#!/bin/sh

lsnrctl stop

if [ $? != 0 ]; then
    exit 2;
else
    ps -ef | grep tnslsnr
fi

exit 0;