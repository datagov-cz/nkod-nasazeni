#!/bin/sh

# Download content.

if [ -d ".git" ]; then
  su - www-data -s /bin/bash -c "cd /var/www/html/ && git pull"
else
  su - www-data -s /bin/bash -c "cd /var/www/html/ && git clone https://github.com/$GITHUB_REPOSITORY.git ."
fi

# Compile content.
if [ "$JEKYLL_ENABLED" = "1" ]; then
  su - www-data -s /bin/bash -c "cd /var/www/html/ && jekyll build"
fi

# Start PHP server.
apache2-foreground
