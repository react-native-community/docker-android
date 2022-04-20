
Use this to test local or online docker Images
```
git clone https://github.com/facebook/react-native --depth=1
docker run --rm -v $PWD/scripts/:/scripts -v $PWD/react-native/:/react-native -w /react-native reactnativecommunity/react-native-android /bin/sh -c "/scripts/test-react-native-setup.sh"
```