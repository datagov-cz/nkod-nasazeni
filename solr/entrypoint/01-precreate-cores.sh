#!/bin/bash

if [ ! -d "/var/solr/data/applications" ]
then
    precreate-core applications /opt/templates/applications
fi

if [ ! -d "/var/solr/data/continents" ]
then
    precreate-core continents /opt/templates/continents
fi

if [ ! -d "/var/solr/data/countries" ]
then
    precreate-core countries /opt/templates/countries
fi

if [ ! -d "/var/solr/data/dataset-themes" ]
then
    precreate-core dataset-themes /opt/templates/dataset-themes
fi

if [ ! -d "/var/solr/data/dcat-ap-viewer" ]
then
    precreate-core dcat-ap-viewer /opt/templates/dcat-ap-viewer
fi

if [ ! -d "/var/solr/data/eurovoc" ]
then
    precreate-core eurovoc /opt/templates/eurovoc
fi

if [ ! -d "/var/solr/data/frequencies" ]
then
    precreate-core frequencies /opt/templates/frequencies
fi

if [ ! -d "/var/solr/data/hvd-categories" ]
then
    precreate-core hvd-categories /opt/templates/hvd-categories
fi

if [ ! -d "/var/solr/data/iana-media-types" ]
then
    precreate-core iana-media-types /opt/templates/iana-media-types
fi

if [ ! -d "/var/solr/data/mdr-file-type" ]
then
    precreate-core mdr-file-type /opt/templates/mdr-file-type
fi

if [ ! -d "/var/solr/data/places" ]
then
    precreate-core places /opt/templates/places
fi

if [ ! -d "/var/solr/data/ruian" ]
then
    precreate-core ruian /opt/templates/ruian
fi

if [ ! -d "/var/solr/data/suggestions" ]
then
    precreate-core suggestions /opt/templates/suggestions
fi
