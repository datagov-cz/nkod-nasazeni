# Docker compose
Nasazení pomocí Docker compose počítá s nasazením NKOD ve třech komponentách.
Každé této komponentě odpovídá jeden Docker compose source.
- Databáze : docker-compose-database.yml
- Webové rozhraní : docker-compose-website.yml
- Datový procesoru : docker-compose-processing.yml

Jednotlivé komponenty je možné provozovat odděleně, nebo na jednom stroji.
Konfigurace komponent probíhá skrze proměnné prostředí a připojením datového úložiště skrze [Docker _volumes_](https://docs.docker.com/storage/volumes/).

Ve zbytku tohoto dokumentu jsou zkráceně popsány jednotlivé komponenty a postup jejich konfigurace a nasazení.
Pro každou komponentu je popsán konfigurační soubor (`.env`), připojení datového úložiště a porty, na kterých je možné se službou komunikovat.
Detailnější informace je možné najít v adresářích příslušných komponent.

Společný obsah `.env` souboru:
```
# "develop" or "main"
# Vybírá prostředí a určuje tagy pro Docker image.
DEPLOYMENT_ENVIRONMENT=
```

## Komponenta: databáze
Komponenta obsahuje:
- CouchDB databázi
- Solr databázi

### Konfigurace
Obsah `.env` souboru:
```
# Uživatelské jméno pro CouchDB.
COUCHDB_USER=
# Uživatelské heslo pro CouchDB.
COUCHDB_PASSWORD=
```

### Datová úložiště
Příkazy pro vytvoření:
```shell
docker volume create --name nkod-solr-data --opt type=none --opt o=bind --opt device=/data/solr
docker volume create --name nkod-couchdb-data --opt type=none --opt o=bind --opt device=/data/couchdb
```
Obsah adresářů je inicializován při spuštění kontejnerů automaticky.
První _volume_ využívá Solr a je třeba aby byl zapisovatelný uživatelem 8983:8983.
Druhý _volume_ používá CouchDB, který běží pod root a není tedy třeba nijak upravovat oprávnění.

### Porty
- 8983 - Solr
- 5984 - CouchDB

## Komponenta: webového rozhraní
Komponenta obsahuje:
- application-catalog

### Konfigurace
Obsah `.env` souboru:
```
# URL na které je dostupný Solr.
SOLR_URL=
# URL na které je dostupný CouchDB.
COUCHDB_URL=
# URL komponenty dcat-ap-form.
DATASET_CATALOG_URL=
```

### Datová úložiště
Tato komponenta neukládá data.

### Porty
- 8083 - nkod-application-catalog

## Komponenta: Datového procesoru
Komponenta obsahuje:
- adapter

### Konfigurace
Obsah `.env` souboru:
```
# Konfigurace pro ms-adaptér popsaná v jeho dokumentaci.
MS_APPLICATION=
MS_TENANT=
MS_SECRET=

# Odpovídá argumentu "site" jak je popsán v dokumentaci k ms-adaptéru.
# Jedná se o stránku/skupiny s registracemi aplikací.
MS_SITE=

# Odpovídá argumentu "list" jak je popsán v dokumentaci k ms-adaptéru.
# Jedná se o list s registracemi aplikací.
MS_APPLICATIONS_LIST=
# Odpovídá argumentu "path" jak je popsán v dokumentaci k ms-adaptéru.
# Jedná se o cestu oddělenou pomocí znaku `/`.
# První část cesty je jméno knihovny, následují jména adresářů.
# Cesta vede do adresáře obrázků pro aplikace.
MS_APPLICATIONS_PATH=

# Odpovídá argumentu "list" jak je popsán v dokumentaci k ms-adaptéru.
# Jedná se o list s registracemi aplikací.
MS_SUGGESTIONS_LIST=

# Odpovídá argumentu "list" jak je popsán v dokumentaci k ms-adaptéru.
# Jedná se o list s poskytovateli.
MS_ALLOWED_PUBLISHERS_LIST=

# Konfigurace isds-adaptéru popsaná v jeho dokumentaci.
ISDS_LOGIN=
ISDS_PASSWORD=
ISDS_URL=
```

### Datová úložiště
Příkazy pro vytvoření:
```shell
docker volume create --name nkod-adapter-data --opt type=none --opt o=bind --opt device=/data/adapter
```
Aplikace běží pod uživatelem 5987:5987 pro kterého je třeba nastavit práva v datovém úložišti.

### Porty
Tato komponenta nevystavuje funkcionality skrze síť.
