import asyncio
import logging
import sys
import smtplib
from aiosmtpd.controller import Controller
from aiosmtpd.smtp import AuthResult, LoginPassword
from aiosmtpd.handlers import Debugging

class Authenticator:
    def __init__(self):
        self.passwd = "secure_password"

    def __call__(self, server, session, envelope, mechanism, auth_data):
        fail_nothandled = AuthResult(success=False, handled=False)
        if mechanism not in ("LOGIN", "PLAIN"):
            print("[SMTP AUTH] Error: not LOGIN PLAIN")
            return fail_nothandled
        if not isinstance(auth_data, LoginPassword):
            print("[SMTP AUTH] Error: Invalid auth data")
            return fail_nothandled
        username = auth_data.login
        password = auth_data.password
        if password != self.passwd:
            print("[SMTP AUTH] Error: Incorrect password.")
            return fail_nothandled
        return AuthResult(success=True)

async def amain(loop):
    cont = Controller(Debugging(), hostname='', port=2525, authenticator=Authenticator())
    cont.start()

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.create_task(amain(loop=loop))
    loop.run_forever()
