# Clone from the CentOS 7
FROM centos:centos7

MAINTAINER Joshua Lee <muzili@gmail.com>

RUN yum swap -y -- remove fakesystemd -- install systemd systemd-libs && yum clean all

RUN curl -o /etc/yum.repos.d/mkosek-freeipa-epel-7.repo https://copr.fedoraproject.org/coprs/mkosek/freeipa/repo/epel-7/mkosek-freeipa-epel-7.repo

# Install FreeIPA server
RUN mkdir -p /run/lock ; yum install -y freeipa-server bind bind-dyndb-ldap perl && yum clean all


ADD scripts /scripts
ADD /scripts/dbus.service /etc/systemd/system/dbus.service
RUN chmod -v +x /scripts/systemctl /scripts/systemctl-socket-daemon \
    /scripts/start.sh /scripts/runuser-pp && \
    ln -sf dbus.service /etc/systemd/system/messagebus.service && \
    ln -sf /scripts/systemctl /bin/systemctl && \
    touch /firstrun

EXPOSE 53/udp 53 80 443 389 636 88 464 88/udp 464/udp 123/udp 7389 9443 9444 9445

CMD ["/scripts/start.sh"]
