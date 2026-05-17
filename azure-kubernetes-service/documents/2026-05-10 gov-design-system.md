# gov-design-system

We used to store gov-design-system using PVC.
Now we just host an image with all the content in it.
As a result, the PVC is no longer needed s o we can remove it.

```sh
kubectl delete pvc nkd-design-system-pvc
```
