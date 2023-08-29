#!/bin/sh

lsnrctl start

LSNRCTL_STATUS=$?

if [ $LSNRCTL_STATUS != 0 ]; then
    echo "Error: Oracle Listener could not be started."
    exit 2;
fi

echo "Oracle Listener started successfully."
exit 0;