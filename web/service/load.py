# data loader - load words into the database

import os
import sys

from django.conf import settings

from .models import Word

def load_words():
    
    proj_dir = settings.ROOT_PATH
    path = os.path.join(proj_dir, "scowl-7.1", "final", "american-words.35");
    if not os.path.exists(path):
        print "Can't find word list file to load!"
        sys.exit(1)
        
    f = open(path, "r")
    for line in f:
        word = line.strip().lower()
        load_word(word)
        
    f.close()
    
def load_word(word):
    
    print "Loading word: %s" % word
    
    # words with apostrophes are skipped
    if word.find("'") != -1:
        return
        
    # past tense words ending in "ed" are skipped
    if word.endswith("ed"):
        return 
        
    # skip plurals
    if word.endswith("s"):
        return

    # skip "ing" form of words
    if word.endswith("ing"):
        return
        
    # skip "ation" form of words
    if word.endswith("ation"):
        return
        
    # confirm it's not a duplicate
    try:
        w = Word.objects.get(word=word)
        # skip this word cause we already have it.
        return
        
    except Word.DoesNotExist:
        
        # add word.
        w = Word()
        w.word = word
        w.save()
        
    