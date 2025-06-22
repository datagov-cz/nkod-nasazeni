# Orchestrátor pro spouštění pipeline
Tato komponenta zajišťuje synchronizace a spouštění pipeline v metadatovém procesoru LinkedPipes:ETL.

Komponenta definuje následující akce:
- `./entrypoint/execute.sh` - Execute entry pipeline.
- `./entrypoint/synchronize.sh` - Synchronize pipelines from a remote repository.

## Konfigurace
Spouštění adaptérů je zajištěné Cronu jehož konfigurace je v souboru `./crontab`.

Obsah `.env` souboru:
```ini
# Konfigurace přístupu k LinkedPipes:ETL.
FRONTEND_URL=
STORAGE_URL=

# Pipeline ke spuštění.
PIPELINE_URL=

# Repozitář jako zdroj pipelines a templates.
STORAGE_REPOSITORY_BRANCH=
STORAGE_REPOSITORY=
```

## Datová úložiště
Stažená definice jsou uloženy do `/data/lp-etl/storage/`.

## Logování

## Porty
