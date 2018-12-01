#!/bin/bash

echo "deb https://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
&& echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
&& curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
&& curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&& apt-get update \
&& apt-get install -y --no-install-recommends nodejs yarn \
&& rm -rf /var/lib/apt/lists/*