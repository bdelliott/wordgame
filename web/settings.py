# Initialize App Engine and import the default settings (DB backend, etc.).
# If you want to use a different backend you have to remove all occurences
# of "djangoappengine" from this file.
from djangoappengine.settings_base import *

import os

# the project directory
ROOT_PATH = os.path.abspath(os.path.dirname(__file__))

# technical people who get email harassment when things are broken
ADMINS = (
    ("Brian Elliott", "brian@sparklesoftware.com"),
    ("Matthew Botos", "matthew@sparklesoftware.com"),
)

# non-technical "managers" are the same as the tech wizards for this project
MANAGERS = ADMINS

# from address for server generated email - google has restrictions about the sender address
SERVER_EMAIL = "brian@sparklesoftware.com"

# send emails when 404s happen
SEND_BROKEN_LINK_EMAILS = True

SECRET_KEY = '889746djkljlkc89d7t23(*&GDKLU89g6%^#KJDLFK%&^(GDEGi'

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.contenttypes',
    'django.contrib.auth',
    'django.contrib.sessions',
    'djangotoolbox',

    # web service application
    'service',
    
    # djangoappengine should come last, so it can override a few manage.py commands
    'djangoappengine',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
)

TEMPLATE_CONTEXT_PROCESSORS = (
    'django.contrib.auth.context_processors.auth',
    'django.core.context_processors.request',
    'django.core.context_processors.media',
)

# This test runner captures stdout and associates tracebacks with their
# corresponding output. Helps a lot with print-debugging.
TEST_RUNNER = 'djangotoolbox.test.CapturingTestSuiteRunner'

ADMIN_MEDIA_PREFIX = '/media/admin/'
ROOT_URLCONF = 'urls'

# where templates get loaded from:
TEMPLATE_DIRS = (
    os.path.join(ROOT_PATH, "templates"),
    os.path.join(ROOT_PATH, "service", "templates"),
    os.path.join(ROOT_PATH, "cron", "templates"),
)

# Activate django-dbindexer if available
try:
    import dbindexer
    DATABASES['native'] = DATABASES['default']
    DATABASES['default'] = {'ENGINE': 'dbindexer', 'TARGET': 'native'}
    INSTALLED_APPS += ('dbindexer',)
    DBINDEXER_SITECONF = 'dbindexes'
    MIDDLEWARE_CLASSES = ('dbindexer.middleware.DBIndexerMiddleware',) + \
                         MIDDLEWARE_CLASSES
except ImportError:
    pass
    
# profiling - use with care.
ENABLE_PROFILER = False
SORT_PROFILE_RESULTS_BY = "cumulative" # http://docs.python.org/release/2.5.4/lib/profile-stats.html
MAX_PROFILE_RESULTS = 50

