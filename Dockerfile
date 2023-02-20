FROM ubuntu:20.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# Keep the previous SDK as a fallback until we've finished the migration.
ARG ANDROID_BUILD_VERSION_FALLBACK=31
ARG ANDROID_TOOLS_VERSION_FALLBACK=31.0.0

# set default build arguments
# https://developer.android.com/studio#command-tools
ARG SDK_VERSION=commandlinetools-linux-8512546_latest.zip
ARG ANDROID_BUILD_VERSION=33
ARG ANDROID_TOOLS_VERSION=33.0.0
ARG BUCK_VERSION=2022.05.05.01
# Buck doesn't support versions beyond NDK 21
# Therefore we need to diverge the NDK version and set NDK_HOME
# for Buck to pick it up correctly.
ARG NDK_VERSION_BUCK=21.4.7075529
ARG NDK_VERSION_GRADLE=23.1.7779620
ARG NODE_VERSION=16
ARG WATCHMAN_VERSION=4.9.0
# For comaptibilites we install both CMake 3.18.x and 3.22.x, as AGP 7.3 autodownloads 3.18.x
# Once we bump to AGP 7.4, we can remove 3.18.x and use only 3.22.x
ARG CMAKE_VERSION=3.22.1
ARG OLD_CMAKE_VERSION=3.18.1

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK_BUCK=${ANDROID_HOME}/ndk/$NDK_VERSION_BUCK
ENV ANDROID_NDK_GRADLE=${ANDROID_HOME}/ndk/$NDK_VERSION_GRADLE
# this is needed for Buck to be able to recognize NDK 21
ENV NDK_HOME=${ANDROID_HOME}/ndk/$NDK_VERSION_BUCK
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/$NDK_VERSION_GRADLE

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

ENV PATH=${CMAKE_BIN_PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}

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
        ruby \
        ruby-dev \
        tzdata \
        unzip \
        sudo \
        ninja-build \
        zip \
        # Dev libraries requested by Hermes
        libicu-dev \
        # Emulator & video bridge dependencies
        libc6 \
        libdbus-1-3 \
        libfontconfig1 \
        libgcc1 \
        libpulse0 \
        libtinfo5 \
        libx11-6 \
        libxcb1 \
        libxdamage1 \
        libnss3 \
        libxcomposite1 \
        libxcursor1 \
        libxi6 \
        libxext6 \
        libxfixes3 \
        zlib1g \
        libgl1 \
        pulseaudio \
        socat \
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

 # download and install buck using the java11 pex from Jitpack
 RUN curl -L https://jitpack.io/com/github/facebook/buck/v${BUCK_VERSION}/buck-v${BUCK_VERSION}-java11.pex -o /tmp/buck.pex \
    && mv /tmp/buck.pex /usr/local/bin/buck \
    && chmod +x /usr/local/bin/buck

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
# workaround buck clang version detection by symlinking
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "platforms;android-$ANDROID_BUILD_VERSION_FALLBACK" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION_FALLBACK" \
        "cmake;$CMAKE_VERSION" \
        "cmake;$OLD_CMAKE_VERSION" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "ndk;$NDK_VERSION_BUCK" \
        "ndk;$NDK_VERSION_GRADLE" \
    && rm -rf ${ANDROID_HOME}/.android \
    && chmod 777 -R /opt/android \
    && ln -s ${ANDROID_NDK_BUCK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.9 ${ANDROID_NDK_BUCK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.8
