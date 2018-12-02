#!/bin/bash
export SDK_VERSION=sdk-tools-linux-3859397.zip
export ANDROID_BUILD_VERSION=27
export ANDROID_TOOLS_VERSION=27.0.3

curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/android-sdk.zip
mkdir -p $ANDROID_HOME
unzip -q -d $ANDROID_HOME /tmp/android-sdk.zip
rm /tmp/android-sdk.zip

yes | sdkmanager --licenses && sdkmanager --update
sdkmanager "system-images;android-19;google_apis;armeabi-v7a" \
    "platform-tools" \
    "platforms;android-$ANDROID_BUILD_VERSION" \
    "build-tools;$ANDROID_TOOLS_VERSION" \
    "add-ons;addon-google_apis-google-23" \
    "extras;android;m2repository"

# clean up unnecessary directories
rm -rf /opt/android/.android
