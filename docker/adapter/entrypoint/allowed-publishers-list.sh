#!/bin/sh

java -jar /opt/ms-adapter/ms-adapter.jar download-list \
  --site "$MS_SITE" \
  --list "$MS_ALLOWED_PUBLISHERS_LIST" \
  --base "http://localhost/allowed-publishers" \
  --output /data/adapter/allowed-publishers/content.trig  \
  >> /data/log/allowed-publishers-list.log 2>&1
