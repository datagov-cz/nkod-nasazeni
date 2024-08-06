# Adaptér na externí služby
Tato komponenta obsahuje adaptéry na externí služby:
- ms-adaptér - [Adaptér pro přístup ke službám skrze Microsoft Graph API](https://github.com/datagov-cz/ms-adapter/) je spouštěný ve dvou režimech. První umožňuje stažení seznamu (registrovaných aplikací), druhý pak adresáře (přílohy k registracím),
  V prvním režimu provádí stáhnutí seznamu registrovaných aplikací, ve druhém pak obrázkových příloh.
- isds-adapter - [Adaptér pro stažení datových zpráv](https://github.com/datagov-cz/isds-adapter/).

V rámci těchto adaptérů jsou definovány následující akce:
- stažení seznamu registrovaných aplikací - skript `./entrypoint/applications-list.sh`
- stažení adresáře příloh registrovaných aplikací - `./entrypoint/applications-image.sh`

## Konfigurace
Spouštění adaptérů je zajištěné Cronu jehož konfigurace je v souboru `./crontab`.

Konfigurace předaná isds-adaptéru je uložena `/isds-adapter/configuration.properties`.
V tomto souboru jsou definovány i cestu k načtení certifikátů a uložení stažených zpráv.
Ve výchozím nastavení se certifikáty čtou z  adresáře `/data/certificates`, který je naplněný certifikáty z `./certificates` v tomto repositáři.

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

## Datová úložiště
Stažený list registrovaných aplikací je uložen do souboru `/data/applications/content.trig`.
Stažený adresář příloh k registrovaným aplikacím  je uložen do adresáře `/data/applications-images/`.
Stažené datové zprávy jsou uložené do adresáře `/data/registrations` (nastaveno v konfiguraci isds-adaptéru).
Aplikace běží pod uživatelem 5987:5987 pro kterého je třeba nastavit práva v datovém úložišti.
Stažený list registrovaných požadavků na zveřejnění datových sad je uložen do souboru `/data/suggestions/content.trig`.
Stažený list povolených poskytovatelů je uložen do souboru  `/data/suggestions/allowed-publishers.trig`.

## Logování
Adaptéry zapisují logy ve formát JSON do adresáře `/data/log/`.
Jedná se o přesměrování výstupu z adaptérů a je tedy třeba zajistit jeho pravidelné mazání, či rotaci.

## Porty
