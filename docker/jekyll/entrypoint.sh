#!/bin/sh

# Make sure mounting point is owned by www-data.
if [ -d "/mnt/website/" ]; then
  # This is the expected state.
  .
else
  # The image run without mounted point.
  mkdir /mnt/website/
fi
# Make sure www-data has access.
chown www-data:www-data /mnt/website/

# Download data portal content.
if [ -d "/mnt/website/github/" ]; then
  su - www-data -s /bin/bash -c "cd /mnt/website/github/ && git pull"
else
  mkdir /mnt/website/github/
  chown www-data:www-data /mnt/website/github/
  su - www-data -s /bin/bash -c "cd /mnt/website/github/ &&
    git clone https://github.com/$GITHUB_REPOSITORY.git . && git checkout --force origin/$GITHUB_BRANCH"
fi

# Jekyll compilation.
# This is our home directory, it must be writable for Jekyll.
chown www-data:www-data /var/www/
# We set RUBYOPT, to deal with
# incompatible character encodings: ASCII-8BIT and UTF-8 (Encoding::CompatibilityError)
su - www-data -s /bin/bash -c 'cd /mnt/website/github/ && export RUBYOPT="-E utf-8:utf-8" && jekyll build'

# Start PHP server.
apache2-foreground
