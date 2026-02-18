#!/bin/sh

# Save current environment variables to be used by cron.
env >> /etc/environment

# Run cron in foreground.
cron -f
