# Virtuoso databáze

## Konfigurace

Obsah `.env` souboru:
```ini
# Heslo pro "dba" uživatele.
DBA_PASSWORD=
# Heslo pro "dva" uživatele.
DAV_PASSWORD=
```

## Datová úložiště

Data jsou uložena do adresáře `/database` pro uživatele `1001:1001`.

## Logování

Logy jsou zapisovány do `/database/`

## Porty

- 1111 - ODBC 2 / JDBC / ADO.Net / OLE-DB / ISQL data server
- 8890 - HTTP

## Vstupní body

## Poznámky pro vývoj

- Adresář `initdb.d` obsahuje inicializační skripty ke spuštění.
