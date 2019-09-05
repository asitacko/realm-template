#!/usr/bin/env bash

set -e
cd dj
python manage.py migrate
