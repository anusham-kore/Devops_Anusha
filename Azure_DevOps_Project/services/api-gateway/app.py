import os
from flask import Flask, request, jsonify
import requests
import logging
from functools import wraps
import jwt

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Service URLs
USER_SERVICE_URL = os.getenv('USER_SERVICE_URL', 'http://user-service')
PRODUCT_SERVICE_URL = os.getenv('PRODUCT_SERVICE_URL', 'http://product-service')
ORDER_SERVICE_URL = os.getenv('ORDER_SERVICE_URL', 'http://order-service')
PAYMENT_SERVICE_URL = os.getenv('PAYMENT_SERVICE_URL', 'http://payment-service')

def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return jsonify({'error': 'Missing authorization header'}), 401
        try:
            token = auth_header.split(' ')[1]
            # In production, verify JWT token
            logger.info(f"Token validated: {token[:20]}...")
        except Exception as e:
            return jsonify({'error': 'Invalid token'}), 401
        return f(*args, **kwargs)
    return decorated_function

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

# User Service Routes
@app.route('/api/users', methods=['GET'])
@require_auth
def get_users():
    try:
        response = requests.get(f'{USER_SERVICE_URL}/users', timeout=5)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.error(f"Error calling user service: {e}")
        return jsonify({'error': 'User service unavailable'}), 503

@app.route('/api/users/<user_id>', methods=['GET'])
@require_auth
def get_user(user_id):
    try:
        response = requests.get(f'{USER_SERVICE_URL}/users/{user_id}', timeout=5)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.error(f"Error calling user service: {e}")
        return jsonify({'error': 'User service unavailable'}), 503

# Product Service Routes
@app.route('/api/products', methods=['GET'])
def get_products():
    try:
        response = requests.get(f'{PRODUCT_SERVICE_URL}/products', timeout=5)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.error(f"Error calling product service: {e}")
        return jsonify({'error': 'Product service unavailable'}), 503

# Order Service Routes
@app.route('/api/orders', methods=['GET'])
@require_auth
def get_orders():
    try:
        response = requests.get(f'{ORDER_SERVICE_URL}/orders', timeout=5)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.error(f"Error calling order service: {e}")
        return jsonify({'error': 'Order service unavailable'}), 503

@app.route('/api/orders', methods=['POST'])
@require_auth
def create_order():
    try:
        data = request.json
        response = requests.post(f'{ORDER_SERVICE_URL}/orders', json=data, timeout=5)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.error(f"Error calling order service: {e}")
        return jsonify({'error': 'Order service unavailable'}), 503

# Payment Service Routes
@app.route('/api/payments', methods=['POST'])
@require_auth
def process_payment():
    try:
        data = request.json
        response = requests.post(f'{PAYMENT_SERVICE_URL}/payments', json=data, timeout=5)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.error(f"Error calling payment service: {e}")
        return jsonify({'error': 'Payment service unavailable'}), 503

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)