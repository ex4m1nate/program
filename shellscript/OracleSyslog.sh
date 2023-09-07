#!/bin/sh

ALERT_LOG="/opt/oracle/diag/rdbms/dbfirc00/DBFIRC00/trace/alert_DBFIRC00.log"
ERROR_KEYWORDS="ORA-00600 ORA-00700"

monitor_alert_log() {
    while read -r line; do
        for keyword in $ERROR_KEYWORDS; do
            if [[ "$line" == *"$keyword"* ]]; then
                logger -p local0.err "Oracle Alert Log: $line"
                break
            fi
        done
    done < $ALERT_LOG
}

monitor_alert_log

if [ $? != 0  ]; then
    echo "Error: Posting to syslog failed."
    exit 2;
else
    echo "Posting to syslog was successfully completed."
fi

exit 0;