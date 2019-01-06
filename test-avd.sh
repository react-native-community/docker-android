set -e
echo no | avdmanager create avd -n testEmulator -k "system-images;android-19;google_apis;armeabi-v7a"
emulator -avd testEmulator -no-audio -no-window &
curl -sS https://raw.githubusercontent.com/travis-ci/travis-cookbooks/master/community-cookbooks/android-sdk/files/default/android-wait-for-emulator -o android-wait-for-emulator
chmod +x ./android-wait-for-boot.sh && ./android-wait-for-boot.sh
adb shell input keyevent 82
