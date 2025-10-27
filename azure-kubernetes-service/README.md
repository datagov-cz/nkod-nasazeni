# Nasazení do prostředí Azure Kubernetes Service (AKS)

## Konfigurace

### LinkedPipes:ETL

Podle nasazení je třeba upravit následující:
- Šablona `Frontend prefix pro kvalitu` obsahuje prefix k souborům s kvalitou.

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
  $env:AKS_CLUSTER="nkod-kubernetes"
  $env:CONTAINER_REGISTRY="nkodcontainerregistry"
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
# Můžeme získávat images i z jiného místa, ale tady bude asi lepší dostupnost.
az acr create --resource-group $env:RESOURCE_GROUP --name $env:CONTAINER_REGISTRY --sku Basic

# Povolení přístupu k ACR skrze ARM token.
# https://learn.microsoft.com/en-us/azure/container-apps/tutorial-code-to-cloud
az acr config authentication-as-arm show --registry $env:CONTAINER_REGISTRY

# Vytvoření Azure Kubernetes Service (AKS), více informací na:
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview
# Přehled pro A - Entry-level economical, je na:
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/av2-series
# Standard_A4_v2 - 4 CPU, 8GB
# WARNING: Toto je třeba upravit: "node-count" "node-vm-size" a "location".
az aks create --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool1  --node-count 2 --attach-acr $env:CONTAINER_REGISTRY --node-vm-size Standard_A4_v2 --location northeurope

# Přidání node s větší pamětí pro zpracování dat.
# Standard_A8_v2 - 8 CPU, 16GB
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2 --node-count 1 --node-vm-size Standard_A8_v2

# Umožni AKS přístup k ACR.
az aks update --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --attach-acr $env:CONTAINER_REGISTRY

# Výpis nodes a získání node pool name.
az aks nodepool list --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER -o table
```

## Nastavení kubeclt

```shell
# Konfigurace kubectl.
az aks get-credentials --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER
# Nastavení výchozího jmenného prostoru.
kubectl config set-context --current --namespace=nkod
# Následují příkaz by měl projít a vypsat uzly které tvoří do AKS.
kubectl get nodes
```

## Nasazení NginX jako řešení pro ingress

### Ingress-Nginx Controller

Využijeme [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/).
```shell
# Nasazení ingress kontroleru.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.3/deploy/static/provider/cloud/deploy.yaml
# Zkontrolujeme, že je vše nasazeno a běží jak má.
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
# Získáme veřejnou IP adresu je možné získat následujícím příkazem:
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```

### Managed NGINX ingress

Alternativně je možné využít Azure spravovaný NginX ingress.

Zdroje:
- [Managed NGINX ingress with the application routing add-on](https://learn.microsoft.com/en-us/azure/aks/app-routing).
- [Application routing add-on for AKS training](https://github.com/sabbour/app-routing-tutorial)

## Sestavení a publikace Docker obrazů

Pomocí Azure portálu se můžeme podívat na obsah repositáře.
Z detailu Container registry otevřeme skupinu "Service" a dále vybereme "Repositories".

```shell
# Začneme přihlášením se do ACR.
az acr login --name $env:CONTAINER_REGISTRY
# Solr
docker build -t "$env:CONTAINER_REGISTRY.azurecr.io/solr:develop" ./docker/solr/
docker push "$env:CONTAINER_REGISTRY.azurecr.io/solr:develop"
# ...
```

## Nasazení komponent národního katalogu
Pro nasazení do různých prostředí využijeme [Kustomize](https://kustomize.io/), jenž je součástí kubectl.

```shell
# Namespace potřebujeme pro secrets
kubectl apply -f ./azure-kubernetes-service/base/namespace.yaml
# Secrets a konfigurace
kubectl apply -f ./azure-kubernetes-service/secret/
# Komponenty

kubectl apply -k ./azure-kubernetes-service/overlays/develop

```

## Konvence

...

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

### Nastavení přístupu

Pro přístup je nutné mít nastavené příkazy [az](#nastavení-az) a [kubeclt](#nastavení-kubeclt).

### Přístup k podům

Připojení k běžícímu podu pomocí příkazové řádky:
```shell
kubectl exec -it pod/{pod-name} -- /bin/bash
```

V případě více kontejnerů je možné si vybrat následovně:
```shell
kubectl exec -it pod/{pod-name} -c {container} -- /bin/bash
```

Přístup na porty:
```shell
kubectl port-forward {resource-type}/{resource-name} {local-port}:{pod-port}
```
Obdobné příkazy je možné použít i pro Deployment a Service.
[Zdroj](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_port-forward/)

Pro připojení k LinkedPipes ETL je tedy možné využít následující příkaz:
```shell
kubectl port-forward service/nkod-linkedpipes-etl 8080:8080
```
