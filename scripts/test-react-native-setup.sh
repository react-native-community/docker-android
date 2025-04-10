#!/bin/sh

set -e

echo "Build React Native via Gradle"
yarn install --ignore-engines
./gradlew --no-daemon build -PreactNativeArchitectures=arm64-v8a
