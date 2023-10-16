# Deployment with Docker Compose

Create volume mounts using following commands.
```shell
docker volume create --name nkod-solr-data --opt type=none --opt o=bind --opt device=/data/solr
docker volume create --name nkod-couchdb-data --opt type=none --opt o=bind --opt device=/data/couchdb
```
