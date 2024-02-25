FROM rockylinux:9 as builder

LABEL maintainer=hi@thisiskarimi.com

RUN dnf -y update && dnf -y groupinstall "Development Tools" && dnf -y install libedit-devel libuuid-devel libxml2-devel sqlite-devel openssl-devel

RUN curl -o /tmp/asterisk-20.6.0.tar.gz https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20.6.0.tar.gz && tar -xvf /tmp/asterisk-20.6.0.tar.gz -C /usr/src/

WORKDIR /usr/src/asterisk-20.6.0

RUN ./configure --with-jansson-bundled && make && make install && make samples


FROM rockylinux:9 as final

RUN dnf -y update && dnf -y install libedit

RUN useradd -r -U -M -s /sbin/nologin asterisk

COPY --from=builder --chown=asterisk:asterisk /usr/lib/libasterisk* /usr/lib/
COPY --from=builder --chown=asterisk:asterisk /usr/lib/asterisk/ /usr/lib/asterisk/
COPY --from=builder --chown=asterisk:asterisk /var/spool/asterisk/ /var/spool/asterisk/
COPY --from=builder --chown=asterisk:asterisk /var/log/asterisk/ /var/log/asterisk/
COPY --from=builder --chown=asterisk:asterisk /usr/sbin/asterisk /usr/sbin/asterisk
COPY --from=builder --chown=asterisk:asterisk /etc/asterisk/ /etc/asterisk/
COPY --from=builder --chown=asterisk:asterisk /var/lib/asterisk/ /var/lib/asterisk/
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/usr/sbin/asterisk -U asterisk -G asterisk -pvvvdddf"]
