FROM openjdk:8-slim

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."
LABEL maintainer="Héctor Ramos <hector@fb.com>"

# set default environment variables
ENV ADB_INSTALL_TIMEOUT=10
ENV PATH=${PATH}:/opt/buck/bin/
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
ENV ANDROID_NDK=/opt/ndk/android-ndk
ENV PATH=${PATH}:${ANDROID_NDK}

# install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ant \
        apt-transport-https \
        autoconf \
        automake \
        curl \
        dirmngr \
        g++ \
        gcc \
        git \
        gnupg2 \
        libqt5widgets5 \
        lib32z1 \
        lib32stdc++6 \
        make \
        maven \
        python-dev \
        python3-dev \
        qml-module-qtquick-controls \
        qtdeclarative5-dev \
        unzip \
    && rm -rf /var/lib/apt/lists/*;

# install nodejs and yarn packages from nodesource and yarn apt sources
COPY node-setup.sh /tmp
RUN /tmp/node-setup.sh

# download buck and build buck
COPY buck-setup.sh /tmp
RUN /tmp/buck-setup.sh

COPY android-ndk-setup.sh /tmp
RUN /tmp/android-ndk-setup.sh

# Add android SDK tools
COPY android-sdk-setup.sh /tmp
RUN /tmp/android-sdk-setup.sh
