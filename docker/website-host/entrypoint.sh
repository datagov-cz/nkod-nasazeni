#!/bin/sh

# Download content.

if [ -d "github" ]; then
  su - www-data -s /bin/bash -c "cd /var/www/html/github/ && git pull"
else
  mkdir /var/www/html/github/
  chown www-data:www-data /var/www/html/github/
  su - www-data -s /bin/bash -c "cd /var/www/html/github/ && git clone https://github.com/$GITHUB_REPOSITORY.git ."
fi

# Compile content.
if [ "$JEKYLL_ENABLED" = "1" ]; then
  su - www-data -s /bin/bash -c "cd /var/www/html/github/ && jekyll build"
fi

# Start PHP server.
apache2-foreground
