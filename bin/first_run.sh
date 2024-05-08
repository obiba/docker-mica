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

# Install default plugins
if [ ! -d $MICA_HOME/plugins ]
then
	echo "Preparing default plugins in $MICA_HOME ..."
	mkdir -p $MICA_HOME/plugins
	cp -r $DEFAULT_PLUGINS_DIR/* $MICA_HOME/plugins
fi

# Configure MongoDB
if [ -n "$MONGODB_URI" ]
then
	sed s,localhost:27017/mica,$MONGODB_URI,g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
elif [ -n "$MONGO_HOST" ]
	then
  MGP=27017
	if [ -n "$MONGO_PORT" ]
	then
		MGP=$MONGO_PORT
	fi
	MGURI="$MONGO_HOST:$MGP"
	if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASSWORD" ]
	then
		MGURI="$MONGO_USER:$MONGO_PASSWORD@$MGURI/$MONGO_DB?authSource=admin"
	else
		MGURI="$MGURI/$MONGO_DB"
	fi
	sed s,localhost:27017/mica,$MGURI,g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Configure Opal
if [ -n "$OPAL_HOST" ]
	then
	sed s/localhost:8443/$OPAL_HOST:$OPAL_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
elif [ -n "$OPAL_URL" ]
	then
	sed s,https://localhost:8443,$OPAL_URL,g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Configure Agate
if [ -n "$AGATE_HOST" ]
	then
	sed s/localhost:8444/$AGATE_HOST:$AGATE_PORT/g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
elif [ -n "$AGATE_URL" ]
	then
	sed s,https://localhost:8444,$AGATE_URL,g $MICA_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $MICA_HOME/conf/application.yml
fi
