#!/bin/sh

java -DconfigurationFile=/opt/isds-adapter/configuration.properties -jar /opt/isds-adapter/isds-adapter.jar >> /data/log/registrations.log 2>&1
