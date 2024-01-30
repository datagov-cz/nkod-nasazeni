#!/bin/sh

# Save current environemnt variables to be used by cron.
env >> /etc/environment

# Run cron in foregrouns.
cron -f
