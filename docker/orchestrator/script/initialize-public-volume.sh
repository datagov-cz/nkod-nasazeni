#!/bin/bash
#
# Initialize public volume.
#

set -e

# Create directories
mkdir -p /data/public/soubor 2>/dev/null

# Make sure we have the public nkod.trig file.
if [ ! -f /data/public/soubor/nkod.trig ]; then
    touch /data/public/soubor/nkod.trig 2>/dev/null
fi
