FROM openjdk:8-jdk
MAINTAINER Timoteo Ponce <timo.slack@gmail.com>
##########################
# INSTALL JAVA, SBT and other deps
ENV SBT_VERSION 0.13.11
ENV SBT_HOME /usr/local/sbt
#ENV JAVA_HOME /usr/jdk1.8.0_66
ENV PATH ${PATH}:${JAVA_HOME}/bin
ENV PATH ${PATH}:${SBT_HOME}/bin
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.13.0
###########################

USER root

# Fix for non supported packages
# RUN sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y curl git xvfb apt-transport-https \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | gunzip | tar -x -C /usr/local
#RUN curl -LOH 'Cookie: oraclelicense=accept-securebackup-cookie' $(curl -s https://lv.binarybabel.org/catalog-api/java/jdk8.txt?p=downloads.tgz) \
#    && mkdir -p /usr/java \
#    && tar xvf jdk-*.tar.gz -C /usr/java --strip-components=1 \
#    && ln -s $JAVA_HOME /usr/java \
#    && rm -rf $JAVA_HOME/src.zip $JAVA_HOME/javafx-src.zip $JAVA_HOME/man


RUN curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN curl -kSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && chmod -R a+rwx /usr/local/lib/ \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs && mkdir -p /usr/local/lib && mkdir -p /usr/local/node_modules \
  && chown -R node /usr/local/ 

USER node

RUN npm install -g bower gulp polymer-cli

USER root
# Add certificates
RUN mkdir -p /usr/local/share/ca-certificates/

COPY trust-certs/ /usr/local/share/ca-certificates/

RUN ls -1 /usr/local/share/ca-certificates | while read cert; do \
  openssl x509 -outform der -in /usr/local/share/ca-certificates/$cert -out $cert.der; \
  $JAVA_HOME/bin/keytool -import -alias $cert -keystore $JAVA_HOME/jre/lib/security/cacerts -trustcacerts -file $cert.der -storepass changeit -noprompt; \
  rm $cert.der; \
  done

