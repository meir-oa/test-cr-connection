import os
from flask import Flask, request, jsonify
import google.auth.transport.requests
import google.oauth2.id_token
import requests
import json

app = Flask(__name__)

# Configuration
SERVICE_B_URL = os.getenv('SERVICE_B_URL', 'https://service-b-m7t2o2ljoa-ew.a.run.app')  # Replace with actual URL
SERVICE_B_AUDIENCE = SERVICE_B_URL

def make_authorized_post_request(endpoint, audience, data):
    """Makes an authorized POST request to another Cloud Run service"""
    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, audience)

    headers = {
        'Authorization': f'Bearer {id_token}',
        'Content-Type': 'application/json',
    }

    response = requests.post(
        endpoint,
        headers=headers,
        json=data
    )
    return response

def verify_token(request):
    """Verifies the incoming token"""
    if 'Authorization' not in request.headers:
        return None

    token = request.headers['Authorization'].split(' ').pop()

    try:
        auth_req = google.auth.transport.requests.Request()
        claims = google.oauth2.id_token.verify_oauth2_token(
            token, auth_req)
        return claims
    except Exception as e:
        print(f"Token verification failed: {str(e)}")
        return None

@app.route('/send-to-b', methods=['POST'])
def send_to_b():
    """Endpoint to send data to Service B"""
    try:
        data = request.get_json()
        response = make_authorized_post_request(
            f"{SERVICE_B_URL}/receive-from-a",
            SERVICE_B_AUDIENCE,
            data
        )
        return jsonify({"status": "success", "response": response.json()}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/receive-from-b', methods=['POST'])
def receive_from_b():
    """Endpoint to receive data from Service B"""
    claims = verify_token(request)
    if not claims:
        return jsonify({"status": "error", "message": "Unauthorized"}), 401

    try:
        data = request.get_json()
        # Process the received data
        processed_data = {
            "message": f"Data received by Service A by pinging {SERVICE_B_URL}",
            "received_data": data
        }
        return jsonify(processed_data), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
