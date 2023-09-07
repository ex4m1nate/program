#!/bin/sh

logname="3_OracleListenerStart.log"
logfile="/tmp/job/$logname"

lsnrctl start >> $logfile 2>&1

if [ $? != 0 ]; then
    exit 2;
else
    ps -ef | grep tnslsnr
fi

exit 0;