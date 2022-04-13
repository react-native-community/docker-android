# build buck from source
FROM ubuntu:20.04 AS buck

ARG BUCK_VERSION=2021.01.12.01
ENV ANT_OPTS="-Xmx4096m"
RUN apt update  && apt install  -y --no-install-recommends \
    ant \
    git \
    openjdk-11-jdk-headless \
    python-setuptools \
    python3-setuptools
# install buck by compiling it from source. We also remove the buck repo once it's built.
RUN git clone --depth 1 --branch v${BUCK_VERSION} https://github.com/facebook/buck.git \
    && cd buck \
    && ant \
    && ./bin/buck build buck --config java.target_level=11 --config java.source_level=11 --out /tmp/buck.pex

# build react native image and use buck built from source from above stage
FROM ubuntu:20.04
LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-7302050_latest.zip
ARG ANDROID_BUILD_VERSION=31
ARG ANDROID_TOOLS_VERSION=31.0.0
ARG NDK_VERSION=21.4.7075529
ARG NODE_VERSION=14.x
ARG WATCHMAN_VERSION=4.9.0
ARG CMAKE_VERSION=3.18.1

# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

ENV PATH=${ANDROID_NDK}:${CMAKE_BIN_PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}

COPY --from=buck /tmp/buck.pex /usr/local/bin/buck

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
    && gem install bundler \
    && rm -rf /var/lib/apt/lists/*;

# install nodejs and yarn packages from nodesource
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends nodejs \
    && npm i -g yarn \
    && rm -rf /var/lib/apt/lists/*

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
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;$CMAKE_VERSION" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "ndk;$NDK_VERSION" \
    && rm -rf ${ANDROID_HOME}/.android \
    && chmod 777 -R /opt/android \
    && ln -s ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.9 ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.8
