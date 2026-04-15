#!/bin/bash
set -e

echo "Creating Maildir..."
mkdir -p /var/mail/contact/Maildir/{cur,new,tmp}
chown -R vmail:vmail /var/mail/
chmod -R 700 /var/mail/

echo "Check postfix aliases database..."
newaliases || true

echo "Starting postfix..."
postmap /etc/postfix/vmailbox
postfix start

echo "Provisioning password for virtual dovecot user 'contact'..."

cat > /etc/dovecot/users <<EOF
contact:$(doveadm pw -s SHA512-CRYPT -p $MAIL_PASSWD)::
EOF
chmod 600 /etc/dovecot/users

echo "Starting dovecot..."
dovecot --version
dovecot

echo "Starting Mail Depository API..."
exec python3 /opt/mail/mail.py
