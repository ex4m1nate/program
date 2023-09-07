#!/bin/sh

logname="1_OracleListenerStop.log"
logfile="/tmp/job/$logname"

lsnrctl stop >> $logfile 2>&1

if [ $? != 0 ]; then
    exit 2;
else
    ps -ef | grep tnslsnr
fi

exit 0;