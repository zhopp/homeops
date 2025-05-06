#!/bin/bash

talconfig="$CLUSTER_DIR/talos/talconfig.yaml"

schematic=$(yq .controlPlane.schematic "$talconfig")
image_id=$(curl -X POST --data-binary "$schematic" https://factory.talos.dev/schematics | jq -r .id)
talos_version=$(yq -r .talosVersion "$talconfig")
iso_url="https://factory.talos.dev/pxe/$image_id/$talos_version/metal-amd64.iso" # check endpoint

## pull pxe boot assets
## put assets into a directory
## conditionally use colima if on Apple silion device
## use that in the docker compose to serve the right boot assets so machines can boot via iPXE
