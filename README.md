# Welcome to my K8s Home Lab

## Installation/Configuration Instructions
### Prequisites

You will need the following tools installed:
  - sops
  - direnv
  - talhelper
  - talosctl
  - kubectl
  - kustomize
  - helm
  - task

You also need sops to be configured with your preferred encryption tool (age, kms, etc).

#### Example install
```sh
     brew install sops talhelper siderolabs/talos/talosctl kustomize kubectl helm
```

### SOPS using age

```sh
     mkdir -p ~/.config/sops/age
     age-keygen -o ~/.config/sops/age/keys.txt
```

Ensure `direnv allow` has been ran in the root repo directory, and ensure `export SOPS_AGE_RECIPIENTS="$HOME/.config/sops/age/keys.txt"` is in your `.envrc` file in the root of the repo.

Configure your `.sops.yaml` with your age public key as such:

```yaml
creation_rules:
   - path_regex: secret-.*\.sops\.ya?ml
    encrypted_regex: "^(data|stringData)$"
    key_groups:
      - age:
        - YOUR_PUBLIC_AGE_KEY
  - path_regex: .*\.sops\.yaml
    key_groups:
      - age:
        - YOUR_PUBLIC_AGE_KEY
```

### Create Env File (optional)
An optional env file can be created to store variables that can be subsituted in
the talconfig.yaml on manifest generation

If these envs are secret, ensure that they are encrypted via SOPS:

```sh
touch talenv.sops.yaml
sops -e -i talenv.sops.yaml
```

Make sure direnv is installed, and that you run a direnv allow to enable the env vars to be loaded when entering the directory in your shell.

## WIP ##

*Updating to use Taskfile for easier configuration, instructions may be out of date*

### Create Talos Secrets

Per cluster, only run gensecret once!

**Ensure that each cluster has it's own secret, failure to do so may result in nodes attempting to join other clusters.**

```sh
talhelper gensecret > talsecret.sops.yaml
sops -e -i talsecret.sops.yaml
```

**Generating secrets will overwrite all of the keys and there's no way to recover from it. This will brick the cluster unless you have some sort of backup**

### Create Talos Config
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

Flash a usb stick with that ISO image. This will be used to install Talos on the bare metal machine.
Boot from USB and Talos will install on the device into maintenance mode.

### Boostrap
* load the Talos image onto a usb and boot your device from it
* either statically set ip addresses or use DHCP reservations to obtain
  an IP address
* Run bootstrap script, this configures the nodes, bootstraps the nodes, and runs the `deploy-integrations.sh` script that installs the Cilium and the CSR approver

```sh
./bootstrap.sh
```

If you're enabling the tailscale extension and are not using a pre-defined authkey:

* Grab the tailscale login url:

```sh
talosctl -n YOUR_NODE_IP logs ext-tailscale
```

### Installing apps

Follow the README located [here](./k8s/bootstrap/README.md). Flux is used to install all apps and will take ownership of the Cilium and CSR deployment that was done during the bootstrap.

### Updates

if you need to make a change to your talos config run `talhelper genconfig` to generate a
new config with your added changes then run `apply.sh` to apply them

### Resetting your nodes

Reboot your nodes, and interrupt the boot squence to set the nodes into maintenance mode. After that, follow the steps from ["Create Talos Secrets"](https://github.com/zhopp/homeops?tab=readme-ov-file#create-talos-secrets) onward.

To wipe your Ceph cluster, follow the README steps [here](./k8s/apps/storage/README.md)
