import logging
logger = logging.getLogger("word")

import os

import random

from .models import DailyWord, Word

def generate_daily_word(date):
    
    num_words = Word.objects.count()
    if num_words == 0:
        raise Exception("generate_daily_word: No words in the fallback wordlist!")

    
    while True:
        x = random.randint(0, num_words-1) # 1 <= x <= num_words
        w = Word.objects.all()[x]
    
        # confirm word hasn't been used previously.
        try:
            DailyWord.objects.get(word=w.word)
            # it's been used before.
        except DailyWord.DoesNotExist:
            break
            
    logger.info("Generated daily word: %s" % w)
    
    return w.word
    
    