#
# Mica Dockerfile
#
# https://github.com/obiba/docker-mica
#

FROM maven:3.9-eclipse-temurin-21 AS building

ENV NVM_DIR /root/.nvm
ENV NODE_LTS_VERSION iron
ENV MICA_BRANCH master

RUN apt-get update && \
    apt-get install -y --no-install-recommends devscripts debhelper build-essential fakeroot git curl
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
    mvn clean install && \
    mvn -Prelease org.apache.maven.plugins:maven-antrun-plugin:run@make-deb

FROM maven:3.9-eclipse-temurin-21 AS es-plugin

ENV MICA_SEARCH_ES_BRANCH master

RUN apt-get update && \
    apt-get install -y --no-install-recommends git

WORKDIR /projects
RUN git clone https://github.com/obiba/mica-search-es8.git

WORKDIR /projects/mica-search-es8

RUN git checkout $MICA_SEARCH_ES_BRANCH; \
    mvn clean install

FROM docker.io/library/eclipse-temurin:21-jre-noble AS server

ENV MICA_ADMINISTRATOR_PASSWORD password
ENV MICA_ANONYMOUS_PASSWORD password
ENV MICA_HOME /srv
ENV MICA_DIST /usr/share/mica2
ENV DEFAULT_PLUGINS_DIR /opt/plugins
ENV JAVA_OPTS -Xmx2G

RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip gosu

WORKDIR /tmp
COPY --from=building /projects/mica2/mica-dist/target/mica2-*-dist.zip .
RUN cd /usr/share/ && \
    unzip -q /tmp/mica2-*-dist.zip && \
    rm /tmp/mica2-*-dist.zip && \
    mv mica2-* mica2

RUN adduser --system --home $MICA_HOME --no-create-home --disabled-password mica

WORKDIR $DEFAULT_PLUGINS_DIR
COPY --from=es-plugin /projects/mica-search-es8/target/mica-search-es8-*-dist.zip .

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
