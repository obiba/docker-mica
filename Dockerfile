#
# Mica Dockerfile
#
# https://github.com/obiba/docker-mica
#

FROM obiba/docker-gosu:latest AS gosu

FROM maven:3.5.4-slim AS building

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 4.5.0
ENV MICA_BRANCH master

RUN mkdir -p $NVM_DIR

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends devscripts debhelper build-essential fakeroot git && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && \
    source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    npm install -g bower grunt && \
    echo '{ "allow_root": true }' > $HOME/.bowerrc

WORKDIR /projects
RUN git clone https://github.com/obiba/mica2.git

WORKDIR /projects/mica2

RUN source $NVM_DIR/nvm.sh; \
    git checkout $MICA_BRANCH; \
    mvn clean install && \
    mvn -Prelease org.apache.maven.plugins:maven-antrun-plugin:run@make-deb

FROM maven:3.5.4-slim AS es-plugin

ENV MICA_SEARCH_ES_BRANCH master

RUN apt-get update && \
    apt-get install -y --no-install-recommends git

WORKDIR /projects
RUN git clone https://github.com/obiba/mica-search-es.git

WORKDIR /projects/mica-search-es

RUN git checkout $MICA_SEARCH_ES_BRANCH; \
    mvn clean install

FROM openjdk:8-jdk-stretch AS server

ENV MICA_ADMINISTRATOR_PASSWORD password
ENV MICA_ANONYMOUS_PASSWORD password
ENV MICA_HOME /srv
ENV DEFAULT_PLUGINS_DIR /opt/plugins
ENV JAVA_OPTS -Xmx2G

WORKDIR /tmp
COPY --from=building /projects/mica2/mica-dist/target/mica2_*.deb .
RUN apt-get update && \
    apt-get install -y --no-install-recommends daemon psmisc && \
    DEBIAN_FRONTEND=noninteractive dpkg -i mica2_*.deb && \
    rm mica2_*.deb

WORKDIR $DEFAULT_PLUGINS_DIR
COPY --from=es-plugin /projects/mica-search-es/target/mica-search-es-*-dist.zip .

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

COPY /bin /opt/mica/bin
RUN chmod +x -R /opt/mica/bin; \
    chown -R mica /opt/mica; \
    chmod +x /usr/share/mica2/bin/mica2

WORKDIR $MICA_HOME

VOLUME $MICA_HOME
EXPOSE 8082 8445

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/bin/bash" ,"/docker-entrypoint.sh"]
CMD ["app"]