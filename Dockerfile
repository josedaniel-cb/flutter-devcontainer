FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG COMMAND_LINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip
ARG PLATFORM_VERSION=android-29
ARG BUILD_TOOLS_VERSION=33.0.1

# Install Java. See:
# - https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
RUN apt-get update && apt-get install -y openjdk-11-jdk

USER vscode

# Install Android SDK Command-Line Tools. See:
# - https://developer.android.com/studio/command-line/sdkmanager
RUN mkdir -p /home/vscode/android_sdk/cmdline-tools
WORKDIR /home/vscode/android_sdk/cmdline-tools
RUN wget -O commandlinetools.zip $COMMAND_LINE_TOOLS_URL \
    && unzip commandlinetools.zip \
    && rm commandlinetools.zip \
    && mv cmdline-tools latest
ENV ANDROID_HOME="/home/vscode/android_sdk"
ENV PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/"

# Install Android SDK Platform-Tools and Android SDK Build-Tools. See:
# - https://developer.android.com/studio/command-line/sdkmanager#install
RUN yes | sdkmanager \
    "platform-tools" \
    "platforms;$PLATFORM_VERSION" \
    "build-tools;$BUILD_TOOLS_VERSION"
ENV PATH="$PATH:$ANDROID_HOME/platform-tools/"

# Install Flutter. See:
# - https://docs.flutter.dev/get-started/install/linux
RUN git clone https://github.com/flutter/flutter.git -b stable /home/vscode/flutter
ENV PATH="$PATH:/home/vscode/flutter/bin/"

# Accept Android Licences
RUN yes | flutter doctor --android-licenses

# Start Android Debug Bridge server
RUN adb start-server

