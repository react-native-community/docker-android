#!/bin/bash

export BUCK_VERSION=v2018.10.29.01
git clone https://github.com/facebook/buck.git /opt/buck --branch $BUCK_VERSION --depth=1
cd /opt/buck
ant