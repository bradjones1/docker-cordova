FROM node:7

# Adds 32-bit libraries as well.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
  tee /etc/apt/sources.list.d/webupd8team-java.list \
  && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
  tee -a /etc/apt/sources.list.d/webupd8team-java.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
  && dpkg --add-architecture i386 \
  && apt-get update && apt-get install -yqq --no-install-recommends \
  oracle-java8-installer \
  lib32stdc++6 lib32z1 \
  libswt-gtk-3-java \
  libxext6:i386 libgl1-mesa-glx:i386 libgl1-mesa-dri:i386 \
  && apt-get clean autoclean && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# install cordova
RUN npm i -g cordova@6

# download and extract android sdk
RUN curl http://dl.google.com/android/android-sdk_r24.2-linux.tgz | tar xz -C /usr/local/
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# update and accept licences
ENV ANDROID_SDK_HOME /tmp
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /usr/local/android-sdk-linux/tools/android update sdk --no-ui -a --filter platform-tool,build-tools-23.0.1,android-23,86; \
    find /usr/local/android-sdk-linux -perm 0744 | xargs chmod 755

RUN echo no | android create avd -n arm -t android-23 -g google_apis

RUN rm /tmp/adb.log && chmod -R 777 /tmp/.android

ENV GRADLE_USER_HOME /src/gradle
# Emulator is 32-bit.
ENV ANDROID_EMULATOR_FORCE_32BIT true
VOLUME /src
WORKDIR /src
