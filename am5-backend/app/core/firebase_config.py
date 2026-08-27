import firebase_admin
from firebase_admin import credentials
import os

def init_firebase():
    if not firebase_admin._apps:
        # Construct the absolute path to serviceAccountKey.json
        # Since this file is in app/core, we go up one level to app/
        current_dir = os.path.dirname(os.path.abspath(__file__))
        app_dir = os.path.dirname(current_dir)
        cred_path = os.path.join(app_dir, "serviceAccountKey.json")
        
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("Firebase Admin SDK initialized successfully.")
        else:
            print(f"Warning: serviceAccountKey.json not found at {cred_path}. Push notifications will not work.")
