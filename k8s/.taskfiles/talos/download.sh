#!/bin/bash

talconfig="$CLUSTER_DIR/talos/talconfig.yaml"

schematic=$(yq .controlPlane.schematic "$talconfig")
image_id=$(curl -X POST --data-binary "$schematic" https://factory.talos.dev/schematics | jq -r .id)
talos_version=$(yq -r .talosVersion "$talconfig")
iso_url="https://factory.talos.dev/image/$image_id/$talos_version/metal-amd64.iso"

wget "$iso_url"
