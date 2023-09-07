#!/bin/sh

lsnrctl start

if [ $? != 0 ]; then
    exit 2;
else
    ps -ef | grep tnslsnr
fi

exit 0;