#!/bin/bash

#
# Script waits until the 'site.properties' file exists,
# then replaces the localhost with the ELASTICSEARCH_HOST if set.
#

if [ -n "$ELASTICSEARCH_HOST" ]; then
    while true; do
        for file in $MICA_HOME/plugins/mica-search-es8*/site.properties; do
            if [ -f "$file" ]; then
                echo "Modifying $file..."
                sed -i "s/localhost/$ELASTICSEARCH_HOST/g" "$file"
                exit 0
            fi
        done
        sleep 1
    done
fi