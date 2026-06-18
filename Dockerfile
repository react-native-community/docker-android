FROM ubuntu:22.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
# https://developer.android.com/studio#command-tools
ARG SDK_VERSION=commandlinetools-linux-11076708_latest.zip
ARG ANDROID_BUILD_VERSION=37
ARG ANDROID_TOOLS_VERSION=37.0.0
ARG NDK_VERSION=27.1.12297006
ARG NODE_VERSION=22.14
ARG WATCHMAN_VERSION=4.9.0
ARG CMAKE_VERSION=3.30.5

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/$NDK_VERSION

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

ENV PATH=${CMAKE_BIN_PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}

# Set the encoding to resolve a known character encoding issue with decompressing tar.gz files in containers
# via Gradle: https://github.com/gradle/gradle/issues/23391#issuecomment-1878979127
ENV LC_ALL=C.UTF8

# Install system dependencies
RUN apt update -qq && apt install -qq -y --no-install-recommends \
        apt-transport-https \
        curl \
        file \
        gcc \
        git \
        g++ \
        gnupg2 \
        libc++1-11 \
        libgl1 \
        libtcmalloc-minimal4 \
        make \
        openjdk-17-jdk-headless \
        openssh-client \
        patch \
        python3 \
        python3-distutils \
        rsync \
        ruby \
        ruby-dev \
        tzdata \
        unzip \
        sudo \
        ninja-build \
        zip \
        ccache \
        # Dev libraries requested by Hermes
        libicu-dev \
        # Dev dependencies required by linters
        jq \
        shellcheck \
    && gem install bundler \
    && rm -rf /var/lib/apt/lists/*;

# install nodejs using n
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n \
    && bash n $NODE_VERSION \
    && rm n \
    && npm install -g n \
    && npm install -g yarn

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;$CMAKE_VERSION" \
        "ndk;$NDK_VERSION" \
    && rm -rf ${ANDROID_HOME}/.android \
    && chmod 777 -R /opt/android

# Pre-download React Native native C++ dependencies so Gradle skips downloading them at build time
RUN mkdir -p /opt/react-native-downloads \
    && curl -sL -o /opt/react-native-downloads/boost_1_83_0.tar.gz https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.gz \
    && curl -sL -o /opt/react-native-downloads/double-conversion-1.1.6.tar.gz https://github.com/google/double-conversion/archive/v1.1.6.tar.gz \
    && curl -sL -o /opt/react-native-downloads/fast_float-8.0.0.tar.gz https://github.com/fastfloat/fast_float/archive/v8.0.0.tar.gz \
    && curl -sL -o /opt/react-native-downloads/fmt-11.0.2.tar.gz https://github.com/fmtlib/fmt/archive/11.0.2.tar.gz \
    && curl -sL -o /opt/react-native-downloads/folly-2024.11.18.00.tar.gz https://github.com/facebook/folly/archive/v2024.11.18.00.tar.gz \
    && curl -sL -o /opt/react-native-downloads/gflags-2.2.0.tar.gz https://github.com/gflags/gflags/archive/v2.2.0.tar.gz \
    && curl -sL -o /opt/react-native-downloads/glog-0.3.5.tar.gz https://github.com/google/glog/archive/v0.3.5.tar.gz \
    && curl -sL -o /opt/react-native-downloads/nlohmann_json-3.11.2.tar.gz https://github.com/nlohmann/json/archive/v3.11.2.tar.gz

ENV REACT_NATIVE_DOWNLOADS_DIR=/opt/react-native-downloads

# Disable git safe directory check as this is causing GHA to fail on GH Runners
RUN git config --global --add safe.directory '*'
