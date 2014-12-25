pre_start_action() {
    HOSTNAME_FQDN=$( hostname -f )
    HOSTNAME_SHORT=${HOSTNAME_FQDN%%.*}
    DOMAIN=${HOSTNAME_FQDN#*.}
    if [ "$HOSTNAME_SHORT.$DOMAIN" != "$HOSTNAME_FQDN" ] ; then
	usage
    fi

    if [ -z "$PASSWORD" ] ; then
	usage
    fi

    REALM=${DOMAIN^^}

    DEBUG_OPT=
    if [ -n "$DEBUG" ] ; then
	DEBUG_OPT=-d
    fi

    if [ -z "$FORWARDER" ] ; then
	FORWARDER=$( awk '$1 == "nameserver" { print $2; exit }' /etc/resolv.conf )
    fi
    if [ "$FORWARDER" == '127.0.0.1' ] ; then
	FORWARDER=--no-forwarders
    else
	FORWARDER=--forwarder=$FORWARDER
    fi

    if [ "$CAN_EDIT_RESOLV_CONF" == "0" ] ; then
	find /usr -name bindinstance.py | xargs sed -i '/changing resolv.conf to point to ourselves/s/^/#/'
    fi

    if /usr/sbin/ipa-server-install -r $REALM -p $PASSWORD -a $PASSWORD -U $DEBUG_OPT --setup-dns $FORWARDER < /dev/null ; then
	sed -i 's/default_ccache_name/# default_ccache_name/' /etc/krb5.conf
	cp -f /etc/resolv.conf /etc/resolv.conf.ipa
	echo "FreeIPA server configured."
    else
	ret=$?
	echo "FreeIPA server configuration failed."
	exit $ret
    fi
}

post_start_action() {
    rm /firstrun
}
