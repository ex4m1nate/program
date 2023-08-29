#!/bin/sh

lsnrctl stop

LSNRCTL_STATUS=$?

if [ $LSNRCTL_STATUS != 0 ]; then
    echo "Error: Oracle Listener could not be stopped."
    exit 2;
fi

echo "Oracle Listener stopped successfully."
exit 0;