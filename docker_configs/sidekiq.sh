#!/bin/sh
cd /home/app/webapp
exec /sbin/setuser app bundle exec sidekiq -e production