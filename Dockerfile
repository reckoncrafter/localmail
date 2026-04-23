FROM alpine:3.23

ENV MAILDIR=/var/mail/
ENV PYTHONBUFFERED=1

RUN apk add --no-cache python3 \
    py3-flask \
    dovecot \
    dovecot-lmtpd \
    dovecot-submissiond \
    postfix \
    postfix-pcre \
    ca-certificates \
    bash \
    busybox-suid \
    tzdata \
    shadow \
    rsyslog \
    inetutils-telnet \
    mutt

# RUN adduser -D -u 5000 -h /home/vmail -s /usr/bin/nologin vmail
RUN usermod -u 5000 vmail
RUN addgroup -g 5000 vmail
RUN groupmod -g 5000 vmail

RUN usermod -aG vmail dovecot
RUN usermod -aG vmail postfix

COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY postfix/ /etc/postfix/

COPY mail.py  /opt/mail/mail.py

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 993 8080

# VOLUME ["/var/mail"]
VOLUME ["/etc/ssl/dovecot/certificate.pem"]
VOLUME ["/etc/ssl/dovecot/privatekey.pem"]

ENTRYPOINT ["/docker-entrypoint.sh"]

