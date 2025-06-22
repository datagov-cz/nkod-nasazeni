ARG DEPLOYMENT_ENVIRONMENT=main

FROM ghcr.io/datagov-cz/ms-adapter:${DEPLOYMENT_ENVIRONMENT} as ms-adapter

FROM ghcr.io/datagov-cz/isds-adapter:${DEPLOYMENT_ENVIRONMENT} as isds-adapter

# The final image.
FROM openjdk:21-bookworm

# Install cron.
RUN apt-get update && apt-get install cron -y

# Create user we use to run the scripts.
ARG USER=5987
RUN addgroup --gid $USER "nkod" \
    && useradd --gid "nkod" --uid $USER "nkod" --create-home

# Copy ms-adapter.
COPY --from=ms-adapter --chown=nkod:nkod /opt/ms-adapter/ /opt/ms-adapter/

# Copy isds-adapter and configuration.
COPY --from=isds-adapter --chown=nkod:nkod /opt/isds-adapter/ /opt/isds-adapter/
COPY --chown=nkod:nkod ./isds-adapter/configuration.properties /opt/isds-adapter/

# Copy certificates as read-only.
WORKDIR /data/certificates
COPY --chown=nkod:nkod ./certificates ./
RUN chmod 444 *

# Create data directory and set access.
WORKDIR /data/
RUN mkdir log \
  && chown -R nkod:nkod /data

# Copy entrypoints.
WORKDIR /opt/entrypoint.d/
COPY ./entrypoint ./
RUN chown nkod:nkod *.sh && chmod 0744 *.sh

# Copy main script to be executed.
COPY ./entrypoint.sh /opt/
RUN chmod u+x /opt/entrypoint.sh

# Setup cron.
COPY crontab /etc/cron.d/adapter-cron-file
RUN chmod 0644 /etc/cron.d/adapter-cron-file
RUN crontab /etc/cron.d/adapter-cron-file

# Set starting location.
WORKDIR /opt/

# Creating entry point for cron.
CMD ["/opt/entrypoint.sh"]
