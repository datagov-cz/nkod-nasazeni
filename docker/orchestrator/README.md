# Orchestrátor pro spouštění pipeline
Tato komponenta zajišťuje synchronizace a spouštění pipeline v metadatovém procesoru LinkedPipes:ETL.

## Vstupní body
Komponenta definuje následující akce:
- `/opt/orchestrator/synchronize-pipelines-and-templates.sh` - Execute entry pipeline.
- `/opt/orchestrator/execute-harvesting.sh` - Synchronize pipelines from a remote repository.

## Konfigurace
Spouštění adaptérů je zajištěné Cronu jehož konfigurace je v souboru `./crontab`.

Obsah `.env` souboru:
```ini
# Konfigurace přístupu k LinkedPipes:ETL.
FRONTEND_URL=
STORAGE_URL=

# Pipeline ke spuštění.
PIPELINE_URL=

# Repositář jako zdroj pipelines a templates.
STORAGE_REPOSITORY_BRANCH=
STORAGE_REPOSITORY=
```

## Datová úložiště
Stažená definice jsou uloženy do `/data/lp-etl/storage/`.
Komponenta dále předpokládá přístup do `/data/public/`.

## Logování

## Porty
