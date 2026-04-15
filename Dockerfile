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
    mutt

#RUN adduser vmail -D -h /var/mail/ -s /sbin/nologin -
RUN addgroup -S vmail

RUN mkdir -p /var/spool/postfix

RUN mkdir -p /var/spool/postfix/public
RUN chgrp -R postdrop /var/spool/postfix/public

RUN mkdir -p /var/spool/postfix/maildrop
RUN chgrp -R postdrop /var/spool/postfix/maildrop

COPY postfix/main.cf /etc/postfix/main.cf
COPY postfix/vmailbox /etc/postfix/vmailbox

COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY dovecot/conf.d /etc/dovecot/conf.d/
RUN touch /etc/dovecot/users \
 && chmod 600 /etc/dovecot/users \
 && chown dovecot:dovecot /etc/dovecot/users

COPY mail.py  /opt/mail/mail.py

RUN printf "root: nobody" > /etc/aliases && newaliases

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 993 8080

VOLUME ["/var/mail"]
# VOLUME ["etc/ssl"]

ENTRYPOINT ["/docker-entrypoint.sh"]

