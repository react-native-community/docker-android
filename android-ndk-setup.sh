#!/bin/bash

export NDK_VERSION=17c

curl -sS https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip -o /tmp/ndk.zip
unzip -q -d /tmp /tmp/ndk.zip
mv /tmp/android-ndk-r${NDK_VERSION} $ANDROID_NDK
rm /tmp/ndk.zip