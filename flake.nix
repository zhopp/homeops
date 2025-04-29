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
          direnv
          sops
          talosctl
          kubectl
          kustomize
          go-task
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
          '';
        };
      }
    );
}
