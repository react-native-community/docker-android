#!/bin/sh

echo no | avdmanager create avd -n testEmulator -k "system-images;android-21;google_apis;armeabi-v7a"
emulator -avd testEmulator -no-audio -no-cache -no-snapshot -no-window &

echo "Waiting until the device is ready"
adb wait-for-device

echo "The device is ready"
adb shell input keyevent 82
