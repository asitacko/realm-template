#!/usr/bin/env bash

set -e
cd dj
python manage.py check
python manage.py makemigrations --check --dry-run
