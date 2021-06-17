#!/bin/sh

set -e

ulimit

echo "Check Buck setup"
./scripts/circleci/buck_fetch.sh
buck build ReactAndroid/src/main/java/com/facebook/react
buck build ReactAndroid/src/main/java/com/facebook/react/shell

echo "Build React Native"
yarn install
./gradlew --no-daemon :ReactAndroid:packageReactNdkLibsForBuck

echo "Assemble RNTester app"
./gradlew --no-daemon :packages:rn-tester:android:app:assembleRelease
