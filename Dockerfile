#FROM mkenney/npm:debian
FROM selenium/standalone-chrome

MAINTAINER Timoteo Ponce <timo.slack@gmail.com>

##########################
# INSTALL JAVA, SBT and other deps
ENV SBT_VERSION 0.13.11
ENV SBT_HOME /usr/local/sbt
ENV JAVA_HOME /usr/jdk1.8.0_66
ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV PATH ${PATH}:${SBT_HOME}/bin
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 7.2.0

USER root

RUN apt-get update && \
  apt-get install -y git curl xz-utils xvfb \
  && groupadd --gid 1100 node \
  && useradd --uid 1100 --gid node --shell /bin/bash --create-home node \
  && curl -kSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && npm install -g bower gulp polymer-cli && npm cache clean \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local
RUN  curl \
  --silent \
  --location \
  --retry 3 \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz" \
    | gunzip \
    | tar x -C /usr/ \
    && ln -s $JAVA_HOME /usr/java \
    && rm -rf $JAVA_HOME/src.zip $JAVA_HOME/javafx-src.zip $JAVA_HOME/man

