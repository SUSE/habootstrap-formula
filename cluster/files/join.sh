#!/bin/sh
systemctl -q is-active pacemaker && exit
while true; do
	ping -q -c 1 $IP >/dev/null && break
	echo "[join] cluster creator not yet online..."
	sleep 5
done
ARGS="-y -c $IP"
if [ -n "$INTERFACE" ]; then
	ARGS="$ARGS -i $INTERFACE"
fi
if [ -n "$WATCHDOG" ]; then
	ARGS="$ARGS -w $WATCHDOG"
fi
/usr/sbin/crm cluster join $ARGS
