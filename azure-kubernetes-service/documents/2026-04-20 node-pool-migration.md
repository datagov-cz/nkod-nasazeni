# Migration of `nodepool1`,  `nodepool2`, `nodepool3`, `nodepool4`

Initially the cluster run using `Standard_A2_v2` machines, mostly used as they are an entry level machines.
Yet, for production use we need more computation power.
The `D` series provides better performance for a similar price.

```sh
# List node pools.
az aks nodepool list --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER -o table

# Standard_D2as_v5 - 2 vCPU, 8B RAM
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name system --node-count 3 --node-vm-size Standard_D2as_v5 --mode System

# Standard_D4as_v5 - 4 vCPU, 16GB RAM
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name user1 --node-count 1 --node-vm-size Standard_D4as_v5

# Standard_D8as_v5 - 8 vCPU, 32GB RAM - only for virtuoso.
az aks nodepool add --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name virtuoso --node-count 1 --node-vm-size Standard_D8as_v5
kubectl taint nodes virtuoso dedicated=virtuoso:NoSchedule

# Remove previous pools.
kubectl drain --ignore-daemonsets --delete-emptydir-data $(kubectl get nodes -l agentpool=nodepool1 -o name)
az aks nodepool delete --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool1

kubectl drain --ignore-daemonsets --delete-emptydir-data $(kubectl get nodes -l agentpool=nodepool2 -o name)
az aks nodepool delete --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool2

kubectl drain --ignore-daemonsets --delete-emptydir-data $(kubectl get nodes -l agentpool=nodepool3 -o name)
az aks nodepool delete --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool3

kubectl drain --ignore-daemonsets --delete-emptydir-data $(kubectl get nodes -l agentpool=nodepool4 -o name)
az aks nodepool delete --resource-group $env:RESOURCE_GROUP --cluster-name $env:AKS_CLUSTER --name nodepool4
```
