import datetime
import logging
logger = logging.getLogger("cron")

from django.conf import settings
from django.core.mail import send_mail
from django.core.urlresolvers import reverse
from django.http import HttpResponse

import models
from service.models import DailyWord

def reminder(request):
    ''' Cronjab to harass admins to generate words. '''

    logger.info("Cron: Running reminder")
    
    start = datetime.date.today()
    end = start+datetime.timedelta(days=14)
    
    num = DailyWord.objects.filter(date__gte=start, date__lt=end).count()
    logger.info("Cron: %d words scheduled in next 2 weeks.", num)
    
    # if we don't have 2 weeks of words already set up, send out a reminder.
    if num < 14:
        logger.info("Cron: Sending nag reminder to admins")
        send_nag_mail()
    else:
        logger.info("Cron: Skipping nag reminder")

    return HttpResponse(content="ok")
    
def send_nag_mail():

    to_emails = [ email for (name, email) in settings.MANAGERS]
    logger.info("Sending nag mails to %s" % ",".join(to_emails))
    
    path = reverse('choosewords')
    nag_msg = "Nag reminder to choose daily words for the near future at: http://sparkleword.appspot.com%s" % path
    nag_msg += "\nThis nag reminder will be generated daily until at least 2 weeks of words in the future have been generated."
    send_mail('Daily Word nag reminder', nag_msg, 'brian@sparklesoftware.com',
            to_emails, fail_silently=False)

    # save a log that we sent the outgoing mails:
    job_entry = models.ScheduledJobEntry()
    job_entry.job_type = models.JOB_TYPE_MAIL_REMINDER
    job_entry.save()
    
