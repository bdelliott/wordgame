from django.db import models

JOB_TYPE_MAIL_REMINDER = "MR"

JOB_TYPE_CHOICES = (
    (JOB_TYPE_MAIL_REMINDER, "Mail Reminder"), 
)

class ScheduledJobEntry(models.Model):
    ''' Just note the time that a schedule job ran. '''
    
    job_type = models.CharField(max_length=2, choices=JOB_TYPE_CHOICES)
    job_time = models.DateTimeField(auto_now_add=True) # timestamp automatically taken when model is saved.
    
    def __str__(self):
        return "%s: %s" % (self.job_time, self.job_type)
        
    class Meta:
        verbose_name_plural = "Scheduled job entries"