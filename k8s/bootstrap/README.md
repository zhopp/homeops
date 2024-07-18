# Bootstrap

## Flux

### Install Flux

```sh
kubectl apply --server-side --kustomize ./k8s/bootstrap/flux
```

### Apply Cluster Configuration

_These cannot be applied with `kubectl` in the regular fashion due to be encrypted with sops_

```sh
sops --decrypt k8s/bootstrap/flux/secret-age-key.sops.yaml | kubectl apply -f -
sops --decrypt k8s/flux/vars/cluster-secrets.sops.yaml | kubectl apply -f -
kubectl apply --server-side -f k8s/flux/vars/cluster-settings.yaml
```

### Kick off Flux applying this repository

```sh
kubectl apply --server-side --kustomize ./k8s/flux/config
```
