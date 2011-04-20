import os

# set app id and version for testing
os.environ["CURRENT_VERSION_ID"] = "%s.1234" % os.getlogin()
os.environ["APPLICATION_ID"] = "thehoneylist"

# from testmodule import *