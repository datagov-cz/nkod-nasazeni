FROM solr:9.3.0

# Copy core definitions and script to create cores.
COPY --chown=solr:solr ./templates/ /opt/templates/

# Entry point files.
COPY --chown=solr:solr ./entrypoint/ /docker-entrypoint-initdb.d/

# Change user.
USER solr

EXPOSE 8983
