#!/bin/sh
systemctl -q is-active pacemaker && exit

ARGS="-y --name $NAME"
if [ -n "$INTERFACE" ]; then
	ARGS="$ARGS -i $INTERFACE"
fi
if [ -n "$WATCHDOG" ]; then
	ARGS="$ARGS -w $WATCHDOG"
fi
if [ -n "$ADMIN_IP" ]; then
	ARGS="$ARGS -A $ADMIN_IP"
fi
if [ "$UNICAST" = "yes" ]; then
	ARGS="$ARGS -u"
fi
if [ -n "$SBD" ]; then
	ARGS="$ARGS --enable-sbd"
	if [ -n "$SBD_DEVICE" ]; then
		ARGS="$ARGS -s $SBD_DEVICE"
	fi
fi
/usr/sbin/crm cluster init $ARGS
