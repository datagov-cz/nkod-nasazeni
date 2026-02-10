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

Pro úspěšné nasazení je dále třeba mít připravené:
- Certifikáty pro domény

## Příprava GitLab repositářů s obsahem pro portál

Pro automatickou synchronizaci obsahu s GitHub repositářem je třeba vytvořit webhook na následující adresy.
- `/api/v2/portal-data-gov-cz/reload`
  Obsah repositáře bude dostupný na datovém portálu.
- `/api/v2/portal-ofn-data-gov-cz/reload`
  Obsah bude dostupný na ofn portálu.

Jako `Content type` je třeba zvolit `application/json`.
Pro `Which events would you like to trigger this webhook?` zvolte `Just the push event.`.

Při tvorbě si zapište `secret`, budou třeba v sekci [Konfigurace a nasazení komponent národního katalogu](#k8s-component-deployment).

## Příprava prostředí powershell

Všechny níže uvedené příkazy předpokládají nastavení následujících proměnných prostředí:
```shell
$env:SUBSCRIPTION=
$env:RESOURCE_GROUP=
$env:AKS_CLUSTER="nkd-kubernetes"
$env:CONTAINER_REGISTRY="nkdcontainerregistry"
$env:LOCATION="northeurope"
# Jedna z hodnot "develop", "test", "production".
# Volba hodnoty ovlivní výchozí nastavení zdrojů.
$env:ENVIRONMENT=
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

Než budeme v nasazování pokračovat je třeba vytvořit odpovídají Azure prostředí.
To zahrnuje zejména Azure Kubernetes Service (AKS).
V rámci této tvorby se definují z jakých strojů bude cluster sestaven a tedy jaké výpočetní kapacity budou k dispozici.

### Volitelný krok: [Vytvoření Azure Container Registry (ACR)](#vytvoření-acr)

Tento krok je volitelný.
Azure Container Registry (ACR) lze použít pro uložení Docker images v rámci prostředí azure.
Název je použitý pro určení DNS jako `{name}.azurecr.io` a musí být unikátní pro celý Azure.

```shell
# Založení Azure Container Registry (ACR).
# Můžeme získávat images také z jiného místa, ale tady bude lepší dostupnost.
az acr create --resource-group $env:RESOURCE_GROUP --name $env:CONTAINER_REGISTRY --sku Basic

# Povolení přístupu k ACR skrze ARM token.
# https://learn.microsoft.com/en-us/azure/container-apps/tutorial-code-to-cloud
az acr config authentication-as-arm show --registry $env:CONTAINER_REGISTRY
```

### Vytvoření Kubernetes clusteru

```shell
# Vytvoření Azure Kubernetes Service (AKS), více informací na:
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview
# https://learn.microsoft.com/en-us/azure/aks/configure-dual-stack - pro ipv4 a ipv6 dual stack
# Přehled pro A - Entry-level economical, je na:
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/av2-series

# Standard_A2_v2 - 2 CPU, 4GB
az aks create --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --node-count 2 --node-vm-size Standard_A2_v2 --location $env:LOCATION --ip-families ipv4,ipv6

# Standard_A8_v2 - 8 CPU, 16GB
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2 --node-count 2 --node-vm-size Standard_A8_v2

# Výpis nodes a získání node pool name.
az aks nodepool list --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER -o table
```

*Volitelný krok:* Pokud existuje [ACR](#vytvoření-acr), je možná poskytnout AKS přístup pomocí následujícího příkazu.
Tento krok je potřeba pouze, pokud je v plánu použít ACR jako úložiště pro Docker images.
```shell
# Umožni AKS přístup k ACR.
az aks update --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --attach-acr $env:CONTAINER_REGISTRY
```

## Nastavení kubeclt

Nastavení kubectl je možné provést až po vytvoření AKS klasteru.
Dále je třeba být přihlášený do Azure CLI.

```shell
# Konfigurace kubectl.
az aks get-credentials --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --context "$env:AKS_CLUSTER-$env:ENVIRONMENT"
# Nastavení výchozího jmenného prostoru.
kubectl config set-context --current --context "$env:AKS_CLUSTER-$env:ENVIRONMENT" --namespace=nkd
# Následují příkaz by měl projít a vypsat uzly které tvoří AKS.
kubectl get nodes
```

## Naklonování repositáře

Pro další kroky předpokládají, že jsme v kořeni lokální kopie tohoto repositáře.
Toho je možné dosáhnout následujícími příkazy:

```shell
git clone https://github.com/datagov-cz/nkod-nasazeni.git
cd nkod-nasazeni
```

## Sestavení a publikace Docker obrazů

Nasazení vyžaduje existenci Docker obrazů jednotlivých komponent.

### GitHub

Aktuálně jsou obrazy automaticky sestaveny a publikovány na GitHub pomocí GitHub Action.
Není tedy třeba provádět žádnou akci.

### Volitelný krok: Azure Container Registry

Alternativní je publikace to Azure Container Registry (ACR).

Pomocí Azure portálu se můžeme podívat na obsah repositáře.
Z detailu `Container registry` otevřeme skupinu `Service` a dále vybereme `Repositories`.

Publikace je manuální pomocí vhodného tagování a následné publikace do ACR.
Příklad je uvedený v následujícím kusu kódu.
```shell
# Začneme přihlášením se do ACR.
az acr login --name $env:CONTAINER_REGISTRY
# Příklad přetagování a publikace komponenty obrazu nkd-solr.
docker build -t "$env:CONTAINER_REGISTRY.azurecr.io/nkd-solr:develop" ./docker/solr/
docker push "$env:CONTAINER_REGISTRY.azurecr.io/nkd-solr:develop"
# ...
```

Výhodou použití ACR je lepší dostupnost a spolehlivost.
V případě přechodu na ACR, je třeba upravit názvy Docker obrazů v YAML definicích pro AKS.

## Získání veřejné IP adresy

Statická IP adresa musí být vytvořena skrze Azure v resource group ve které je Kubernetes.
Smazáním kubernetes clusteru tato grupa zaniká, čímž také zanikne statická adresa.
Nejprve tedy musíme získat název resource group a následně v ní vytvořit veřejnou ip adresu.

```shell
# Získání názvu resource group.
$env:K8S_RESOURCE_GROUP = (az aks show --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --query nodeResourceGroup -o tsv)
# Vytvoření veřejné IPv4 a IPv6.
az network public-ip create --resource-group $env:K8S_RESOURCE_GROUP --name gateway-public-ipv4 --sku Standard --allocation-method Static --version IPv4 --zone 1 2 3
az network public-ip create --resource-group $env:K8S_RESOURCE_GROUP --name gateway-public-ipv6 --sku Standard --allocation-method Static --version IPv6 --zone 1 2 3
# V posledním kroku přípravy získáme IP adresy, které budeme potřebovat později.
$env:K8S_IPV4 = (az network public-ip show --resource-group $env:K8S_RESOURCE_GROUP --name gateway-public-ipv4 --query ipAddress --output tsv)
$env:K8S_IPV6 = (az network public-ip show --resource-group $env:K8S_RESOURCE_GROUP --name gateway-public-ipv6 --query ipAddress --output tsv)
# Zobrazení IP adres, relevantní jsou řádky pro gateway-public-ipv4 a gateway-public-ipv6.
az network public-ip list --resource-group $env:K8S_RESOURCE_GROUP -o table
```

Získané hodnoty použijeme v sekci [Nasazení komponent národního katalogu](#k8s-component-deployment).

## [Konfigurace a nasazení komponent národního katalogu](#k8s-component-deployment)

Než provedeme nasazení do AKS je třeba připravit konfiguraci.
Začneme tedy zkopírováním celého adresáře s konfigurací, navigací do něj a aplikací konfigurace uložené v proměnných prostředí.
```shell
cp -r ./azure-kubernetes-service/configuration/ ./azure-kubernetes-service/.$env:ENVIRONMENT/
cd ./azure-kubernetes-service/.$env:ENVIRONMENT/
# Úprava souborů pomocí proměnných prostředí.
(Get-Content ./kustomization.yaml -raw ) –f $env:ENVIRONMENT | Set-Content ./kustomization.yaml
(Get-Content ./gateway-ingress.yaml -raw ) –f $env:K8S_RESOURCE_GROUP, $env:K8S_IPV4, $env:K8S_IPV6  | Set-Content ./gateway-ingress.yaml
```
Následně je nutné ručně upravit YAML soubor `configuration.yaml`.
Položky označené jako `[ENCODED]` být base64 zakódovaná.

V tuto chvílí máme připravené vše pro nasazení.
Pro nasazení využijeme [Kustomize](https://kustomize.io/), jenž je součástí kubectl.
Nasazení provedeme následujícím příkazem.
```bash
kubectl apply -k .
```

Další krok předpokládá existenci následujících souborů certifikátů pro přístup skrze HTTPS v současném adresáři.
- `./https/ofn.portal.chain.pem`
- `./https/ofn.portal.key.pem`
- `./https/data.portal.chain.pem`
- `./https/data.portal.key.pem`

```bash
kubectl create secret tls nkd-ofn-tls --namespace=nkd --cert=./https/ofn.portal.chain.pem --key=./https/ofn.portal.key.pem
kubectl create secret tls nkd-data-tls --namespace=nkd --cert=./https/data.portal.chain.pem --key=./https/data.portal.key.pem
```

Dále je třeba připravit konfiguraci pro LinkedPipes:ETL.
Ta se skládá ze souborů `lp-etl-configuration.ttl` a `./lp-etl-crontab`.
První soubor je dostupný v LP-ETL pipelines, druhý slouží pro plánování spouštění pipelines.
Při editaci `./lp-etl-crontab` je třeba pamatovat, že se jedná o čas na serveru, nikoliv nutně lokální čas.
Jakmile je soubor připraven vytvoříme Kubernetes resource následujícím příkazem:

```bash
kubectl create configmap nkd-linkedpipes-etl --from-file=lp-etl-configuration.ttl=./lp-etl-configuration.ttl --from-file=lp-etl-crontab=./lp-etl-crontab
```

Následně se můžeme vrátit do kořene repositáře.
```bash
cd ../../
```

## Konfigurace po nasazení

Tato sekce popisuje jaké kroky je třeba provést po nasazení komponent do AKS.
Tyto úpravy je nutné provést před první harvestací.

### Úprava konfigurace úložiště

Použitá datová úložiště, neboli persistent volumes, jsou poskytnuta automaticky.
Pokud dojde ke smazání Kubernetes zdrojů, která tyto úložiště používají, jsou daná úložiště smazána.
Toto může vést ke ztrátě dat.

Důležitá data jsou uložena na persistent volume claims:
- `nkd/nkd-adapter-pvc`
- `nkd/nkd-public-pvc`

Řešením je úprava `retailPolicy` pro vybrané úložiště.
Toho je možné dosáhnout následujícími kroky:
```shell
$env:ADAPTER_PV=(kubectl get pvc nkd-adapter-pvc -o jsonpath='{.spec.volumeName}')
$env:PUBLIC_PV=(kubectl get pvc nkd-public-pvc -o jsonpath='{.spec.volumeName}')

# PowerShell vyžaduje speciální pro JSON.
kubectl patch pv $env:ADAPTER_PV -p '{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Retain\"}}'
kubectl patch pv $env:PUBLIC_PV -p '{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Retain\"}}'

# Následně ověříme změnu ve sloupci "RECLAIM POLICY" z "Delete" na "Retain".
kubectl get pv
```

### Migrace registračních záznamů

Po nasazení je třeba do clusteru dodat vstupní data.
Jedná se zejména o statické soubory a dále pak registrační záznamy.
Pro kopírování souborů lze využít příkazu [kubectl cp](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cp/).

Začneme zkopírováním registračních záznamů.

```shell
# Nejprve je třeba získat název PODu do kterého budeme chtít záznamy kopírovat.
kubectl get pods --selector=app.kubernetes.io/name=adapter

# Příklad zkopírování lokálního souboru do POD.
# Příkaz je možné použít i pro kopírování obsahu celého adresář.
kubectl cp {archiv-s-registračními-záznamy} {pod-name}:/tmp

# Připojení k docker image.
kubectl exec -it {pod-name} -- bash
```

Následně je třeba souboru přesunout do adresářů
- `/data/adapter/registrations/messages`
- `/data/adapter/registrations/attachments`

Relaci k kontejneru je pak možné ukončit pomocí příkazu `exit`.

## Řešení problémů při nasazení

### Chybová hláška: Couldn't get current server API
Přístup k API může být omezený na vybrané IP adresy pomocí `authorizedIpRanges`.
Nastavení je možné upravit na [Home](https://portal.azure.com/#home):
- "Kubernetes service"
- Vybereme odpovídající službu
- "Settings"
- "Networking"
- Na stránce najdeme "Authorized IP ranges"

# Údržba a provoz

## [Přístup k LinkedPipes:ETL](#linkedpipes-etl-access)

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
kubectl get pods --selector=app.kubernetes.io/name=linkedpipes-etl
```

Jméno kontejneru pak odpovídá definic deploymentu.
Alternativně je možné kontejner neuvést a příkaz pak vypíše dostupné možnosti.

## Manuální spuštění harvestace a synchronizace

Manuální spuštění je možné provést skrze container `nkd-orchestrator`.
```shell
# Nejprve zjistíme pod, ve kterém běží LinkedPipes:ETL.
# Jeho název bude začínat na "nkd-linkedpipes-etl-deployment-"
kubectl get pods
# Následně se připojíme do kontejneru.
kubectl exec -it pod/{pod-name} -c nkd-orchestrator -- /bin/bash
```

V kontejneru jsou následující skripty, které můžeme spustit:
- `su nkod /opt/orchestrator/execute-pipeline.sh {url-pipeline-ke-spuštění}`
  Spustí vstupní pipeline pro harvestaci.
- `su nkod /opt/orchestrator/synchronize-storage.sh`
  Synchronizuje lokální instanci LinkedPipes:ETL s Git repositářem.
  Tato operace přepíše lokální změny.

## Promazání K8S podů

```shell
kubectl delete pod --field-selector="status.phase==Failed"
```

## Změna velikosti nodepool

Příklad změny počtů strojů v nodepool.
Pokud by bylo třeba více prostředků, než může jeden node nabídnout, je třeba vytvořit novou skupinu s většími stroji.

```bash
az aks nodepool scale --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2 --node-count 2
```

## [Archivace dat](#archivace-dat)

## [Zrušení prostředí](#zrušení-prostředí)

Před pokračováním v této sekci se ujistěte, že jste provedli [Archivaci dat](archivace-dat).

Zdroje v AKS je možné smazat následujícím příkazem.
```shell
kubectl delete namespace nkd
```

Samotné AKS je pak možné smazat následovně.
*POZOR*: Smazáním AKS dojde i ke smazání veřejných IP adres.
```shell
az aks delete --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER
```

# Vývojářská dokumentace

Tato sekce obsahuje poznámky k vývoji nasazení do AKS.

## Řešení ingress a přístup k národnímu katalogu

Síťování je možné řešit různými způsoby.
Například:
- [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/)
  Bohužel nepodporuje češtinu v URL cestách.
- [Managed NGINX ingress with the application routing add-on](https://learn.microsoft.com/en-us/azure/aks/app-routing)

Další možností je využití Kubernetes service typu `LoadBalancer`, která může poskytnout externí přístup k vybrané službě.
Směrování je pak prováděno pomocí komponenty `gateway`.
To nám dává plnou a přenositelnou kontrolu.
Toto řešení je zvoleno jako výchozí, pro nasazení do AKS a je nasazeno spolu s ostatními komponentami.

Následující příkaz ukazuje, jak je možné získat externí IP, na kterých služba poslouchá a je možné na ně směrovat DNS.
```shell
# Zobrazení informací o službě.
# Ve sloupci EXTERNAL-IP je uvedena veřejná IPv4 a IPv6 adresa.
kubectl get service/nkd-gateway
```


