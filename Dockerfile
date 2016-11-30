#FROM mkenney/npm:debian
FROM selenium/node-chrome

MAINTAINER Timoteo Ponce <timo.slack@gmail.com>

##########################
# INSTALL JAVA, SBT and other deps
ENV SBT_VERSION 0.13.11
ENV SBT_HOME /usr/local/sbt
ENV JAVA_HOME /usr/jdk1.8.0_66

RUN apt-get update && \
  apt-get install -y git curl && \
  npm install -g bower gulp && npm cache clean && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

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

ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV PATH ${PATH}:${SBT_HOME}/bin
