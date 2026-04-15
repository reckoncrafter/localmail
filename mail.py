from flask import Flask, request, jsonify
from email.message import EmailMessage
import subprocess
import os

app = Flask(__name__)

SENDMAIL = "/usr/sbin/sendmail"
TO_ADDR = "contact@mail.local"

@app.route('/send', methods=['POST'])
def send_mail():
    data = request.get_json(force=True)

    subject = data.get('subject', 'Contact Form')
    sender = data.get('from', 'webserver@mail.local')
    body = data.get('body', '')

    app.logger.info(f"Received email from {sender} with subject '{subject}'")

    if not body or len(body) > 5000:
        return jsonify({"error": "Invalid body"}, 400)
    
    msg = EmailMessage()
    msg['From'] = sender
    msg['To'] = TO_ADDR
    msg['Subject'] = subject
    msg.set_content(body)

    app.logger.info(f"Prepared email:\n{msg}")

    result = subprocess.run([SENDMAIL, '-t', '-oi'],
                   input=msg.as_bytes(),
                   check=True)
    
    return jsonify({"status": "sent"}, 200)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)