# localmail

> This is a work in progress.
>
> While the API and local mailbox work, IMAP is not set up properly.

Localmail is a docker container that provides a single HTTP API endpoint (`/send`)
which accepts an "email" in JSON format

```json
{
 "subject": "Form Submission Notification",
 "from": "user@mail.com",
 "body": "content..."
}
```
The purpose of this application is to provide a web server with an extremely simple means of collecting HTML form submissions and making them
available to the webmaster in a convenient way, i.e. IMAP.

If the HTML form is only there to collect simple, human-readable data, like a contact form, it can be turned into an "email" by the webserver and
deposited in a local mailbox which is exposed to IMAP by Dovecot.

In this case, I am using it for a contact form, and taking advantage of the "from" field, presenting the "emails" as though they
actually came from the address put into the form, even though it is fabricated entirely by the web server.

If you have docker installed, the container can be built with:
```sh
docker-compose build
```
and run with:
```sh
docker start localmail
```

You may prefer to build and run it in an attached state, of course:
```sh
docker-compuse up --build
```

Once the container is running, you can try and modify the two included testing scripts
- `curl.sh` runs a curl command that POSTs a json document to localhost:8080/send
- `open_mutt.sh` opens the included `mutt` utility inside the container at the default Maildir location.