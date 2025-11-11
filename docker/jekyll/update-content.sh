#!/bin/sh

cd /data/website/

# Update
git checkout --force origin/$GITHUB_BRANCH

# We set RUBYOPT, to deal with
# incompatible character encodings: ASCII-8BIT and UTF-8 (Encoding::CompatibilityError)
export RUBYOPT="-E utf-8:utf-8"
jekyll build
