#!/bin/sh

# Set environment variables.
export GEM_HOME="/opt/jekyll/gems"
export PATH="/opt/jekyll/gems/bin:$PATH"
export RUBYOPT="-E utf-8:utf-8"

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
