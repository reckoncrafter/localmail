#!/bin/bash
set -e

echo "Check postfix aliases database..."
newaliases || true

USERNAME="contact"
DOMAIN="mail.local"
ADDRESS=$USERNAME@$DOMAIN


echo "Provisioning virtual mail user $ADDRESS"

touch /etc/postfix/vmailbox
echo "$ADDRESS $DOMAIN/$USERNAME/" >> /etc/postfix/vmailbox
postmap /etc/postfix/vmailbox

echo "Adding Dovecot user configuration for $ADDRESS"


mkdir -p /var/mail/$DOMAIN/$USERNAME/
echo "$ADDRESS::5000:5000::/var/mail/$DOMAIN/$USERNAME" >> /var/mail/$DOMAIN/passwd
echo "$ADDRESS:$(doveadm pw -p $MAIL_PASSWD)" >> /var/mail/$DOMAIN/shadow
chown vmail:vmail /var/mail/$DOMAIN/passwd && chmod 775 /var/mail/$DOMAIN/passwd
chown vmail:vmail /var/mail/$DOMAIN/shadow && chmod 775 /var/mail/$DOMAIN/shadow

chown -R vmail:vmail /var/mail/
chmod -R 700 /var/mail/
#postfix reload

echo "Starting postfix..."
postmap /etc/postfix/virtual_alias
postfix start

cat > /etc/dovecot/users <<EOF
contact:$(doveadm pw -s SHA512-CRYPT -p $MAIL_PASSWD)::
EOF
chmod 600 /etc/dovecot/users

echo "Starting dovecot..."
dovecot --version
dovecot

echo "Starting Mail Depository API..."
exec python3 /opt/mail/mail.py
