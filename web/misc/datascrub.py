# path hackery to make sure project directory is on sys.path
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
project_dir = os.path.abspath(os.path.join(script_dir, ".."))
import sys
sys.path.insert(0, project_dir)

from django.core.management import execute_manager
try:
    import settings # Assumed to be in the same directory.
except ImportError:
    import sys
    sys.stderr.write("Error: Can't find the file 'settings.py' in the directory containing %r. It appears you've customized things.\nYou'll have to run django-admin.py, passing it your settings module.\n(If the file settings.py does indeed exist, it's causing an ImportError somehow.)\n" % __file__)
    sys.exit(1)


from google.appengine.ext import db
from google.appengine.ext.deferred.deferred import _DeferredTaskEntity

def scrub():
    ''' delete the oddball _DeferredTaskEntity objects '''

    print "-"*80
    
    query = _DeferredTaskEntity.all()
    print "Query returned %d entities" % query.count()
    
    num = 0
    
    for dte in query:
        # catch weird exceptions and keep deleting as much as possibl!
        try:
            dte.delete()
            num += 1
            if num % 100 == 0:
                print num
                
        except:
            print "Delete failed"
        
    print "-"*80
    
if __name__=='__main__':
    
    scrub()