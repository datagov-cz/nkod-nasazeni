FROM solr:9.3.0

# Data and logs are saved to /var/solr
# Configuration in /etc/default/solr

# Copy core definitions and script to create cores.
COPY --chown=solr:solr ./templates/ /opt/templates/
COPY --chown=solr:solr ./create-core.sh /docker-entrypoint-initdb.d/

# Change user.
USER solr

# Allow to change content using HTTP requests.
# https://solr.apache.org/guide/solr/latest/indexing-guide/content-streams.html#remote-streaming
SET SOLR_ENABLE_STREAM_BODY=true
SET SOLR_ENABLE_REMOTE_STREAMING=true

EXPORT 8983
