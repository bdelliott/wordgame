from django import forms

from .models import DailyWord

class DailyWordForm(forms.Form):
    
    date = forms.DateField()
    word = forms.CharField(max_length=16)

    def clean_date(self):
        ''' confirm an entry date has not yet been saved '''
        
        date = self.cleaned_data["date"]
        x = DailyWord.objects.filter(date=date).count()
        if x > 0:
            raise forms.ValidationError("Date %s already has a daily word configured" % date)
            
        return date
        
    def clean_word(self):
        ''' confirm this word has not already been used '''
        
        word = self.cleaned_data["word"]        
        x = DailyWord.objects.filter(word=word).count()
        if x > 0:
            raise forms.ValidationError("Word %s has already been used." % word)
            
        return word
