#
# Mica Dockerfile
#
# https://github.com/obiba/docker-mica
#

FROM docker.io/library/eclipse-temurin:21-jre-noble AS server-released

LABEL OBiBa <dev@obiba.org>

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV MICA_ADMINISTRATOR_PASSWORD password
ENV MICA_ANONYMOUS_PASSWORD password
ENV MICA_HOME /srv
ENV MICA_DIST /usr/share/mica2
ENV JAVA_OPTS -Xmx2G

ENV MICA_VERSION 6.0.0-RC2
ENV ES8_PLUGIN_VERSION=2.0.0-RC1

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https unzip gosu

# Install Mica Server
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O mica2.zip https://github.com/obiba/mica2/releases/download/${MICA_VERSION}/mica2-${MICA_VERSION}-dist.zip && \
  unzip -q mica2.zip && \
  rm mica2.zip && \
  mv mica2-${MICA_VERSION} mica2 && \
  chmod +x /usr/share/mica2/bin/mica2

# Install ElasticSearch 8 plugin
RUN \
  mkdir -p $MICA_DIST/plugins && \
  curl -L -o $MICA_DIST/plugins/mica-search-es8-${ES8_PLUGIN_VERSION}-dist.zip https://github.com/obiba/mica-search-es8/releases/download/${ES8_PLUGIN_VERSION}/mica-search-es8-${ES8_PLUGIN_VERSION}-dist.zip

COPY ./bin /opt/mica/bin

RUN chmod +x -R /opt/mica/bin && \
  adduser --system --home $MICA_HOME --no-create-home --disabled-password mica && \
  chown -R mica /opt/mica

VOLUME $MICA_HOME

# http and https
EXPOSE 8082 8445

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
