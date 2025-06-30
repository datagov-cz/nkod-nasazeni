FROM php:8.3-apache

# Use the default production configuration.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install packages
RUN apt update && \
  apt install -y --no-install-recommends git ruby-full build-essential

# Install Ruby bundler.
ENV GEM_HOME="$HOME/gems"
ENV PATH="$HOME/gems/bin:$PATH"
# Force UTF-8 to deal with
# "incompatible character encodings: ASCII-8BIT and UTF-8" error.
ENV RUBYOPT="-E utf-8:utf-8"
RUN gem install bundler

# Install Jekyll
WORKDIR /opt/jekyll
COPY ./jekyll/Gemfile ./jekyll/Gemfile.lock ./
RUN bundle install

# Configure apache.
COPY ./apache2 /etc/apache2/sites-available

# Install hooks.
COPY --chown=www-data:www-data ./api/ /var/www/api/

# Prepare entrypoint.
WORKDIR /opt
COPY ./entrypoint.sh ./
CMD "./entrypoint.sh"

ENV GITHUB_BRANCH="main"
ENV GITHUB_REPOSITORY="datagov-cz/data.gov.cz"
ENV JEKYLL_ENABLED="1"
