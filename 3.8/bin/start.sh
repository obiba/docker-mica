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

# Make sure conf folder is available
if [ ! -d $MICA_HOME/conf ]
	then
	mkdir -p $MICA_HOME/conf
	cp -r /usr/share/mica2/conf/* $MICA_HOME/conf
	# So that application is accessible from outside of docker
	sed s/address:\ localhost//g $MICA_HOME/conf/application.yml > /tmp/application.yml && \
	    mv /tmp/application.yml $MICA_HOME/conf/application.yml
fi

# Check if 1st run. Then configure database.
if [ -e /opt/mica/bin/first_run.sh ]
    then
    /opt/mica/bin/first_run.sh
    mv /opt/mica/bin/first_run.sh /opt/mica/bin/first_run.sh.done
fi

# Wait for MongoDB to be ready
if [ -n "$MONGO_HOST" ]
	then
	until curl -i http://$MONGO_HOST:$MONGO_PORT/mica &> /dev/null
	do
  		sleep 1
	done
fi

# Start mica
/usr/share/mica2/bin/mica2
