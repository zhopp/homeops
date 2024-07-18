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

If this is your first time installing Talos, follow the below steps:
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


If you're enabling the tailscale extension and are not using the authkey:

Ensure you grab the tailscale login url:
```
talosctl -n 192.168.4.10 logs ext-tailscale
```

## Installing apps

Follow the README located [here](./k8s/bootstrap/README.md)

## Updates

if you need to make a change to your talos config run `talhelper genconfig` to generate a
new config with your added changes then run `apply.sh` to apply them

## Resetting your nodes

Reboot your nodes, and interrupt the boot squence to set the nodes into maintenance mode. After that, follow the steps from `Create Talos Secrets` onward.
