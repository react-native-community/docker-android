FROM openjdk:8-slim

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."
LABEL maintainer="Héctor Ramos <hector@fb.com>"

# set default build arguments
ARG SDK_VERSION=sdk-tools-linux-3859397.zip
ARG ANDROID_BUILD_VERSION=27
ARG ANDROID_TOOLS_VERSION=27.0.3
ARG BUCK_VERSION=v2018.10.29.01
ARG NDK_VERSION=17c
ARG NODE_VERSION=lts
ARG WATCHMAN_VERSION=4.9.0

# set default environment variables
ENV ADB_INSTALL_TIMEOUT=10
ENV PATH=${PATH}:/opt/buck/bin/
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
ENV ANDROID_NDK=/opt/ndk/android-ndk-r$NDK_VERSION
ENV PATH=${PATH}:${ANDROID_NDK}

# install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ant \
        autoconf \
        automake \
        curl \
        g++ \
        gcc \
        git \
        libqt5widgets5 \
        lib32z1 \
        lib32stdc++6 \
        make \
        maven \
        python-dev \
        python3-dev \
        qml-module-qtquick-controls \
        qtdeclarative5-dev \
        unzip

# install nodejs and yarn packages from nodesource and yarn apt sources
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt get install -y --no-install-recommends nodejs yarn

# download buck
RUN git clone https://github.com/facebook/buck.git /opt/buck --branch $BUCK_VERSION --depth=1
WORKDIR /opt/buck

# build buck
RUN ant

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
RUN mkdir /opt/android && \
 cd /opt/android && \
 curl --silent https://dl.google.com/android/repository/${SDK_VERSION} > android.zip && \
 unzip android.zip && \
 rm android.zip

# download and unpack NDK
RUN mkdir /opt/ndk && \
  cd /opt/ndk && \
  curl --silent https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip > ndk.zip && \
  unzip ndk.zip && \
  rm ndk.zip

# Add android SDK tools
RUN yes | sdkmanager --licenses && sdkmanager --update
RUN sdkmanager "system-images;android-19;google_apis;armeabi-v7a" \
    "platform-tools" \
    "platforms;android-$ANDROID_BUILD_VERSION" \
    "build-tools;$ANDROID_TOOLS_VERSION" \
    "add-ons;addon-google_apis-google-23" \
    "extras;android;m2repository"

# clean up unnecessary directories
RUN rm -rf /opt/android/.android
