#!/bin/bash
# Starts up Freeipa within the container.

# Stop on error
set -e

function usage () {
	if [ -n "$1" ] ; then
		echo $1 >&2
	else
		echo "Start as docker run -h \$FQDN_HOSTNAME -e PASSWORD=\$THE_ADMIN_PASSWORD image" >&2
	fi
	exit 1
}

systemd-tmpfiles --remove --create 2>&1 | grep -v 'Failed to replace specifiers' || :

rm -f /var/run/*.pid /run/systemctl-lite-running/*

CAN_EDIT_RESOLV_CONF=0
cp -f /etc/resolv.conf /etc/resolv.conf.docker
if echo '# test access' >> /etc/resolv.conf || umount /etc/resolv.conf 2> /dev/null ; then
	CAN_EDIT_RESOLV_CONF=1
	cp -f /etc/resolv.conf.docker /etc/resolv.conf
fi

if [[ -e /firstrun ]]; then
  source /scripts/first_run.sh
else
  source /scripts/normal_run.sh
fi

pre_start_action

post_start_action

# Start MariaDB
echo "Starting freeipa..."
exec /usr/sbin/init

