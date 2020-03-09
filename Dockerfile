FROM ubuntu

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

# set default build arguments
ARG SDK_VERSION=sdk-tools-linux-4333796.zip
ARG ANDROID_BUILD_VERSION=29
ARG ANDROID_TOOLS_VERSION=29.0.2
ARG BUCK_VERSION=2019.10.17.01
ARG NDK_VERSION=20.0.5594570
ARG NODE_VERSION=12.x
ARG WATCHMAN_VERSION=4.9.0

# set default environment variables
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION

ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/buck/bin/:${PATH}

# Install system dependencies
RUN apt update -qq && apt install -qq -y --no-install-recommends \
        apt-transport-https \
        curl \
        build-essential \
        file \
        git \
        openjdk-8-jdk \
        gnupg2 \
        python \
        openssh-client \
        unzip \
    && rm -rf /var/lib/apt/lists/*;

# install latest Ruby using ruby-install
RUN apt-get update -qq \
  && apt-get install -qq -y --no-install-recommends \
          bison \
          zlib1g-dev \
          libyaml-dev \
          libssl-dev \
          libgdbm-dev \
          libreadline-dev \
          libncurses5-dev \
          libffi-dev \
  && curl -L https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz | tar -zxvf - -C /tmp/ \
  && cd /tmp/ruby-install-* \
  && make install \
  && ruby-install --latest --system --cleanup ruby \
  && gem install bundler -N \
  && rm -rf /var/lib/apt/lists/*

# install nodejs and yarn packages from nodesource and yarn apt sources
RUN echo "deb https://deb.nodesource.com/node_${NODE_VERSION} stretch main" > /etc/apt/sources.list.d/nodesource.list \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends nodejs yarn \
    && rm -rf /var/lib/apt/lists/*

# download and install buck using debian package
RUN curl -sS -L https://github.com/facebook/buck/releases/download/v${BUCK_VERSION}/buck.${BUCK_VERSION}_all.deb -o /tmp/buck.deb \
    && dpkg -i /tmp/buck.deb \
    && rm /tmp/buck.deb

# Full reference at https://dl.google.com/android/repository/repository2-1.xml
# download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir ${ANDROID_HOME} \
    && unzip -q -d ${ANDROID_HOME} /tmp/sdk.zip \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-28" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;28.0.3" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "add-ons;addon-google_apis-google-23" \
        "system-images;android-19;google_apis;armeabi-v7a" \
        "extras;android;m2repository" \
        "ndk;$NDK_VERSION" \
    && rm -rf /opt/android/.android
