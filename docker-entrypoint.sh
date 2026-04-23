#!/bin/bash
set -e

ADDRESS=$MAIL_USER@$MAIL_DOMAIN

echo "Checking prerequisites..."

if [ -z "$MAIL_USER" ]; then
    echo "No MAIL_USER variable defined, using default"
    MAIL_USER="mail"

elif [ -z "$MAIL_DOMAIN" ]; then
    echo "No MAIL_DOMAIN variable defined, using default"
    MAIL_DOMAIN="localmail"

elif [ -z "$MAIL_PASSWD" ]; then
    echo "No MAIL_PASSWD variable defined, using default"
    echo "It is highly recommended that you declare your own MAIL_PASSWD when running\
    as this is the password used to login to the mailbox over IMAP and SMTP"
    echo "Default password: password123"
    MAIL_PASSWD="passwd123"

elif [ -z "$(ls /etc/ssl/dovecot/certificate.pem)" ]; then
    echo "No SSL certificate found.\
    Please mount a certificate (e.g. fullchain.pem) to:\
    /etc/ssl/dovecot/certificate.pem"
    exit;

elif [ -z "$(ls /etc/ssl/dovecot/privatekey.pem)" ]; then
    echo "No SSL private key found.\
    Please mount a private key (e.g. privkey.pem) to:\
    /etc/ssl/dovecot/privatekey.pem"
    exit;
fi


echo "Mapping $MAIL_DOMAIN to loopback address..."
cat > /etc/hosts <<EOF
127.0.0.1 localhost
127.0.0.1 $MAIL_DOMAIN
::1 localhost
::1 $MAIL_DOMAIN
EOF

chmod 666 /etc/resolv.conf

echo "Initializing local mail user..."
mkdir -p /var/mail/$MAIL_USER/

mkdir -p /var/dovecot
echo "$MAIL_USER:$(doveadm pw -s SHA512-CRYPT -p $MAIL_PASSWD):5000:5000::/var/mail/$MAIL_USER" >> /var/dovecot/passwd
chown -R dovecot:dovecot /var/dovecot/

#echo "$ADDRESS:$(doveadm pw -p $MAIL_PASSWD)" >> /var/mail/shadow

echo "Initializing vmail user..."
#chown vmail:vmail /var/mail/shadow && chmod 775 /var/mail/shadow
chown -R vmail:vmail /var/mail/
chmod -R 700 /var/mail/

echo "Initializing dovecot unix sockets location..."
mkdir -p /run/dovecot
#chown -R dovecot:dovecot /run/dovecot
#chmod 0755 /run/dovecot

# echo "Configuring mail user password..."
# cat > /etc/dovecot/users <<EOF
# contact:$(doveadm pw -s SHA512-CRYPT -p $MAIL_PASSWD)::
# EOF
# chmod 600 /etc/dovecot/users

echo "Editing postfix configuration..."
sed -i -e "s/<MAIL_DOMAIN>/$MAIL_DOMAIN/g" /etc/postfix/main.cf
sed -i -e "s/<MAIL_DOMAIN>/$MAIL_DOMAIN/g" /etc/postfix/recipient_rewrite
sed -i -e "s/<MAIL_USER>/$MAIL_USER/g"     /etc/postfix/recipient_rewrite

# cat /etc/postfix/main.cf
# cat /etc/postfix/recipient_rewrite

echo "Starting postfix internal relay..."
postmap /etc/postfix/recipient_rewrite
postfix start

echo "Creating rawlog directories..."
mkdir -p /var/log/rawlog
mkdir -p /var/log/rawlog/relay
chmod -R 777 /var/log/rawlog

dovecot --version
dovecot

echo "Starting mail depository API..."
exec python3 /opt/mail/mail.py
