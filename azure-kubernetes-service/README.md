# Nasazení do prostředí Azure Kubernetes Service (AKS)

Tato sekce obsahuje poznámky k uvážení před nasazením.
Tuto sekci je nutné si přečíst, jinak to nemusí dopadnout dobře!

- Pro produkčního nasazení bude vhodné uvážit SKU.
  Tento návod využívá Locally redundant storage (LRS), nicméně pro produkci by byla vhodná volba dražšího řešení.
- Pro produkčního nasazení bude vhodné uvážit změnu `node-vm-size`.


## Požadavky

Pro spuštění níže uvedených příkazů je třeba mít nainstalováno:
- `powershell`
- `kubectl`, verze by měla odpovídat AKS.
  [Postup instalace](https://kubernetes.io/docs/tasks/tools/).
- `az`, Azure CLI
  [Postup instalace](https://learn.microsoft.com/cs-cz/cli/azure/install-azure-cli?view=azure-cli-latest).
- `kubelogin`, Kubelogin
  [Postup instalace](https://azure.github.io/kubelogin/install.html).

## Příprava prostředí powershell

Všechny níže uvedené příkazy předpokládají:
- Spuštění v kořeni tohoto adresáře.
- Nastavení následujících proměnných prostředí:
  ```shell
  $env:SUBSCRIPTION=
  $env:RESOURCE_GROUP=
  $env:AKS_CLUSTER="nkd-kubernetes"
  $env:CONTAINER_REGISTRY="nkdcontainerregistry"
  $env:LOCATION="northeurope"
  ```

## Nastavení Azure CLI (az)

```shell
# Přihlásíme se do Azure, je třeba vybrat správnou "subscription".
az login
# "subscription" je možné změnit pomocí následujícího příkazu.
az account set --subscription $env:SUBSCRIPTION
# Pro kontrolu aktuální "subscription" lze použít následující příkaz.
az account show -o table
```

## Příprava prostředí Azure

Toto je třeba provést pouze jednou!
Alternativu je tvorba skrze portál Azure.
```shell
# Založení Azure Container Registry (ACR).
# Můžeme získávat images také z jiného místa, ale tady bude lepší dostupnost.
az acr create --resource-group $env:RESOURCE_GROUP --name $env:CONTAINER_REGISTRY --sku Basic

# Povolení přístupu k ACR skrze ARM token.
# https://learn.microsoft.com/en-us/azure/container-apps/tutorial-code-to-cloud
az acr config authentication-as-arm show --registry $env:CONTAINER_REGISTRY

# Vytvoření Azure Kubernetes Service (AKS), více informací na:
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview
# https://learn.microsoft.com/en-us/azure/aks/configure-dual-stack - pro ipv4 a ipv6 dual stack
# Přehled pro A - Entry-level economical, je na:
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/av2-series
# Standard_A4_v2 - 4 CPU, 8GB
# WARNING: Toto je třeba upravit: "node-count" "node-vm-size" a "location".
az aks create --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --node-count 2 --attach-acr $env:CONTAINER_REGISTRY --node-vm-size Standard_A4_v2 --location $env:LOCATION --ip-families ipv4,ipv6

# Přidání node s větší pamětí pro zpracování dat.
# Standard_A8_v2 - 8 CPU, 16GB
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2 --node-count 1 --node-vm-size Standard_A8_v2

# Umožni AKS přístup k ACR.
az aks update --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --attach-acr $env:CONTAINER_REGISTRY

# Výpis nodes a získání node pool name.
az aks nodepool list --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER -o table
```

## Nastavení kubeclt

```shell
# Konfigurace kubectl.
az aks get-credentials --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER
# Nastavení výchozího jmenného prostoru.
kubectl config set-context --current --namespace=nkd
# Následují příkaz by měl projít a vypsat uzly které tvoří do AKS.
kubectl get nodes
```

## Příprava konfigurace

Začneme vytvořením souboru `configuration.yaml` s obsahem dle následujícího předpisu.
Do předpisu je třeba doplnit Base64 zakódované hodnoty.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nkd
  labels:
    app.kubernetes.io/name: nkd
---
apiVersion: v1
kind: Secret
metadata:
  name: nkd-adapter-secret
  namespace: nkd
  labels:
    app.kubernetes.io/name: adapter
type: Opaque
data:
  #
  ms_application:
  #
  ms_tenant:
  #
  ms_secret:
  #
  ms_site:
  #
  ms_applications_list:
  #
  ms_applications_path:
  #
  ms_suggestions_list:
  #
  ms_allowed_publishers_list:
  # Uživatelské jméno pro přihlášení do ISDS.
  isds_login:
  # Helso pro přihlášení k ISDS.
  isds_password:
  # URL rozhraní datových schránek, e.g. https://ws1.czebox.cz/DS/ .
  isds_url:
---
apiVersion: v1
kind: Secret
metadata:
  name: nkd-couchdb-secret
  namespace: nkd
  labels:
    app.kubernetes.io/name: couchdb
type: Opaque
data:
  # Uživatelské jméno pro připojení k databáze s admin přístupem.
  couchdb_user:
  # Heslo pro výše uvedeného uživatele.
  couchdb_password:
---
apiVersion: v1
kind: Secret
metadata:
  name: nkd-graphql-secret
  namespace: nkd
  labels:
    app.kubernetes.io/name: graphql
type: Opaque
data:
  # Token pro reload data.
  graphql_reload_token:
  # Heslo pro SSH přístup.
  graphql_ssh_password:
---
apiVersion: v1
kind: Secret
metadata:
  name: nkd-ldf-secret
  namespace: nkd
  labels:
    app.kubernetes.io/name: graphql
type: Opaque
data:
  # Token pro reload data.
  ldf_reload_token:
  # Heslo pro SSH přístup.
  ldf_ssh_password:
---
apiVersion: v1
kind: Secret
metadata:
  name: nkd-virtuoso-ndc-secret
  namespace: nkd
data:
  # Heslo pro uživatele `dba`.
  virtuoso_dba_password:
  # Heslo pro uživatele `dva`.
  virtuoso_dva_password:
  # Heslo pro SSH přístup.
  virtuoso_ssh_password:
---
apiVersion: v1
kind: Secret
metadata:
  name: nkd-virtuoso-vocabulary-secret
  namespace: nkd
data:
  # Heslo pro uživatele `dba`.
  virtuoso_dba_password:
  # Heslo pro uživatele `dva`.
  virtuoso_dva_password:
  # Heslo pro SSH přístup.
  virtuoso_ssh_password:
```

Následně nahrajeme soubor do AKS clusteru pomocí následujícího příkazu spuštěného v adresáři se souborem.
```bash
kubectl apply -f configuration.yaml
```

## Sestavení a publikace Docker obrazů

Nasazení vyžaduje existenci Docker obrazů jednotlivých komponent.

### GitHub

Aktuálně jsou obrazy automaticky sestaveny a publikovány do GitHub repository pomocí GitHub Action.
Není tedy třeba provádět žádnou speciální akci.

### Azure Container Registry

Alternativní je publikace to Azure Container Registry (ACR).

Pomocí Azure portálu se můžeme podívat na obsah repositáře.
Z detailu `Container registry` otevřeme skupinu `Service` a dále vybereme `Repositories`.

Publikace je manuální pomocí vhodného otagování a následné publikace.
Příklad je uvedený v následujícím kusu kódu.
```shell
# Začneme přihlášením se do ACR.
az acr login --name $env:CONTAINER_REGISTRY}
# Solr
docker build -t "$env:CONTAINER_REGISTRY.azurecr.io/nkd-solr:develop" ./docker/solr/
docker push "$env:CONTAINER_REGISTRY.azurecr.io/nkd-solr:develop"
# ...
```

Výhodou použití ACR by mohla být lepší dostupnost a spolehlivost.

## Nasazení komponent národního katalogu
Pro nasazení do různých prostředí využijeme [Kustomize](https://kustomize.io/), jenž je součástí kubectl.

```shell
# Namespace potřebujeme pro secrets
kubectl apply -f ./azure-kubernetes-service/base/namespace.yaml
# Secrets a konfigurace
kubectl apply -f ./azure-kubernetes-service/secret/
# Nasazení z develop, pro produkční prostředí třeba změnit develop na production.
kubectl apply -k ./azure-kubernetes-service/overlays/develop
```

## Řešení ingress

Síťování je možné řešit různými způsoby.
Například:
- [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/)
  Bohužel nepodporuje češtinu v URL cestách.
- [Managed NGINX ingress with the application routing add-on](https://learn.microsoft.com/en-us/azure/aks/app-routing)

Další možností je využití Kubernetes service typu `LoadBalancer`, která může poskytnout externí přístup k vybrané službě.
Směrování je pak prováděno pomocí komponenty `gateway`.
To nám dává plnou a přenositelnou kontrolu.

### Pomocí Kubernetes service

Nejsnazší je přímé zpřístupnění komponenty vstupní brány pomocí služby.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nkd-gateway
  namespace: nkd
  labels:
    app.kubernetes.io/name: gateway
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: gateway
  externalTrafficPolicy: Cluster
  ipFamilyPolicy: PreferDualStack
  ipFamilies:
  - IPv4
  - IPv6
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
```

Následně nahrajeme soubor do AKS clusteru pomocí následujícího příkazu spuštěného v adresáři se souborem.
```bash
kubectl apply -f configuration.yaml
```

## Konfigurace po nasazení

Tato sekce popisuje jaké kroky je třeba provést po nasazení všech komponent.

### Úprava konfigurace úložiště

Použitá datová úložiště jsou poskytnuta automaticky.
Pokud dojde ke smazání Kubernetes zdrojů jsou i úložiště smazána.
Toto může vést ke ztrátě dat.

Řešením je úprava retailPolicy pro vybrané úložiště - persistent volumes.
Toho je možné dosáhnout následujícími kroky:

```shell
# Začneme získáním ID disků, pro které chceme upravit konfiguraci.
# Důležitá data jsou uložena na persistent volume claims:
# - nkd/nkd-adapter-pvc
# - nkd/nkd-public-pvc
# Ostatní data lze z těchto dat odvodit, či dopočítat.
# Cílem bude změna "RECLAIM POLICY".
kubectl get pv
# Změnu je možné provést následujícím příkazem, po nahrazení {NAME} za příslušné jméno.
# PowerShell vyžaduji jiné escapování pro JSON, příklad níže v komentáři.
kubectl patch pv {NAME} -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
#  kubectl patch pv {NAME} -p '{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Retain\"}}'
# Následně ověříme změnu ve sloupci "RECLAIM POLICY" z "Delete" na "Retain".
```

### Migrace dat

TODO

Kopírování souborů z a do clusteru:
```shell
# Příklad zkopírování lokálního souboru do POD.
kubectl cp 2025-11-12.zip {pod-name}:/{directory-path} -c {container-name}
```
Dokumentace k příkazu [kubectl cp](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cp/).

### LinkedPipes:ETL

Po nasazení je třeba provést úpravy v LinkedPipes:ETL.

Podle nasazení je třeba upravit následující v LinkedPipes:ETL:
- Šablona `Frontend prefix pro kvalitu` obsahuje prefix k souborům s kvalitou.

## Konvence

TODO

## Řešení problémů při nasazení

### Chybová hláška: Couldn't get current server API
Přístup k API může být omezený na vybrané IP adresy pomocí `authorizedIpRanges`.
Nastavení je možné upravit na [Home](https://portal.azure.com/#home):
- "Kubernetes service"
- Vybereme odpovídající službu
- "Settings"
- "Networking"
- Na stránce najdeme "Authorized IP ranges"

## Údržba a provoz

### Přístup k LinkedPipes:ETL

Pro připojení k LinkedPipes ETL je tedy využít následující příkaz:
```shell
kubectl port-forward service/nkd-linkedpipes-etl 8080:8080
```
Po jeho spuštění bude frontend dostupný na lokálním portu 8080.

Dále je možné využít SSH připojení přímo do docker kontejneru.
V případě více kontejnerů je možné si vybrat následovně:
```shell
kubectl exec -it pod/{pod-name} -c {container} -- /bin/bash
```

Jméno podu je možné získat v výstupu příkazu:
```shell
kubectl get pods
```

Jméno kontejneru pak odpovídá definic deploymentu.
Alternativně je možné kontejner neuvést a příkaz pak vypíše dostupné možnosti.

### Manuální spuštění harvestace a synchronizace

Manuální spuštění je možné provést skrze container `nkd-orchestrator`.
```shell
# Nejprve zjistíme pod, ve kterém běží LinkedPipes:ETL.
# Jeho název bude začínat na "nkd-linkedpipes-etl-deployment-"
kubectl get pods
# Následně se připojíme do kontejneru.
kubectl exec -it pod/{pod-name} -c nkd-orchestrator -- /bin/bash
```

V kontejneru jsou následující skripty, které můžeme spustit:
- `/opt/entrypoint/execute.sh`
  Spustí vstupní pipeline pro harvestaci.
- `/opt/entrypoint/synchronize.sh`
  Synchronizuje lokální instanci LinkedPipes:ETL s Git repositářem.
  Tato operace přepíše lokální změny.
