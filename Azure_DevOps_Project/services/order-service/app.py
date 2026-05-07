import os
import json
from flask import Flask, jsonify, request
from datetime import datetime
import psycopg2
from psycopg2.extras import RealDictCursor
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database connection
def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            database=os.getenv('DB_NAME', 'orders'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection error: {e}")
        raise

# Health check
@app.route('/health', methods=['GET'])
def health():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({'status': 'healthy'}), 200
    except:
        return jsonify({'status': 'unhealthy'}), 503

@app.route('/orders', methods=['GET'])
def get_orders():
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM orders')
        orders = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify([dict(row) for row in orders]), 200
    except Exception as e:
        logger.error(f"Error fetching orders: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/orders/<order_id>', methods=['GET'])
def get_order(order_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute('SELECT * FROM orders WHERE id = %s', (order_id,))
        order = cur.fetchone()
        cur.close()
        conn.close()
        if order:
            return jsonify(dict(order)), 200
        return jsonify({'error': 'Order not found'}), 404
    except Exception as e:
        logger.error(f"Error fetching order: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/orders', methods=['POST'])
def create_order():
    try:
        data = request.json
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO orders (user_id, product_id, quantity, status, created_at) VALUES (%s, %s, %s, %s, %s) RETURNING id',
            (data['user_id'], data['product_id'], data['quantity'], 'pending', datetime.utcnow())
        )
        order_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'id': order_id, 'status': 'created'}), 201
    except Exception as e:
        logger.error(f"Error creating order: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)