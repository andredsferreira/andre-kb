import smtplib
from email.message import EmailMessage

EMAIL_ADDRESS = 'andredsferreira1@gmail.com'
# App password configured in google account (not gmail account password)
EMAIL_PASSWORD = 'tdso pnrr zxgh rytx'  

msg = EmailMessage()
msg['Subject'] = 'Test Email to Myself'
msg['From'] = EMAIL_ADDRESS
msg['To'] = EMAIL_ADDRESS  # Send to yourself
msg.set_content('This is a test email sent to myself from Python!')

with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
    smtp.ehlo()
    smtp.starttls()
    smtp.ehlo()

    smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
    smtp.send_message(msg)

print("Email sent!")
