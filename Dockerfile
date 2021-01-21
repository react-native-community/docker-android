FROM reactnativecommunity:react-native-android-core:android-29-jdk-8

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

ENV DEBIAN_FRONTEND=noninteractive

# set default build arguments
ARG BUCK_VERSION=2020.10.21.01

ENV PATH=${ANDROID_HOME}/emulator:/opt/buck/bin/:${PATH}

# Install system dependencies
RUN apt update -qq && apt install -qq -y --no-install-recommends \
        file \
        gnupg2 \
        libc++1-7 \
        libgl1 \
        libtcmalloc-minimal4 \
        openssh-client \
        python-minimal \
        python3 \
        python3-distutils \
        rsync \
        ruby \
        ruby-dev \
        tzdata \
        zip \
    && rm -rf /var/lib/apt/lists/*;

# # download and install buck using debian package
RUN curl -sS -L https://github.com/facebook/buck/releases/download/v${BUCK_VERSION}/buck.${BUCK_VERSION}_all.deb -o /tmp/buck.deb \
    && dpkg --force-all -i /tmp/buck.deb \
    && rm /tmp/buck.deb

# # Full reference at https://dl.google.com/android/repository/repository2-1.xml
# # download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "emulator" \
        "system-images;android-21;google_apis;armeabi-v7a" \
    && rm -rf ${ANDROID_HOME}/.android
