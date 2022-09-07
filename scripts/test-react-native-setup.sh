#!/bin/sh

set -e

export KOTLIN_HOME="third-party/kotlin"

echo "Download Buck dependencies"
./scripts/circleci/buck_fetch.sh

echo "Build React Native via Buck"
buck build ReactAndroid/src/main/java/com/facebook/react
buck build ReactAndroid/src/main/java/com/facebook/react/shell

echo "Build React Native via Gradle"
yarn install
./gradlew --no-daemon :ReactAndroid:packageReactNdkLibsForBuck -PreactNativeArchitectures=arm64-v8a

echo "Assemble RNTester Release arm64-v8a"
./gradlew --no-daemon :packages:rn-tester:android:app:assembleRelease -PreactNativeArchitectures=arm64-v8a
