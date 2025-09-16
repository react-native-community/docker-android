#!/bin/sh

set -e

echo "Configuring environment for Fantom tests"
sudo apt update
sudo apt install -y git cmake openssl libssl-dev clang
git config --global --add safe.directory '*'
yarn install
yarn fantom
