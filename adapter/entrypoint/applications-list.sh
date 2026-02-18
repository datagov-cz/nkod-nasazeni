#!/bin/sh

export PATH="$JAVA_HOME/bin:$PATH"

java -jar /opt/ms-adapter/ms-adapter.jar download-list --site $MS_SITE --list $MS_APPLICATIONS_LIST --output /data/applications/content.trig --base "http://localhost/applications" >> /data/log/applications-list.log 2>&1
