## Android Docker Image for react native
![Build Docker image](https://github.com/react-native-community/docker-android/workflows/Build%20Docker%20image/badge.svg)
![Publish](https://github.com/react-native-community/docker-android/workflows/Publish/badge.svg)
[![Docker Pulls](https://img.shields.io/docker/pulls/reactnativecommunity/react-native-android.svg?maxAge=3600)](https://hub.docker.com/r/reactnativecommunity/react-native-android) 
[![Docker Layers](https://images.microbadger.com/badges/image/reactnativecommunity/react-native-android.svg)](https://hub.docker.com/r/reactnativecommunity/react-native-android)

## Motivation
This is an implementation of https://github.com/react-native-community/discussions-and-proposals/blob/master/proposals/0005-Official-Docker.md.

## Support

### reactnativecommunity/react-native-android

Full image to build and test React Native apps. Comes with:

* Node
* Npm & Yarn
* Android SDK
* Buck
* Python,
* Ruby
* Commonly used apt packages (unzip, zip, ...)

| React Native Versions  | Full image                                    
| ---------------------- | -----------
| x - 0.63               | reactnativecommunity/react-native-android:3.0

[Find on docker hub.](https://hub.docker.com/r/reactnativecommunity/react-native-android/)

# reactnativecommunity/react-native-android-core

Core image that contains the minimum to build React Native apps. Comes with:

* Node
* Npm & Yarn
* Android SDK

| React Native Versions  | Core image
| ---------------------- | -----------
| x - 0.63               | reactnativecommunity/react-native-android-core:android-29-jdk-8 

[Find on docker hub.](https://hub.docker.com/r/reactnativecommunity/react-native-android-core/)

## Showcase
https://github.com/react-native-community/ci-sample

Original version is split from react-native repo, see https://github.com/facebook/react-native/blob/988366a4179d87d667e5d9396efdfba4cbbe0b2e/ContainerShip/Dockerfile.android-base.
