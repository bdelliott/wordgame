import datetime
import logging
logger = logging.getLogger("cron")

from django.core.mail import send_mail
from django.http import HttpResponse

from service.models import DailyWord

def reminder(request):
    ''' Cronjab to harass admins to generate words. '''

    logger.info("Running cron reminder")
    
    start = datetime.date.today()
    end = start+datetime.timedelta(days=14)
    
    num = DailyWord.objects.filter(date__gte=start, date__lt=end).count()
    
    # if we don't have 2 weeks of words already set up, send out a reminder.
    if num < 14:
        send_mail('Daily Word nag reminder', 'Nag nag.', 'brian@sparklesoftware.com',
                ['brian@sparklesoftware.com'], fail_silently=False)
                
    return HttpResponse(content="ok")