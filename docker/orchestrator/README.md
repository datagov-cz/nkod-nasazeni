# Orchestrátor
Tato komponenta zajišťuje:
- synchronizace LinkedPipes:ETL
- spouštění pipeline v LinkedPipes:ETL
- přípravu dat před spuštěním LinkedPipes:ETL

## Vstupní body
Komponenta definuje následující akce:
- `/opt/orchestrator/execute-pipeline.sh`
- `/opt/orchestrator/initialize-data-directory.sh`
- `/opt/orchestrator/synchronize-lp-etl.sh`

## Konfigurace
Spouštění adaptérů je zajištěné Cronu jehož konfigurace je v souboru `./crontab`.

Obsah `.env` souboru:
```ini
# Konfigurace přístupu k LinkedPipes:ETL.
FRONTEND_URL=
STORAGE_URL=

# Git repositář jako zdroj pipelines a templates.
STORAGE_REPOSITORY_BRANCH=
STORAGE_REPOSITORY=
```

```
05 2 * * * nkod /opt/orchestrator/synchronize-pipelines-and-templates.sh
25 2 * * * nkod /opt/orchestrator/execute-harvesting.sh
```

## Datová úložiště
Stažená definice jsou uloženy do `/data/lp-etl/storage/`.
Komponenta dále předpokládá přístup do `/data/public/`.

## Logování

## Porty
