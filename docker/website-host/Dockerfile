FROM php:8.3-apache

# Use the default production configuration.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install packages
RUN apt update && \
  apt install -y --no-install-recommends git ruby-full build-essential

# Install Ruby and Jekyll.
WORKDIR /opt/jekyll
RUN gem install bundler
COPY ./jekyll/Gemfile ./jekyll/Gemfile.lock ./
RUN bundle install

# Configure apache.
COPY ./apache2 /etc/apache2/sites-available

# Install hooks.
COPY --chown=www-data:www-data ./api/ /var/www/api/

# Prepare entrypoint.
WORKDIR /opt
COPY --chmod=755 ./entrypoint.sh ./
CMD "./entrypoint.sh"
