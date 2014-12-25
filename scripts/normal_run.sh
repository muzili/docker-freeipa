pre_start_action() {
    echo "FreeIPA server is already configured, starting the services."
    if [ "$CAN_EDIT_RESOLV_CONF" == "1" ] ; then
	if [ -f /etc/resolv.conf.ipa ] ; then
	    perl -pe 's/^(nameserver).*/$1 127.0.0.1/' /etc/resolv.conf.ipa > /etc/resolv.conf
	fi
    fi
    /scripts/systemctl start-enabled
    HOSTNAME_FQDN=$( hostname -f )
    while ! host $HOSTNAME_FQDN > /dev/null ; do
	sleep 5
    done
    kdestroy -A
    kinit -k
    (
	echo "server 127.0.0.1"
	echo "update delete $HOSTNAME_FQDN A"
	MY_IP=$( /sbin/ip addr show | awk '/inet .*global/ { split($2,a,"/"); print a[1]; }' | head -1 )
	echo "update add $HOSTNAME_FQDN 180 A $MY_IP"
	echo "send"
	echo "quit"
    ) | nsupdate -g
    kdestroy -A
    host $HOSTNAME_FQDN
    echo "FreeIPA server started."
}

post_start_action() {
    : # No-op
}
