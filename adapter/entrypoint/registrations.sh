#!/bin/sh
export PATH=/usr/local/openjdk-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

java -DconfigurationFile=/opt/isds-adapter/configuration.properties -jar /opt/isds-adapter/isds-adapter.jar >> /data/log/registrations.sh 2>&1
