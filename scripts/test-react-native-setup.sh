#!/bin/sh

set -e

npx envinfo

export KOTLIN_HOME="third-party/kotlin"

echo "Download Buck dependencies"
./scripts/circleci/buck_fetch.sh

echo "Build React Native via Buck"
buck build ReactAndroid/src/main/java/com/facebook/react
buck build ReactAndroid/src/main/java/com/facebook/react/shell

echo "Build React Native via Gradle"
yarn install
./gradlew :ReactAndroid:packageReactNdkLibsForBuck

echo "Assemble RNTester app"
./gradlew :packages:rn-tester:android:app:assembleRelease
