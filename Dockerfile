FROM alpine:3.23

ENV MAILDIR=/var/mail/
ENV PYTHONBUFFERED=1

RUN apk add --no-cache python3 \
    py3-flask \
    postfix \
    postfix-openrc \
    dovecot \
    ca-certificates \
    bash \
    busybox-suid \
    tzdata \
    shadow \
    rsyslog \
    mutt

#RUN adduser -u 5000 -h /home/vmail -s /usr/bin/nologin vmail
RUN usermod -u 5000 vmail
RUN addgroup -g 5000 vmail

RUN usermod -aG vmail postfix \
 && usermod -aG vmail dovecot

RUN mkdir -p /var/spool/postfix

RUN mkdir -p /var/spool/postfix/public
RUN chgrp -R postdrop /var/spool/postfix/public

RUN mkdir -p /var/spool/postfix/maildrop
RUN chgrp -R postdrop /var/spool/postfix/maildrop

COPY postfix /etc/postfix/

COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf

COPY mail.py  /opt/mail/mail.py

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 993 8080

VOLUME ["/var/mail"]
# VOLUME ["etc/ssl"]

ENTRYPOINT ["/docker-entrypoint.sh"]

