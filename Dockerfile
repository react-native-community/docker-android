FROM ubuntu:20.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
# https://developer.android.com/studio#command-tools
ARG SDK_VERSION=commandlinetools-linux-8512546_latest.zip
ARG ANDROID_BUILD_VERSION=33
ARG ANDROID_TOOLS_VERSION=33.0.0
ARG NDK_VERSION=23.1.7779620
ARG RUBY_VERSION=3.2.2
ARG NODE_VERSION=16
ARG WATCHMAN_VERSION=4.9.0
ARG CMAKE_VERSION=3.22.1

# set default environment variables, please don't remove old env for compatibilty issue
ENV RBENV_ROOT=/root/.rbenv
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/$NDK_VERSION

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

ENV PATH=${RBENV_ROOT}/shims:${CMAKE_BIN_PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}

# Install system dependencies
RUN apt update -qq && apt install -qq -y --no-install-recommends \
        apt-transport-https \
        curl \
        file \
        gcc \
        git \
        g++ \
        gnupg2 \
        libc++1-10 \
        libgl1 \
        libtcmalloc-minimal4 \
        make \
        openjdk-11-jdk-headless \
        openssh-client \
        patch \
        python3 \
        python3-distutils \
        rsync \
        tzdata \
        unzip \
        sudo \
        ninja-build \
        zip \
        # Dev dependencies required by Ruby
        libssl-dev \
        libyaml-dev \
        libz-dev \
        # Dev libraries requested by Hermes
        libicu-dev \
        # Dev dependencies required by linters
        jq \
        shellcheck \
    && rm -rf /var/lib/apt/lists/*;

# install ruby using rbenv
RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
    && git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
    && eval "$(${RBENV_ROOT}/bin/rbenv init -)" \
    && rbenv install $RUBY_VERSION \
    && rbenv global $RUBY_VERSION \
    && gem install bundler

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
