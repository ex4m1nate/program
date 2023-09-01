#!/bin/sh

lsnrctl start

LSNRCTL_STATUS=$?

if [ $LSNRCTL_STATUS != 0 ]; then
    exit 2;
fi

exit 0;