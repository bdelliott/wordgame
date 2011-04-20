import logging
logger = logging.getLogger("middleware")

from django.shortcuts import render_to_response
from django.template.context import RequestContext

from google.appengine.runtime.apiproxy_errors import CapabilityDisabledError

from error import *

class ExceptionMiddleware(object):
    
    def process_exception(self, request, exception):
        
        logger.exception("Uncaught exception")

        if isinstance(exception, CapabilityDisabledError):
            # google's datastore is in read-only mode.
            context = RequestContext(request)
            return render_to_response("facebook/maintenance.html", context)
            
            
        # treat other exceptions that bubble through to this point as application errors.
        # these exceptions will be handled by Django, which will send email to everyone in settings.ADMINS
        
        return None
