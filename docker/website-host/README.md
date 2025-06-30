# Komponenta pro hosting webových stránek

Pro update obsahu webových stránek, je třeba nastavit Github hook na adresu `/api/on-github-push.php`.

## Vstupní body

- `/opt/entrypoint.sh`
  Výchozí vstupní bod, inicializuje data a spustí Apache.

## Konfigurace

Obsah `.env` souboru:
```ini
# Výchozí branch.
GITHUB_BRANCH=
# Název repositáře ve tvaru {team}/{repository}
GITHUB_REPOSITORY =
# Secret z Github konfigurace.
GITHUB_SECRET=
# "1" pro kompilaci obsahu pomocí Jekyll.
JEKYLL_ENABLED=1
# Port pro Apache server.
PORT=
```

## Datová úložiště

Data z GitHubu jsou uložena v adresáři `/var/www/html/github`.
Pro zrychlení spuštění je vhodné adresář `/var/www/html/` připojit jako volume.

## Logování

API funkce, pro synchronizaci, zapisuje výsledek do adresáře `/data/log/github.log`.
Tento soubor je přepsán s každou synchronizací.

## Porty

Komponenta poslouchá na následujících portech:
- `80` - Apache server s obsahem.
