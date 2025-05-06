# welcome to zhopp's homeops

This repo is for my homelab, to practice all things kubenetes.

## WIP ##
TODO:

* Add additional tasks to taskfile, validate tasks
* Document way to install Talos to bare metal nodes using PXE
* Make ISO download script more dynamic to allow user defined chipset

## Installation/Configuration Instructions
### Dependencies

This project's dependencies are handled via [nix flakes](https://wiki.nixos.org/wiki/Flakes).

In the root of the repo, run a `nix develop`. You may need to run a `direnv allow` in the directory, but after that, when you navigate into the directory your development environment will load.

The nix development environment will use the packages and versions defined in the project flake first (will put them first in your $PATH), but you will still retain access to your global packages.

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

### Installation using Taskfiles

This section is a WIP. We will automate the creation, bootstrapping, and managing a the Talos cluster and related actions using [taskfiles](https://taskfile.dev/)

We will have a root-level `taskfile` that will include sub taskfiles so it's easier to manage. It will set global settings (if desired).

The bellow will outline the steps to deploy and boostrap a cluster from bare-metal:

* Run `task talos:generate-initial-configs`
* This generates the cluster secret, generates the config for the cluster, to prepare for the initial bootstrap. Ensure you only run this once, or else you have the chance of breaking your cluster by generating a new cluster secret.

You now have two options for the inital boot/install of Talos, PXE or USB install.

#### PXE installation

Ensure your machines can be imaged using PXE. Enable in the BIOS and set boot order if required.



#### USB ISO bare metal install

* Run `task talos:download-iso`. This will download an ISO that you will use to create bootable media to use on your nodes to load Talos into maitenance mode.

* Create bootable USB drive using the .iso downloaded above. We will use this later. There are many ways to do this, so pick your favorite. Boot your machine from your USB, and Talos will enter maintenance mode.

You're now ready for the initial bootstrapping of Talos!


TODO: Gen the kubeconfig

### Helpful commands

Wiping and formatting drive on MacOS:
```shell
diskutil list
### note your drive disk name and path, use them in the commands below. In my case, it was disk4
diskutil eraseDisk MS-DOS disk4 /dev/disk4
diskutil  unmountDisk /dev/disk4
sudo dd if=k8s/metal-amd64.iso of=/dev/rdisk4 bs=4096 status=progress
diskutil eject /dev/disk4
```
