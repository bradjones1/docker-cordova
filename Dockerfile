FROM node:7

# Adds 32-bit libraries as well.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
  tee /etc/apt/sources.list.d/webupd8team-java.list \
  && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
  tee -a /etc/apt/sources.list.d/webupd8team-java.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
  && apt-get update && apt-get install -yqq --no-install-recommends \
  oracle-java8-installer \
  lib32stdc++6 lib32z1 \
  libswt-gtk-3-java \
  unzip \
  && apt-get clean autoclean && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# download and extract android sdk
RUN curl -L -o temp.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \
  && unzip -d /usr/local/android-sdk-linux temp.zip && rm temp.zip
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

#download and install gradle.
RUN curl -s -L -o temp.zip https://services.gradle.org/distributions/gradle-4.2.1-bin.zip \
  && unzip -d /usr/local temp.zip && rm temp.zip
ENV PATH $PATH:/usr/local/gradle-3.3/bin

ENV ANDROID_SDK_HOME /tmp
RUN mkdir -p /tmp/.android && touch /tmp/.android/repositories.cfg && chmod -R 777 /tmp/.android
# update and accept licences
RUN mkdir -p ${ANDROID_HOME}/licenses
RUN echo -n 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license
# Install some basic dependencies and let Gradle install what it wants.
RUN /usr/local/android-sdk-linux/tools/bin/sdkmanager \
  "platform-tools" \
  "extras;android;m2repository" \
  && chmod -R 777 $ANDROID_HOME

ENV GRADLE_USER_HOME /src/gradle

VOLUME /src
WORKDIR /src
