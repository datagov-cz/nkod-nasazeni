# Adaptér na externí služby
Tento kontejner je složený z více adaptérů.
V sekci _Adaptéry_ je popsána konfigurace jednotlivých adaptérů.

## Spouštění
Spouštění adaptérů je plánované pomocí cronu jehož konfigurace je v souboru `crontab`.

## Adaptéry

### ms-adaptér
(Adaptér pro přístup ke službám skrze Microsoft Graph API)[https://github.com/datagov-cz/ms-adapter/] je spouštěný ve dvou režimech.
V prvním režimu provádí stáhnutí seznamu registrovaných aplikací, ve druhém pak obrázkových příloh.
Obě tyto části mají společnou následující konfiguraci skrze proměnné prostředí:
- `MS_APPLICATION` - Je popsáno v dokumentaci k ms-adaptéru.
- `MS_TENANT` - Je popsáno v dokumentaci k ms-adaptéru.
- `MS_SECRET` - Je popsáno v dokumentaci k ms-adaptéru.
- `MS_SITE` - Odpovídá argumentu `site` jak je popsán v dokumentaci k ms-adaptéru.

Pro stažení seznamu je třeba nastavit navíc následující proměnné:
- `MS_LIST` - Odpovídá argumentu `list` jak je popsán v dokumentaci k ms-adaptéru.
Výstup je uložen do souboru `/data/applications/content.trig`.
Tato akce je definovaná skriptem `./entrypoint/applications-list.sh`

Pro stažení obsahu adresáře s přílohami je třeba nastavit navíc následující proměnné:
- `MS_DRIVE` - Odpovídá argumentu `drive` jak je popsán v dokumentaci k ms-adaptéru.
- `MS_DIRECTORY` - Odpovídá argumentu `directory` jak je popsán v dokumentaci k ms-adaptéru.
Výstup je uložen do adresáře `/data/applications-images/`.
Tato akce je definovaná skriptem `./entrypoint/applications-image.sh`

### isds-adapter
(Adaptér pro stažení datových zpráv)[https://github.com/datagov-cz/isds-adapter/] je konfigurovatelný pomocí následujících proměnných prostředí:
- `ISDS_LOGIN` - odpovídá konfigurační položce `login` jak je popsán v dokumentaci k isds-adatéru.
- `ISDS_PASSWORD` - odpovídá konfigurační položce `password` jak je popsán v dokumentaci k isds-adatéru.
- `ISDS_URL`- odpovídá konfigurační položce `url` jak je popsán v dokumentaci k isds-adatéru.
Konfigurace předaná isds-adaptéru je uložena `/isds-adapter/configuration.properties`.
V tomto souboru jsou definovány i cestu k načtení certifikátů a uložení stažených zpráv.
Ve výchozím nastavení se certifikáty čtou z  adresáře `/data/certificates`, který je naplněný certifikáty z `./certificates` v tomto repositáři.

## Logování
Adaptéry zapisují logy ve formát JSON do adresáře `/data/log/`.
Jedná se o přesměrování výstupu z adaptérů a je tedy třeba zajistit jeho pravidelné mazání, či rotaci.

## Práva
Aplikace běží pod uživatelem 5987:5987, pro případ mountování adresářů je tedy zajistit oprávnění pro zápis tohoto uživatele.
Výchozího uživatele je možné změnit pomocí proměnné `USER` při sestavování Docker image.
