# localmail

Localmail is a docker container that provides a simple means of collecting arbitrary data from a web server and
making it available as if it were email.

It accepts data at an HTTP API endpoint: `/send`, in the form of a JSON document, e.g.:

```json
{
 "subject": "Form Submission Notification",
 "from": "user@mail.com",
 "body": "content..."
}
```

> This project currently uses the Flask development server, and the API is fixed on port 8080.

The endpoint can be tested with cURL:
```bash
curl --location 'http://localhost:8080/send' \
--header 'Content-Type: application/json' \
--data-raw '{
 "subject": "Form Submission Notification",
 "from": "user@mail.com",
 "body": "content..."
}'
```

These documents are converted into email format and submitted to Mailcot via an LMTP request, which Mailcot
delivers to a Maildir at `/var/mail/$MAIL_USER/Maildir`

Dovecot then makes these emails available over IMAP.

Dovecot is also set up to provide a submission (SMTP) service.
Because nearly all email clients won't allow a mailbox to be configured
with only IMAP or POP3, which would be receive-only, the container also exposes this SMTP service.

The submission service relays to a simple postfix relay, which relays back to dovecot's LMTP service. This allows
mail clients to send messages to it's own mailbox (some clients do this as part of set up to check that the server is working),
but will always bounce emails sent to other users or domains.

Here's an example docker-compose.yml to build the container:
```yml
services:
  mail:
    container_name: localmail
    build: ./localmail
    ports:
      - "127.0.0.1:8080:8080" # HTTP API
      - "993:993" # IMAPS
      - "143:143" # IMAP
      - "587:587" # SMTP
    volumes:
      - mail_data:/var/mail
    restart: none
    configs:
      - mail_env
    secrets:
      - certificate.pem
      - privatekey.pem

volumes:
  mail_data:
    # External volume for persistent storage of mailbox content

configs:
  mail_env:
    file: # Points to a .env file containing definitions for:
      # MAIL_USER (mailbox username)
      # MAIL_DOMAIN (mailbox domain. This can really be anything you want.)
      # MAIL_PASSWD (password to authenticate over SMTP and IMAP)

secrets:
  certificate.pem:
    # Points to the SSL certificate used to encrypt IMAP and SMTP
  privatekey.pem:
    # Points to the SSL private key used to sign the certificate.
```

You can then build the container with:
```sh
docker-compose build
```
and run with:
```sh
docker start localmail
```

You may prefer to build and run it in an attached state, of course:
```sh
docker-compose up --build
```

Once the container is running, you should be able to send HTTP POST requests to `localhost:8080/send`,
and log in to your mailbox from an email client.