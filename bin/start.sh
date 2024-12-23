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
	sed s/address:\ localhost//g $MICA_HOME/conf/application-prod.yml > /tmp/application-prod.yml && \
	    mv /tmp/application-prod.yml $MICA_HOME/conf/application-prod.yml
fi

# Upgrade configuration
if [[ -f $MICA_HOME/conf/application.yml && ! -f $MICA_HOME/conf/application-prod.yml ]]
	then
	if grep -q "profiles:" $MICA_HOME/conf/application.yml
		then
			cp $MICA_HOME/conf/application.yml $MICA_HOME/conf/application.yml.5.x
			cat $MICA_HOME/conf/application.yml.5.x | grep -v "profiles:" > $MICA_HOME/conf/application.yml
	fi
	mv -f $MICA_HOME/conf/application.yml $MICA_HOME/conf/application-prod.yml
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
	MGDB=mica
	if [ -n "$MONGO_DB" ]
	then
		MGDB=$MONGO_DB
	fi
	until curl -i http://$MONGO_HOST:$MONGO_PORT/$MGDB &> /dev/null
	do
  		sleep 1
	done
fi

# Configure Elasticsearch
if [ -n "$ELASTICSEARCH_HOST" ]
then
	/opt/mica/bin/set_elasticsearch.sh &
fi

# Start mica
/usr/share/mica2/bin/mica2
