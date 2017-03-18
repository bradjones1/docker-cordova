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
RUN curl -o temp.zip https://dl.google.com/android/repository/tools_r25.2.3-linux.zip \
  && unzip -d /usr/local/android-sdk-linux temp.zip && rm temp.zip
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# update and accept licences
ENV ANDROID_SDK_HOME /tmp
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /usr/local/android-sdk-linux/tools/android update sdk --no-ui -a --filter platform-tool,build-tools-25.0.1,android-25; \
    find /usr/local/android-sdk-linux -perm 0744 | xargs chmod 755

RUN chmod -R 777 /tmp/.android

ENV GRADLE_USER_HOME /src/gradle

# install cordova and ionic.
RUN npm i -g cordova ionic

VOLUME /src
WORKDIR /src
