from django.db import models

CLIENT_IPHONE = "iPhone"

CLIENT_NAMES = (
    (CLIENT_IPHONE, CLIENT_IPHONE),
)

class User(models.Model):
    ''' Store additional info about our users here. '''

    user_name = models.CharField("User supplied name", max_length=32)
    
    def __str__(self):
        return self.user_name
        
        
class DailyWord(models.Model):
    ''' word of the day '''
    
    word = models.CharField("The word of the day", max_length=16, unique=True)
    date = models.DateField("The date", unique=True)
    
    def __str__(self):
        return "%s: %s" % (self.date, self.word)
        
    
class Score(models.Model):
    ''' user scores '''
    
    daily_word = models.ForeignKey(DailyWord)
    user = models.ForeignKey(User)
    num_guesses = models.IntegerField("Number of guesses")
    
    def __str__(self):
        return "%s: %s: %d" % (self.daily_word, self.user, self.num_guesses)


class Word(models.Model):
    ''' American words - just used for help picking the daily word. '''
    
    word = models.CharField("An American word", max_length=16)
    
    def __str__(self):
        return self.word
 
class ConfigValue(models.Model):
    ''' configuration value '''
    
    client_name = models.CharField("Client name", max_length=8, choices=CLIENT_NAMES)
    min_version = models.CharField("Minimum client version", max_length=6)
    
    name = models.CharField("Configuration item name", max_length=16)
    value = models.CharField("Configuration item value", max_length=1024)
    

    def __str__(self):
        return "%s: %s (%s, %s)" % (self.name, self.value, self.client_name, self.min_version)