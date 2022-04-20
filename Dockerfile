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
ARG ANDROID_SDK_VERSION=7302050
ARG ANDROID_BUILD_VERSION=31
ARG ANDROID_TOOLS_VERSION=31.0.0
ARG NDK_VERSION=21.4.7075529
ARG NODE_VERSION=16.x
ARG GRADLE_VERSION=7.2
ARG WATCHMAN_VERSION=4.9.0
ARG CMAKE_VERSION=3.18.1
ARG SUDO_USER=android



# set default environment variables, please don't remove old env for compatibilty issue
ENV ADB_INSTALL_TIMEOUT=10
ENV USER_HOME=/home/$SUDO_USER
ENV ANDROID_HOME=$USER_HOME/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

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
        locales \
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
		s3cmd \
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
        wget \
        zlib1g \
        libgl1 \
        pulseaudio \
        socat \
    && locale-gen en_US.UTF-8 \
    && gem install bundler \
    && rm -rf /var/lib/apt/lists/*;

# Use unicode
ENV LANGUAGE	en_US.UTF-8
ENV LANG    	en_US.UTF-8
ENV LC_ALL  	en_US.UTF-8

# install nodejs and yarn packages from nodesource
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends nodejs \
    && npm i -g yarn \
    && rm -rf /var/lib/apt/lists/*

# Setup sudo user from defaults to 'android' with passwordless sudo so that npm doesn't fail due to bug when run as root for sentry
RUN groupadd --gid 1000 $SUDO_USER \
  && useradd --uid 1000 --gid $SUDO_USER --groups 0 --shell /bin/bash --home-dir $USER_HOME --create-home $SUDO_USER \
  && echo "$SUDO_USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/$SUDO_USER \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep


### Install Gradle : https://gradle.org/releases/
RUN wget -q https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
    rm gradle-${GRADLE_VERSION}-bin.zip

### Set Gradle in the environment variables
ENV GRADLE_HOME /opt/gradle-${GRADLE_VERSION}
ENV PATH $PATH:/opt/gradle-${GRADLE_VERSION}/bin

### Switch User ###
ENV HOME $USER_HOME
WORKDIR $USER_HOME
USER $SUDO_USER

ENV PATH=${GRADLE_HOME}/bin:${ANDROID_NDK}:${CMAKE_BIN_PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}

# WORKAROUND: for issue https://issuetracker.google.com/issues/37137213
ENV LD_LIBRARY_PATH ${ANDROID_SDK_ROOT}/emulator/lib64:${ANDROID_SDK_ROOT}/emulator/lib64/qt/lib

### Download and install Android SDK : https://developer.android.com/studio#command-tools
# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
# workaround buck clang version detection by symlinking
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && \
    unzip *tools*linux*.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm *tools*linux*.zip \
    && yes | sdkmanager --licenses && yes | sdkmanager --update \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;$CMAKE_VERSION" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "ndk;$NDK_VERSION" \
    && rm -rf ${ANDROID_HOME}/.android \
    && ln -s ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.9 ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.8
