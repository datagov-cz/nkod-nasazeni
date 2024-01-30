#!/bin/sh
export PATH=/usr/local/openjdk-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

java -jar /opt/ms-adapter/ms-adapter.jar download-list --site $MS_SITE --list $MS_LIST --output /data/applications/content.trig  >> /data/log/applications-list.sh 2>&1
