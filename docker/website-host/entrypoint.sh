#!/bin/sh

# Make sure mounting point is owned by www-data.
chown www-data:www-data /var/www/

# Download content.
if [ -d "/var/www/html/github/" ]; then
  su - www-data -s /bin/bash -c "cd /var/www/html/github/ && git pull"
else
  mkdir /var/www/html/github/
  chown www-data:www-data /var/www/html/github/
  su - www-data -s /bin/bash -c "cd /var/www/html/github/ && git clone https://github.com/$GITHUB_REPOSITORY.git ."
fi

# Optional content compilation.
if [ "$JEKYLL_ENABLED" = "1" ]; then
  # We set RUBYOPT, to deal with
  # incompatible character encodings: ASCII-8BIT and UTF-8 (Encoding::CompatibilityError)
  su - www-data -s /bin/bash -c 'cd /var/www/html/github/ && export RUBYOPT="-E utf-8:utf-8" && jekyll build'
fi

# Start PHP server.
apache2-foreground
