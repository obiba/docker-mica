#!/bin/bash

# Make sure conf folder is available
if [ ! -d $MICA_HOME/conf ]
	then
	mkdir -p $MICA_HOME/conf
	cp -r /etc/mica2/* $MICA_HOME/conf
fi

# Install default plugins
if [ ! -d $MICA_HOME/plugins ]
then
  echo "Preparing default plugins in $MICA_HOME ..."
  mkdir -p $MICA_HOME/plugins
  cp -r $DEFAULT_PLUGINS_DIR/* $MICA_HOME/plugins
fi

# Check if 1st run. Then configure database.
if [ -e /opt/mica/bin/first_run.sh ]
    then
    /opt/mica/bin/first_run.sh
    mv /opt/mica/bin/first_run.sh /opt/mica/bin/first_run.sh.done
fi

# Wait for MongoDB to be ready
if [ -n "$MONGO_PORT_27017_TCP_ADDR" ]
	then
	until curl -i http://$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT/mica &> /dev/null
	do
  		sleep 1
	done
fi

# Start mica
/usr/share/mica2/bin/mica2