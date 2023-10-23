# Deployment with Docker Compose
Create ```.env``` file to configure the deployment.
Ax example of the content is bellow:
```
COUCHDB_USER=admin
COUCHDB_PASSWORD=pass
```

Create volume mounts using following commands.
```shell
docker volume create --name nkod-solr-data --opt type=none --opt o=bind --opt device=/data/solr
docker volume create --name nkod-couchdb-data --opt type=none --opt o=bind --opt device=/data/couchdb
```

Build the images using:
```shell
docker compose build
```

Create and start the containers in background:
```shell
docker compose up -d
```
You can call this command later to update only new containers.


You can stop the containers using:
```shell
docker compose down
```
