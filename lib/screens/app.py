from flask import Flask, request, jsonify
from random import randint
from firebase_admin import firestore, initialize_app

app = Flask(__name__)
initialize_app()

db = firestore.client()

@app.route('/send-otp', methods=['POST'])
def send_otp():
    phone = request.form.get('phone')
    otp = randint(1000, 9999)
    
    # Save OTP in Firestore
    db.collection('otps').document(phone).set({'otp': str(otp)})
    
    # Here you should integrate your SMS sending service
    # For now, we'll just print the OTP
    print(f"Sending OTP {otp} to {phone}")
    
    return jsonify({'status': 'success'}), 200

if __name__ == '__main__':
    app.run(debug=True)
