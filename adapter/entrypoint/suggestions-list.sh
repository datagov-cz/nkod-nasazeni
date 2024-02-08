#!/bin/sh
export PATH=/usr/local/openjdk-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

java -jar /opt/ms-adapter/ms-adapter.jar download-list --site $MS_SITE --list $MS_SUGGESTIONS_LIST --base "http://localhost/suggestions" --output /data/suggestions/content.trig  >> /data/log/suggestions-list.log 2>&1
