#!/bin/sh

# Make sure mounting point is owned by www-data.
if [ -d "/data/" ]; then
  # This is the expected state.
  .
else
  # The image is running without the mount point.
  mkdir /data/
  chown www-data:www-data /data/
fi

# Download data portal content.
if [ -d "/data/website/" ]; then
  su - www-data -s /bin/bash -c "cd /data/website/ && git pull"
else
  mkdir /data/website/
  chown www-data:www-data /data/website/
  su - www-data -s /bin/bash -c "cd /data/website/ &&
    git clone https://github.com/$GITHUB_REPOSITORY.git . && git checkout --force origin/$GITHUB_BRANCH"
fi

# Jekyll compilation.
# This is our home directory, it must be writable for Jekyll.
chown www-data:www-data /var/www/
# We set RUBYOPT, to deal with
# incompatible character encodings: ASCII-8BIT and UTF-8 (Encoding::CompatibilityError)
su - www-data -s /bin/bash -c 'cd /data/website/ && export RUBYOPT="-E utf-8:utf-8" && jekyll build'

# Start PHP server.
apache2-foreground
