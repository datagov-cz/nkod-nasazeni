FROM ubuntu:noble-20250529

RUN apt-get update \
 && apt-get -y --no-install-recommends install git curl ca-certificates cron

# Create user we use to run the scripts.
ARG USER=5987
RUN addgroup --gid $USER "nkod" \
    && useradd --gid "nkod" --uid $USER "nkod" --create-home

# Copy entrypoints.
WORKDIR /opt/entrypoint
COPY ./entrypoint ./
RUN chown nkod:nkod *.sh && chmod 0744 *.sh

# Copy entrypoints.
WORKDIR /opt/entrypoint
COPY ./entrypoint ./
RUN chown nkod:nkod *.sh && chmod 0744 *.sh

# Setup cron.
COPY crontab /etc/cron.d/adapter-cron-file
RUN chmod 0644 /etc/cron.d/adapter-cron-file
RUN crontab /etc/cron.d/adapter-cron-file

# Set starting location.
WORKDIR /opt/

# Creating entry point for cron.
CMD ["/opt/entrypoint.sh"]
