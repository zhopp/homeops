#!/usr/bin/env bash

echo "Applying Node Configs"
# Deploy the configuration to the nodes
talhelper gencommand apply | bash
