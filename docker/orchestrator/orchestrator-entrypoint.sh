#!/bin/sh

# Initialize volumes.
su nkod /opt/orchestrator/initialize-public-volume.sh

# Save current environment variables to be used by cron.
env >> /etc/environment

# Run cron in the foreground.
cron -f
