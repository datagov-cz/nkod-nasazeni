FROM php:8.3-apache

# Use the default production configuration.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install packages
RUN apt update && \
  apt install -y --no-install-recommends git ruby-full build-essential

# Switch to www-data to complete the gem installation, so they
# are available to this user.
USER www-data
WORKDIR /opt/jekyll

# Configure path, as home for www-data is `/var/www/` but www-data
# can not write there.
ENV GEM_HOME="/opt/jekyll/gems"
ENV PATH="/opt/jekyll/gems/bin:$PATH"
# Force UTF-8 to deal with
# "incompatible character encodings: ASCII-8BIT and UTF-8" error.
ENV RUBYOPT="-E utf-8:utf-8"

# Install Ruby bundler.
RUN gem install bundler

# Install Jekyll
COPY --chown=www-data:www-data ./jekyll/Gemfile ./jekyll/Gemfile.lock ./
RUN bundle install

# Change back to root
USER root

# Configure apache.
COPY ./apache2 /etc/apache2/sites-available

# Install hooks.
COPY --chown=www-data:www-data ./api/ /var/www/api/

# Prepare entrypoint.
WORKDIR /opt
COPY --chmod=755 ./entrypoint.sh ./
CMD "./entrypoint.sh"
