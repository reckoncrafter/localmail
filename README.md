# localmail

This is a work in progress.

Localmail is a docker container that provides a single HTTP API endpoint (`/send`)
which accepts an "email" in JSON format

```json
}
 "subject" "Subject",
 "body": "content..."
}
```

The "from" and "to" fields are irrelevant since the application only ever sends mail to and from itself.

These messages are dropped into a predefined Maildir, which is then served over IMAP by Dovecot.

This is not in a working state, and still contains many settings for debugging, such as a default plaintext password for the primary IMAP user.
