#!/bin/sh

java -jar /opt/ms-adapter/ms-adapter.jar download-list \
  --site "$MS_SITE" \
  --list "$MS_APPLICATIONS_LIST" \
  --base "http://localhost/applications" \
  --output /data/adapter/applications/content.trig \
  >> /data/log/applications-list.log 2>&1
