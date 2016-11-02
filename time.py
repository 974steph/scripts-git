#!/usr/bin/python


import logging
import logging.config
import os
import re
import sys
from subprocess import check_call
import time
import datetime

now = int(time.time())
print "NOW: %s" % now

mtime = datetime.datetime.fromtimestamp(now)
print "MDATE: %s" % mtime

pattern = '%Y-%m-%d %H:%M:%S'
new_epoch = int(time.mktime(time.strptime(str(mtime), pattern)))
print "NEW_EPOCH: %s" % new_epoch
