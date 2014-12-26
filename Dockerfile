# Clone from the CentOS 7
FROM centos:centos7
MAINTAINER Joshua Lee <muzili@gmail.com>
ENV container docker
RUN curl -o /etc/yum.repos.d/mkosek-freeipa-epel-7.repo https://copr.fedoraproject.org/coprs/mkosek/freeipa/repo/epel-7/mkosek-freeipa-epel-7.repo; \
    yum -y install deltarpm; \
    yum -y update; \
    yum swap -y -- remove fakesystemd -- install systemd systemd-libs; \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;\
    mkdir -p /run/lock ; \
    yum install -y freeipa-server bind bind-dyndb-ldap perl; \
    yum clean all

ADD scripts /scripts
RUN chmod -v +x /scripts/start.sh && \
    touch /firstrun

EXPOSE 53/udp 53 80 443 389 636 88 464 88/udp 464/udp 123/udp 7389 9443 9444 9445
VOLUME [ “/sys/fs/cgroup” ]
CMD ["/scripts/start.sh"]
