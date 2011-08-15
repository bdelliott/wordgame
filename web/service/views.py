import datetime
import logging
logger = logging.getLogger("views")
logger.setLevel(logging.INFO)
import time

from django.template.context import RequestContext
from django.http import *
from django.shortcuts import *
from django.utils import simplejson as json

from .forms import DailyWordForm
from models import *
from . import word

def choosewords(request):
    ''' admin view for choosing upcoming words. '''

    today = datetime.date.today()
    logger.info("choosewords: Today is %s" % today)

    context = RequestContext(request)
    
    dwords = DailyWord.objects.filter(date__gte=today).order_by("date")
    logger.info(dwords)
    date = today
    x = len(dwords)
    if x > 0:
        date = dwords[x-1].date + datetime.timedelta(days=1)

    logger.info("choosewords: Choosing word for date %s" % today)
        
    if request.method == "GET":
        # render form.
    
        context["form"] = DailyWordForm(initial= { 
            "date" : date,
        })

    else:
        # validate and save.

        form = DailyWordForm(request.POST)
        if form.is_valid():
            
            # form is valid - 
            
            dw = DailyWord()
            dw.date = form.cleaned_data["date"]
            dw.word = form.cleaned_data["word"]
            dw.save()
            return redirect("choosewords")
            
        else:
            context["form"] = form
            
    context["dwords"] = dwords
    return render_to_response("service/choosewords.html", context)
            
            
def get_scores(request):
    # TODO this may need a date parameter due to possible race condition with the clock flipping over midnight.
    
    # get today's top scores
    today = datetime.date.today()
    logger.info("Getting scores for %s" % today)
    
    dw = DailyWord.objects.get(date=today)
    
    top_scores = Score.objects.filter(daily_word=dw).order_by("num_guesses")[:50]
    
    logger.info("Return %d top scores" % len(top_scores))
    
    s = []
    for ts in top_scores:
        s.append({
            "user_name" : ts.user.user_name,
            "num_guesses" : ts.num_guesses,
        })
        
    # also include config setting for enabling brags.
    client_name = request.GET.get("client_name", CLIENT_IPHONE) # default to iphone if parameter not provided.
    bragEnabled = 0
    try:
        config_value = ConfigValue.objects.get(name="bragEnabled", client_name=client_name)
        bragEnabled = int(config_value.value)
        
    except ConfigValue.DoesNotExist:
        logger.error("No config setting for '%s' found with client_name '%s'" % ("bragEnabled", client_name))
        bragEnabled = 0 

    d = {
        "scores" : s,
        "bragEnabled" : bragEnabled
    }
    scores_json = json.dumps(d)
    return HttpResponse(content=scores_json, mimetype='application/javascript')
    
def get_time(request):
    ''' just a debug view '''
    # get google app engine time
    now = datetime.datetime.now()
    logger.info("Server time is: %s" % now)
    
    d = {
        "year" : now.year,
        "month" : now.month,
        "day" : now.day,
        "hour" : now.hour,
        "minute" : now.minute,
        "second" : now.second,
    }
    
    now_json = json.dumps(d)
    return HttpResponse(content=now_json, mimetype='application/javascript')
    
def get_word(request):
    ''' Get the requested word of the day.
    
        Clients of versions <= 1.2 flip over to the new word at midnight GMT time.  
        
        In 1.3+, switching to midnight, PST (pacific) so the word flips overnight for Americans, who are our main audience anyway.
        This is accomodated by adding a client version parameter.
    ''' 
    
    year = request.GET.get("y")
    month = request.GET.get("m")
    day = request.GET.get("d")
    client_version = request.GET.get("v", "pre-1.3") # default to old version if parameter not present.
    
    if client_version == "pre-1.3":
        # old clients expect the word to flip at midnight UTC, so we need to respect that:
        utcnow = datetime.datetime.utcnow()
    
        word_date = utcnow.date()
        logger.info("Get word: old client, using word date %s" % utcnow.strftime("%m/%d/%Y"))
        
        
    else:
        # Note: newer clients supply the date for the word they want.  letting the client supply the date
        # avoids any midnight clock synch race conditions between client and server with respect to fetching the word
        # and its corresponding high scores.  

        if not year:
            raise Exception("Get word: 'y' is a required parameter.")
        if not month:
            raise Exception("Get word: 'm' is a required parameter.")
        if not day:
            raise Exception("Get word: 'd' is a required parameter.")
        year = int(year)
        month = int(month)
        day = int(day)

        word_date = datetime.date(year, month, day)
        logger.info("Get word: new client (%s), using word date %s" % (client_version, word_date.strftime("%m/%d/%Y")))
        
        
    try:
        daily_word = DailyWord.objects.get(date=word_date)
        
    except DailyWord.DoesNotExist:
        logger.error("Get word: No word available for date %s" % word_date.strftime("%m/%d/%Y"))
        # administrator fail.  better choose a word randomly 
        # and save it so people can use the app today.
        w = word.generate_daily_word(word_date)
        daily_word = DailyWord()
        daily_word.word = w
        daily_word.date = word_date
        daily_word.save()
        
    # return daily word as json.
    d = {
        "year" : daily_word.date.year,
        "month" : daily_word.date.month,
        "day" : daily_word.date.day,
        "word" : daily_word.word,
    }
    dw_json = json.dumps(d)
    return HttpResponse(content=dw_json, mimetype='application/javascript')
        
        
def post_score(request, user_name):
    
    num_guesses = request.POST.get("num_guesses")
    if not num_guesses:
        msg = "post_score: 'num_guesses' param missing or empty string"
        logger.warn(msg)
        return HttpResponseBadRequest(msg)
        
    num_guesses = int(num_guesses)
    
    word = request.POST.get("word")
    if not word:
        msg = "post_score: 'word' param missing or empty string"
        logger.warn(msg)
        return HttpResponseBadRequest(msg)
    
    dw = DailyWord.objects.get(word=word)   # make sure we apply score to right word if score gets submitted close to midnight.
    
    try:
        user = User.objects.get(user_name=user_name)
    except User.DoesNotExist:
        user = User()
        user.user_name = user_name
        user.save()
        
    # duplicate check
    try:
        logger.info("post_score: skipping duplicate for user %s, word %s" % (user, word))
        Score.objects.get(daily_word=dw, user=user)
        
    except Score.DoesNotExist:
        score = Score()
        score.daily_word = dw
        score.user = user
        score.num_guesses = num_guesses
        score.save()
    
    d = {
        "success" : True,
    }
    post_json = json.dumps(d)
    return HttpResponse(content=post_json, mimetype='application/javascript')
    