#
# Mica Dockerfile
#
# https://github.com/obiba/docker-mica
#

FROM maven:3.9-eclipse-temurin-21 AS building

ARG MICA_BRANCH=master

ENV NVM_DIR=/root/.nvm
ENV NODE_LTS_VERSION=iron
ENV MICA_BRANCH=${MICA_BRANCH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl
RUN mkdir -p $NVM_DIR
SHELL ["/bin/bash", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    source $NVM_DIR/nvm.sh && \
    nvm install --lts=$NODE_LTS_VERSION && \
    npm install -g bower grunt && \
    echo '{ "allow_root": true }' > $HOME/.bowerrc

WORKDIR /projects
RUN git clone https://github.com/obiba/mica2.git

WORKDIR /projects/mica2

RUN source $NVM_DIR/nvm.sh; \
    git checkout $MICA_BRANCH && \
    mvn clean install

FROM maven:3.9-eclipse-temurin-21 AS es-plugin

ARG MICA_SEARCH_ES_BRANCH=2.0.2

RUN apt-get update && \
    apt-get install -y --no-install-recommends git

WORKDIR /projects
RUN git clone https://github.com/obiba/mica-search-es8.git

WORKDIR /projects/mica-search-es8

RUN git checkout $MICA_SEARCH_ES_BRANCH && \
    mvn clean install

FROM maven:3.9-eclipse-temurin-21 AS spss-plugin

ARG MICA_SPSS_BRANCH=2.0.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends git

WORKDIR /projects
RUN git clone https://github.com/obiba/mica-tables-spss.git

WORKDIR /projects/mica-tables-spss

RUN git checkout $MICA_SPSS_BRANCH && \
    mvn clean install

FROM docker.io/library/eclipse-temurin:25-jre-noble AS server-released

LABEL OBiBa=<dev@obiba.org>

ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8

ENV MICA_HOME=/srv
ENV MICA_DIST=/usr/share/mica2
ENV JAVA_OPTS=-Xmx2G

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y gosu apt-transport-https wget unzip curl libcurl4-openssl-dev libssl-dev && \
  apt-get clean &&  \
  rm -rf /var/lib/apt/lists/*

# Install Mica Server (built from source above)
RUN mkdir -p /tmp/mica2-dist
COPY --from=building /projects/mica2/mica-dist/target/mica2-*-dist.zip /tmp/mica2-dist/mica2.zip
RUN set -x && \
  cd /usr/share/ && \
  unzip -q /tmp/mica2-dist/mica2.zip && \
  rm -rf /tmp/mica2-dist && \
  mv mica2-* mica2 && \
  chmod +x /usr/share/mica2/bin/mica2

# Install plugins
RUN mkdir -p $MICA_DIST/plugins
COPY --from=es-plugin /projects/mica-search-es8/target/mica-search-es8-*-dist.zip $MICA_DIST/plugins/mica-search-es8-dist.zip
COPY --from=spss-plugin /projects/mica-tables-spss/target/mica-tables-spss-*-dist.zip $MICA_DIST/plugins/mica-tables-spss-dist.zip
RUN \
  unzip $MICA_DIST/plugins/mica-search-es8-dist.zip -d $MICA_DIST/plugins && \
  unzip $MICA_DIST/plugins/mica-tables-spss-dist.zip -d $MICA_DIST/plugins && \
  rm $MICA_DIST/plugins/*.zip

COPY ./bin /opt/mica/bin

RUN groupadd --system --gid 10041 mica && \
  useradd --system --home $MICA_HOME --no-create-home --uid 10041 --gid mica mica; \
  chmod +x -R /opt/mica/bin && \
  chown -R mica:mica /opt/mica

# Clean up
RUN apt remove -y unzip wget curl && \
  apt autoremove -y && \
  apt clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

VOLUME $MICA_HOME

# http and https
EXPOSE 8082 8445

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
