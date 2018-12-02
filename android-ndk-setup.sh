#!/bin/bash

export NDK_VERSION=17c

curl -sS https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip -o /tmp/ndk.zip
mkdir -p $ANDROID_NDK
unzip -q /tmp/ndk.zip -d $ANDROID_NDK
rm /tmp/ndk.zip