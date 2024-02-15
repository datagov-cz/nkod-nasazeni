#!/bin/sh
export PATH=/usr/local/openjdk-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

java -jar /opt/ms-adapter/ms-adapter.jar download-list --site $MS_SITE --list $MS_ALLOWED_PUBLISHERS_LIST --base "http://localhost/allowed-publishers" --output /data/allowed-publishers/content.trig  >> /data/log/allowed-publishers-list.log 2>&1
