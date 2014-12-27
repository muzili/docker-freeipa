# Clone from the CentOS 7
FROM muzili/systemd
MAINTAINER Joshua Lee <muzili@gmail.com>
ENV container docker
RUN yum -y install deltarpm; \
    yum -y update; \
    yum install -y freeipa-server bind bind-dyndb-ldap; \
    yum clean all

ADD scripts /scripts
RUN chmod -v +x /scripts/start.sh && \
    touch /firstrun

EXPOSE 53/udp 53 80 443 389 636 88 464 88/udp 464/udp 123/udp 7389 9443 9444 9445
VOLUME [ “/sys/fs/cgroup” ]
CMD ["/usr/sbin/init"]
