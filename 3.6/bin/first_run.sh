#!/bin/bash

# Configure administrator password
adminpw=$(echo -n $MICA_ADMINISTRATOR_PASSWORD | xargs java -jar /usr/share/mica2/tools/lib/obiba-password-hasher-*-cli.jar)
cat $MICA_HOME/conf/shiro.ini | sed -e "s,^administrator\s*=.*\,,administrator=$adminpw\,," > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $MICA_HOME/conf/shiro.ini

# Configure anonymous password
anonympw=$(echo -n $MICA_ANONYMOUS_PASSWORD | xargs java -jar /usr/share/mica2/tools/lib/obiba-password-hasher-*-cli.jar)
cat $MICA_HOME/conf/shiro.ini | sed -e "s/^anonymous\s*=.*/anonymous=$anonympw/" > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $MICA_HOME/conf/shiro.ini

# Configure MongoDB
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
	then
	sed s/localhost:27017/$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Configure Opal
if [ -n "$OPAL_PORT_8443_TCP_ADDR" ]
	then
	sed s/localhost:8443/$OPAL_PORT_8443_TCP_ADDR:$OPAL_PORT_8443_TCP_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Configure Agate
if [ -n "$AGATE_PORT_8444_TCP_ADDR" ]
	then
	sed s/localhost:8444/$AGATE_PORT_8444_TCP_ADDR:$AGATE_PORT_8444_TCP_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi
