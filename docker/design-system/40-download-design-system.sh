#!/bin/sh
if [ ! -d "/usr/share/nginx/html/design-system/" ]; then
  cd /tmp
  wget https://github.com/datagov-cz/design-system/releases/download/2025-07-01/design-system.zip
  unzip design-system.zip
  # Create a target and copy.
  mv assets/design-system/ /usr/share/nginx/html/
fi
