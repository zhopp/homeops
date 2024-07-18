#!/usr/bin/env bash

echo "Applying node configs..."
talhelper gencommand apply --extra-flags=--insecure | bash
read -p "press enter key when node configuation is successful"

echo "Running bootstrap..."
talhelper gencommand bootstrap | bash
read -p "press enter key when bootstrap is successful"

echo "Creating kubeconfig..."
talhelper gencommand kubeconfig --extra-flags="-f ." | bash
export KUBECONFIG=$(pwd)/kubeconfig

echo kubectl get nodes
kubectl get nodes

echo deploying integrations
./deploy-integrations.sh
