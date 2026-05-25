# notify_logger.py

import smtplib
from email.mime.text import MIMEText

SUPPORT_EMAIL = "the_email_that_receives_alerts@example.com"

SENDER_EMAIL = "arjun1532006@gmail.com"
SENDER_PASSWORD = "wgfqjgxcqgwpbnpc"

def send_failure(message):
    msg = MIMEText(message)
    msg["Subject"] = "NPO ETL Staging Load Failure"
    msg["From"] = "etl-system@npo.com"
    msg["To"] = SUPPORT_EMAIL

    # Basic SMTP example (adjust to your environment)
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        server.sendmail(msg["From"], [SUPPORT_EMAIL], msg.as_string())