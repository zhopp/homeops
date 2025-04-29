# welcome to zhopp's homeops

This repo is for my homelab, to practice all things kubenetes.

## WIP ##

*Updating to use Taskfile for easier configuration, instructions may be out of date*

TODO:

* Add additional tasks to taskfile, validate tasks
* Document way to install Talos to bare metal nodes using PXE
* Make ISO download script more dynamic to allow user defined chipset

## Installation/Configuration Instructions
### Dependencies

This project's dependencies are handled via [nix flakes](https://wiki.nixos.org/wiki/Flakes).

In the root of the repo, run a `nix develop`. You may need to run a `direnv allow` in the directory, but after that, when you navigate into the directory your development environment will load.

The nix development environment will use the packages and versions defined in the project flake first (will put them first in your $PATH), but you will still retain access to your global packages.

### Installation using Taskfiles

This section is a WIP. We will automate the creation, bootstrapping, and managing a the Talos cluster and related actions using [taskfiles](https://taskfile.dev/)

We will have a root-level `taskfile` that will include sub taskfiles so it's easier to manage. It will set global settings (if desired).

The bellow will outline the steps to deploy and boostrap a cluster from bare-metal:

* Run `task talos:generate-initial-configs`
* This generates the cluster secret, generates the config for the cluster, to prepare for the initial apply. Ensure you only run this once, or else you have the chance of breaking your cluster by generating a new cluster secret.

* Run `task talos:download-iso`. This will download an ISO that you will use to create bootable media to use on your nodes to load Talos into maitenance mode.

* Create bootable USB drive using the .iso downloaded above. We will use this later. There are many ways to do this, so pick your favorite.

TODO: Gen the kubeconfig

### SOPS using age

Run the age key creation taskfile: `task utils:create-age-key`. 

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
