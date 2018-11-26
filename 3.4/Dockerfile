#
# Mica Dockerfile
#
# https://github.com/obiba/docker-mica
#

FROM obiba/docker-gosu:latest AS gosu

# Pull base image
FROM openjdk:8-jdk-stretch AS server-released

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV MICA_ADMINISTRATOR_PASSWORD password
ENV MICA_ANONYMOUS_PASSWORD password
ENV MICA_HOME /srv
ENV JAVA_OPTS -Xmx2G

ENV MICA_BRANCH 3.4.2
ENV MICA_VERSION $MICA_BRANCH

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https unzip

# Install Mica Server
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O mica2.zip https://github.com/obiba/mica2/releases/download/${MICA_VERSION}/mica-dist-${MICA_VERSION}-dist.zip && \
  unzip -q mica2.zip && \
  rm mica2.zip && \
  mv mica-dist-${MICA_VERSION} mica2

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

RUN chmod +x /usr/share/mica2/bin/mica2

COPY ./bin /opt/mica/bin

RUN chmod +x -R /opt/mica/bin
RUN adduser --system --home $MICA_HOME --no-create-home --disabled-password mica
RUN chown -R mica /opt/mica

VOLUME $MICA_HOME

# http and https
EXPOSE 8082 8445

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
