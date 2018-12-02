#!/bin/bash

export NDK_VERSION=17c

curl -sS https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip -o /tmp/ndk.zip
unzip -q /tmp/ndk.zip -d $ANDROID_NDK
rm /tmp/ndk.zip