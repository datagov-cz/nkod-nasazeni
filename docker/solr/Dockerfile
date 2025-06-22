# WARN Solr will start in SolrCloud mode by default in version 10,
#   and you will have to provide --user-managed if you want to
#   stay on the user-managed (aka. standalone) mode.
# WARN We need to update libraries `analysis-extras` in `solrconfig.xml`
#   if we change the version of Solr.
FROM solr:9.8.1

# Copy core definitions and script to create cores.
COPY --chown=solr:solr ./templates/ /opt/templates/
COPY --chown=solr:solr ./templates-seed/ /opt/templates-seed/

# Entry point files.
COPY --chown=solr:solr ./entrypoint/ /docker-entrypoint-initdb.d/

# Configuration.
COPY --chown=solr:solr ./log4j2.xml /var/solr/

# Change user.
USER solr

# https://solr.apache.org/guide/solr/latest/configuration-guide/solr-modules.html#installing-a-module
# Enable modules for language specific features.
ENV SOLR_MODULES="analysis-extras"

# <lib path="${solr.install.dir:../../../..}/contrib/analysis-extras/lib/solr-analysis-extras-9.8.1.jar" />
# <lib path="${solr.install.dir:../../../..}/contrib/analysis-extras/lib/icu4j-74.2.jar" />
# <lib path="${solr.install.dir:../../../..}/contrib/analysis-extras/lib/lucene-analysis-icu-9.11.1.jar" />


EXPOSE 8983
