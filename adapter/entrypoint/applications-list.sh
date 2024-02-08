#!/bin/sh
export PATH=/usr/local/openjdk-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

java -jar /opt/ms-adapter/ms-adapter.jar download-list --site $MS_SITE --list $MS_APPLICATION_LIST --output /data/applications/content.trig --base "http://localhost/applicastions" >> /data/log/applications-list.log 2>&1
