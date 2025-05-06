{
  description = "Deploy Talos using talhelper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    talhelper.url = "github:budimanjojo/talhelper";
    };

  outputs = { self, nixpkgs, talhelper, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            talhelper.overlays.default
          ];
        };

        unstable = with pkgs ;[
          coreutils
          direnv
          sops
          talosctl
          kubectl
          kustomize
          go-task
          docker
          colima
          age
          yq
          jq
          curl
          wget
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          packages = unstable ++ [
            pkgs.talhelper
          ];

          # shellHook allows running arbitrary bash commands when the shell starts.
          shellHook = ''
            echo "Entering project development environment..."
            export MY_PROJECT_CONFIG_PATH="${self}/config"
            export PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
            export TALOSCONFIG="$PROJECT_ROOT/k8s/talos/clusterconfig/talosconfig"
            export SOPS_AGE_DIR="$PROJECT_ROOT/.age"
            export SOPS_AGE_KEY_FILE="$PROJECT_ROOT/.age/keys.txt"
            export KUBECONFIG="$PROJECT_ROOT/k8s/kubeconfig"
            export CLUSTER_DIR="$PROJECT_ROOT/k8s"
            export SOPS_CONFIG="$PROJECT_ROOT/.sops.yaml"
            export CLUSTER="$(basename $PROJECT_ROOT/k8s/)"
          '';
        };
      }
    );
}
