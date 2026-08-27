import asyncio
from dotenv import load_dotenv
import os
import httpx

load_dotenv()

async def test_sms():
    phone = "7569463687"
    otp = "12345"
    message = f"Welcome to AM5ROYAL! Your OTP for registration is {otp}. Please enter this code to complete your sign-up. Do not share this code with anyone. Thank you for choosing AM5ROYAL!"
    
    url = "https://sms.mytext.in/websms/sendsms.aspx"
    params = {
        "userid": os.getenv("SMS_USER_ID"),
        "password": os.getenv("SMS_PASSWORD"),
        "sender": os.getenv("SMS_SENDER_ID"),
        "mobileno": phone,
        "msg": message,
        "msgtype": "0",  # Short Plain Text
        "peid": os.getenv("SMS_PEID"),
        "tpid": os.getenv("SMS_OTP_TPID")
    }
    
    print(f"Sending with params: {params}")
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params)
            response.raise_for_status()
            text = response.text
            print(f"Response: {text}")
    except Exception as e:
        print(f"Error: {e}")

asyncio.run(test_sms())
