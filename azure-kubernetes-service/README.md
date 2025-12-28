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

Všechny níže uvedené příkazy předpokládají nastavení následujících proměnných prostředí:
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

Než budeme v nasazování pokračovat je třeba vytvořit odpovídají Azure prostředí.
To zahrnuje zejména Azure Kubernetes Service (AKS).
V rámci této tvorby se definují z jakých strojů bude cluster sestaven a tedy jaké výpočetní kapacity budou k dispozici.

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

# Přidání node s větší pamětí.
# Standard_A8_v2 - 8 CPU, 16GB
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2 --node-count 2 --node-vm-size Standard_A8_v2

# Umožni AKS přístup k ACR.
az aks update --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --attach-acr $env:CONTAINER_REGISTRY

# Výpis nodes a získání node pool name.
az aks nodepool list --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER -o table
```

## Nastavení kubeclt

Nastavení kubectl je možné provést až po vytvoření AKS klasteru.
Dále je třeba být přihlášený do Azure CLI.

```shell
# Konfigurace kubectl.
az aks get-credentials --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER
# Nastavení výchozího jmenného prostoru.
kubectl config set-context --current --namespace=nkd
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
Není tedy třeba provádět žádnou speciální akci.

### Azure Container Registry

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

Výhodou použití ACR by mohla být lepší dostupnost a spolehlivost.
V případě přechodu na ACR, je třeba upravit názvy Docker obrazů v YAML definicích pro AKS.

## Příprava konfigurace

Než provedeme nasazení do AKS je třeba připravit konfiguraci.
Šablona potřebné konfigurace je umístěna v adresáři `./azure-kubernetes-service/configuration/`.

Začneme zkopírováním celého adresáře a navigací do něj.
```shell
cp -r ./azure-kubernetes-service/configuration/ ../.develop/
cd ../.develop/
```

Následně je nutné upravit YAML soubor `configuration.yaml`.
Položky označené jako `[ENCODED]` být base64 zakódovaná.
Jakmile je konfigurace připravena můžeme jí nahrát do AKS.
```bash
kubectl apply -f ./configuration.yaml
```

Další krok předpokládá existenci následujících souborů certifikátů pro přístup skrze HTTPS v současném adresáři.
- `./ofn.portal.chain.pem`
- `./ofn.portal.key.pem`
- `./data.portal.chain.pem`
- `./data.portal.key.pem`

```bash
kubectl create secret tls nkd-ofn-tls --namespace=nkd --cert=./ofn.portal.chain.pem --key=./ofn.portal.key.pem
kubectl create secret tls nkd-data-tls --namespace=nkd --cert=./data.portal.chain.pem --key=./data.portal.key.pem

kubectl create configmap nkd-https --namespace=nkd --from-file=ofn_portal_domain_chain=./ofn.portal.chain.pem --from-file=ofn_portal_domain_key=./ofn.portal.key.pem --from-file=data_portal_domain_chain=./data.portal.chain.pem --from-file=data_portal_domain_key=./data.portal.key.pem
```

Následně se můžeme vrátit do kořene repositáře.
```bash
cd ../azure-kubernetes-service/
```

## Nasazení komponent národního katalogu

Pro nasazení do různých prostředí využijeme [Kustomize](https://kustomize.io/), jenž je součástí kubectl.

Pro nastavené do testovacího a produkčního prostředí použijeme příkaz:
```shell
kubectl apply -k ./azure-kubernetes-service/overlays/production
```

Pro nasazení na vývojové prostředí použijeme příkaz:
```shell
kubectl apply -k ./azure-kubernetes-service/overlays/develop
```

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

## Konfigurace po nasazení

Tato sekce popisuje jaké kroky je třeba provést po nasazení komponent do AKS.
Tyto úpravy je nutné provést před první harvestací.

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
kubectl patch pv <NAME> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
#  kubectl patch pv <NAME> -p '{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Retain\"}}'
# Následně ověříme změnu ve sloupci "RECLAIM POLICY" z "Delete" na "Retain".
```

### LinkedPipes:ETL

Po nasazení je třeba provést úpravy v LinkedPipes:ETL.

Podle nasazení je třeba upravit následující v LinkedPipes:ETL:
- Šablona `Frontend prefix pro kvalitu` obsahuje prefix k souborům s kvalitou.

### Vytvoření historických dat

Pipeline 07.1 předpokládá existenci souboru `/data/public/soubor/nkod.trig`.
Tento soubor je třeba vytvořit před prvním spuštěním běhu pipeliny.

Soubor je možné vytvořit po připojení se do Docker containeru.
Připojení je možné pomocí následujícího příkazu:
```shell
# Vrátí seznam všech podů.
# Je třeba najít název podu začínající na nkd-linkedpipes-etl-*
kubectl get pods
# Spuštění procesu v podu a připojení k němu.
kubectl exec -it {nkd-linkedpipes-etl-NAME} -c nkd-linkedpipes-etl-executor -- /bin/bash
# Vytvoření prázdného souboru.
touch /data/public/soubor/nkod.trig
# Opuštění podu
exit
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

### Promazání K8S podů

```shell
kubectl delete pod --field-selector="status.phase==Failed"
```

### Změna velikosti nodepool

Příklad změny počtů strojů v nodepool.
Pokud by bylo třeba více prostředků, než může jeden node nabídnout, je třeba vytvořit novou skupinu s většími stroji.

```bash
az aks nodepool scale --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2 --node-count 2
```
