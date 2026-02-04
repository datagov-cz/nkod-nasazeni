#!/bin/sh

# Initialize volumes.
su nkod /opt/orchestrator/initialize-data-directory.sh

# Prepare cron file to be used by the cron.
RUN chmod 0644 /etc/cron.d/adapter-cron-file
RUN crontab /etc/cron.d/adapter-cron-file

# Save current environment variables to be used by cron.
env >> /etc/environment

# Run cron in the foreground.
cron -f
