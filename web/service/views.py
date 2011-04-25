import datetime
import logging
logger = logging.getLogger("views")
logger.setLevel(logging.INFO)

from django.template.context import RequestContext
from django.http import *
from django.shortcuts import *
from django.utils import simplejson as json

from .forms import DailyWordForm
from .models import User, DailyWord, Score
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
        
    d = {
        "scores" : s,
    }
    scores_json = json.dumps(d)
    return HttpResponse(content=scores_json, mimetype='application/javascript')
    
    
def get_word(request):
    ''' get today's word '''
    
    today = datetime.date.today()
    try:
        daily_word = DailyWord.objects.get(date=today)
        
    except DailyWord.DoesNotExist:
        # administrator fail.  better choose a word randomly 
        # and save it so people can use the app today.
        w = word.generate_daily_word(today)
        daily_word = DailyWord()
        daily_word.word = w
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
    
    num_guesses = int(request.POST["num_guesses"])
    word = request.POST["word"]
    
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
    