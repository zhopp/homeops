# Welcome to my K8s Home Lab

## Installation/Configuration Instructions
### Prequisites

* You will need the following tools installed:
  - sops
  - direnv
  - talhelper
  - talosctl
  - kubectl
  - kustomize
  - helm

* You also need sops to be configured with your preferred encryption tool (age, pgp, etc).
### example install
```sh
     brew install sops talhelper siderolabs/talos/talosctl kustomize kubectl helm
```

## SOPS using age
### Quick start
```sh
     mkdir -p ~/.config/sops/age
     age-keygen -o ~/.config/sops/age/keys.txt
```

Ensure `direnv allow` has been ran in your directory, and ensure `export SOPS_AGE_RECIPIENTS="$HOME/.config/sops/age/keys.txt"` is in your .envrc file

Configure your `.sops.yaml` with your age public key as such:

```yaml
creation_rules:
  - path_regex: .*\.sops\.yaml
    key_groups:
      - age:
        - YOUR_PUBLIC_AGE_KEY
```

## Create Env File (optional)
an optional env file can be created to store variables that can be subsituted in
the talconfig.yaml on manifest generation

If these envs are secret, ensure that they are encrypted via SOPS

```
touch talenv.sops.yaml
sops -e -i talenv.sops.yaml
```

Make sure direnv is installed, and that you run a direnv allow to enable the env vars to be loaded when entering the directory in your shell

## Create Talos Secrets

Per cluster, only run gensecret once.

```
talhelper gensecret > talsecret.sops.yaml
sops -e -i talsecret.sops.yaml
```

*Generating secrets will overwrite all of the keys and there's no way to recover from it. This will brick the cluster*

## Create Talos Config
create a talconfig.yaml file following the documentation at https://budimanjojo.github.io/talhelper/latest/

After you have configured your talconfig, generate your configurations

```sh
talhelper genconfig
```

download the ISO that matches your talconfig setings:
```sh
talhelper genurl iso | xargs wget -P ~/Downloads
```

Flash a usb stick with that ISO image. This will be used to install Talos on the bare metal machine
Boot from USB and Talos will install on the device

## Boostrap
* load the Talos image onto a usb and boot your device from it
* either statically set ip addresses or use DHCP reservations to obtain
  an IP address
* Run bootstrap script, this configures the nodes, bootstraps the nodes, and runs the `deploy-integrations.sh` script that installs the Cilium and the CSR approver
```
./bootstrap.sh
```

Once this is complete, run a `k apply -k ./` at the top level to deploy your applications and to have flux take over control of the resources in the system directory

If you're connecting to the tailscale network:

Ensure you grab the tailscale login url:
```
talosctl -n 192.168.4.10 logs ext-tailscale
```

If you have an Nvidia GPU, you can run this to test if the NVIDIA drivers are working:
```sh
kubectl run \
  nvidia-test \
  --restart=Never \
  -ti --rm \
  --image nvcr.io/nvidia/cuda:12.1.0-base-ubuntu22.04 \
  --overrides '{"spec": {"runtimeClassName": "nvidia"}}' \
  nvidia-smi
```

## Installing apps

Apps are added via the the `apps` directory. The "core" apps will be deployed via DoD P1's big-bang offering (https://repo1.dso.mil/big-bang/bigbang):

This is a helm chart of charts that deploys applications and services in an opinonaited way, with a general focus of security and sensible secure defaults.

The flux configuration files will be grabbed from the Big Bang repo as well (https://repo1.dso.mil/big-bang/bigbang/-/tree/2.31.0/base/flux?ref_type=tags).

## Updates

if you need to make a change to your talos config run `talhelper genconfig` to generate a
new config with your added changes then run `apply.sh` to apply them

## Shutdown
`tctl shutdown -n X.X.X.X --force`

### Connecting to remote clusters on tailscale

You have genereated the `talosconfig` file in the `clusterconfig` directory above. You will need to update the endpoint and the node config via a couple commands to match the talos hostname that will be availabe via the tailscale network:

```sh
talosctl config node $CLUSTER_NAME
talosctl config endpoint $CLUSTER_NAME
```

After that, generate your kubeconfig which will automatically update your context:

```sh
talosctl kubeconfig
```

Once you have done that, you can connect to the cluster via any typical way (k9s, etc)
