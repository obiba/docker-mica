#!/bin/bash

# Legacy parameters
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
then
	MONGO_HOST=$MONGO_PORT_27017_TCP_ADDR
fi
if [ -n "$MONGO_PORT_27017_TCP_PORT" ]
then
  MONGO_PORT=$MONGO_PORT_27017_TCP_PORT
fi
if [ -n "$OPAL_PORT_8443_TCP_ADDR" ]
then
	OPAL_HOST=$OPAL_PORT_8443_TCP_ADDR
fi
if [ -n "$OPAL_PORT_8443_TCP_PORT" ]
then
  OPAL_PORT=$OPAL_PORT_8443_TCP_PORT
fi
if [ -n "$AGATE_PORT_8444_TCP_ADDR" ]
then
	AGATE_HOST=$AGATE_PORT_8444_TCP_ADDR
fi
if [ -n "$AGATE_PORT_8444_TCP_PORT" ]
then
  AGATE_PORT=$AGATE_PORT_8444_TCP_PORT
fi

# Configure administrator password
adminpw=$(echo -n $MICA_ADMINISTRATOR_PASSWORD | xargs java -jar /usr/share/mica2/tools/lib/obiba-password-hasher-*-cli.jar)
cat $MICA_HOME/conf/shiro.ini | sed -e "s,^administrator\s*=.*\,,administrator=$adminpw\,," > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $MICA_HOME/conf/shiro.ini

# Configure anonymous password
anonympw=$(echo -n $MICA_ANONYMOUS_PASSWORD | xargs java -jar /usr/share/mica2/tools/lib/obiba-password-hasher-*-cli.jar)
cat $MICA_HOME/conf/shiro.ini | sed -e "s/^anonymous\s*=.*/anonymous=$anonympw/" > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $MICA_HOME/conf/shiro.ini

# Configure MongoDB
if [ -n "$MONGO_HOST" ]
	then
	sed s/localhost:27017/$MONGO_HOST:$MONGO_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Configure Opal
if [ -n "$OPAL_HOST" ]
	then
	sed s/localhost:8443/$OPAL_HOST:$OPAL_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Configure Agate
if [ -n "$AGATE_HOST" ]
	then
	sed s/localhost:8444/$AGATE_HOST:$AGATE_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi
