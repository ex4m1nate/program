#!/bin/sh

ALERT_LOG_PATH=/var/log/system.out
ERROR_KEYWORDS="ORA-00600 ORA-00700"

monitor_alert_log() {
    tail -Fn0 $ALERT_LOG_PATH | while read -r line; do
        for keyword in $ERROR_KEYWORDS; do
            if [[ "$line" == *"$keyword"* ]]; then
                logger -p local6.error "Oracle Alert Log: $line"
                break
            fi
        done
    done
}

monitor_alert_log


