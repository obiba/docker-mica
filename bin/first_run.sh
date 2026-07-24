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
cat $MICA_HOME/conf/shiro.ini | sed -e "s|^administrator\s*=.*,|administrator=\"$adminpw\",|" > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $MICA_HOME/conf/shiro.ini

# Configure anonymous password
anonympw=$(echo -n $MICA_ANONYMOUS_PASSWORD | xargs java -jar /usr/share/mica2/tools/lib/obiba-password-hasher-*-cli.jar)
cat $MICA_HOME/conf/shiro.ini | sed -e "s|^anonymous\s*=.*,|anonymous=\"$anonympw\",|" > /tmp/shiro.ini && \
    mv /tmp/shiro.ini $MICA_HOME/conf/shiro.ini

# Configure MongoDB
if [ -n "$MONGODB_URI" ]
then
	sed s,localhost:27017/mica,$MONGODB_URI,g $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml
	mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
elif [ -n "$MONGO_HOST" ]
	then
  MGP=27017
	if [ -n "$MONGO_PORT" ]
	then
		MGP=$MONGO_PORT
	fi
	MGURI="$MONGO_HOST:$MGP"
	MGDB=mica
	if [ -n "$MONGO_DB" ]
	then
		MGDB=$MONGO_DB
	fi
	if [ -n "$MONGO_USER" ] && [ -n "$MONGO_PASSWORD" ]
	then
		MGURI="$MONGO_USER:$MONGO_PASSWORD@$MGURI/$MGDB?authSource=admin"
	else
		MGURI="$MGURI/$MGDB"
	fi
	sed s,localhost:27017/mica,$MGURI,g $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml
	mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
fi

# Configure Opal
if [ -n "$OPAL_URL" ]
	then
	sed -e "/^opal:/,/^[a-z]/ s|^\(\s*url:\s*\).*|\1$OPAL_URL|" $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
elif [ -n "$OPAL_HOST" ]
	then
	OPAL_URL="http://$OPAL_HOST:${OPAL_PORT:-8080}"
	sed -e "/^opal:/,/^[a-z]/ s|^\(\s*url:\s*\).*|\1$OPAL_URL|" $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
fi

# Configure Opal credentials
if [ -n "$OPAL_USERNAME" ]
	then
	sed -e "/^opal:/,/^[a-z]/ s|^\(\s*username:\s*\).*|\1$OPAL_USERNAME|" $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
fi
if [ -n "$OPAL_PASSWORD" ]
	then
	sed -e "/^opal:/,/^[a-z]/ s|^\(\s*password:\s*\).*|\1$OPAL_PASSWORD|" $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
fi

# Configure Agate
if [ -n "$AGATE_URL" ]
	then
	sed -e "/^agate:/,/^[a-z]/ s|^\(\s*url:\s*\).*|\1$AGATE_URL|" $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
elif [ -n "$AGATE_HOST" ]
	then
	AGATE_URL="http://$AGATE_HOST:${AGATE_PORT:-8081}"
	sed -e "/^agate:/,/^[a-z]/ s|^\(\s*url:\s*\).*|\1$AGATE_URL|" $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv -f /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
fi
