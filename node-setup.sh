#!/bin/bash

# add node 10.x repo and key to apt sources
echo "deb https://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list
apt-key adv --fetch-keys https://deb.nodesource.com/gpgkey/nodesource.gpg.key

# add yarn official repo and key to apt sources
echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
apt-key adv --fetch-keys https://dl.yarnpkg.com/debian/pubkey.gpg

apt-get update \
apt-get install -y --no-install-recommends \
    nodejs \
    yarn
rm -rf /var/lib/apt/lists/*