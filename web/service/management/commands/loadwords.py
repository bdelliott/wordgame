#!/usr/bin/env python2.6

import os

from django.core.management.base import BaseCommand

from web.service import load


class Command(BaseCommand):
    """ Load some words into the database """

    def run_from_argv(self, argv):
        
        load.load_words()