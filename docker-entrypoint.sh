#!/bin/bash
set -e

USERNAME="contact"
DOMAIN="mail.local"
ADDRESS=$USERNAME@$DOMAIN

echo "Adding Dovecot user configuration for $ADDRESS"

mkdir -p /var/mail/$USERNAME/
echo "$ADDRESS::5000:5000::/var/mail/$USERNAME" >> /var/mail/passwd
echo "$ADDRESS:$(doveadm pw -p $MAIL_PASSWD)" >> /var/mail/shadow
chown vmail:vmail /var/mail/passwd && chmod 775 /var/mail/passwd
chown vmail:vmail /var/mail/shadow && chmod 775 /var/mail/shadow

chown -R vmail:vmail /var/mail/
chmod -R 700 /var/mail/

mkdir -p /run/dovecot
#chown -R dovecot:dovecot /run/dovecot
#chmod 0755 /run/dovecot

cat > /etc/dovecot/users <<EOF
contact:$(doveadm pw -s SHA512-CRYPT -p $MAIL_PASSWD)::
EOF
chmod 600 /etc/dovecot/users

echo "Starting dovecot..."
dovecot --version
dovecot

echo "Starting Mail Depository API..."
exec python3 /opt/mail/mail.py
