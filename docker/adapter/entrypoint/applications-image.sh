#!/bin/sh

java -jar /opt/ms-adapter/ms-adapter.jar download-directory \
  --site "$MS_SITE" \
  --path "$MS_APPLICATIONS_PATH" \
  --output /data/adapter/applications-images/ \
  >> /data/log/applications-image.log 2>&1
