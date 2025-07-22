# Nasazení do prostředí Azure Kubernetes Service (AKS)

## Požadavky

Pro spuštění níže uvedených příkazů je třeba mít nainstalováno:
- `kubectl`, verze by měla odpovídat AKS.
  [Postup instalace](https://kubernetes.io/docs/tasks/tools/).
- `az`, Azure CLI
  [Postup instalace](https://learn.microsoft.com/cs-cz/cli/azure/install-azure-cli?view=azure-cli-latest).
- `powershell`

## Příprava prostředí powershell

Všechny níže uvedené příkazy předpokládají:
- Spuštění v kořeni tohoto adresáře.
- Nastavení následujících proměnných prostředí:
  ```shell
  $env:SUBSCRIPTION=
  $env:RESOURCE_GROUP=
  $env:AKS_CLUSTER=
  $env:CONTAINER_REGISTRY=
  ```

## Nastavení az

```shell
# Přihlásíme se do Azure, je třeba vybrat správnou "subscription".
az login
# "subscription" je možné změnit pomocí následujícího příkazu.
az account set --subscription $env:SUBSCRIPTION
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
# Toto je třeba upravit: "node-count" "node-vm-size" a "location".
az aks create --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --node-count 2 --attach-acr $env:CONTAINER_REGISTRY --node-vm-size Standard_A4_v2 --location northeurope

# Umožni AKS přístup k ACR.
az aks update --resource-group $env:RESOURCE_GROUP --name $env:AKS_CLUSTER --attach-acr $env:CONTAINER_REGISTRY
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
