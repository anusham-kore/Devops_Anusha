import os
import json
import pika
import logging
from flask import Flask, jsonify

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def connect_rabbitmq():
    try:
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(os.getenv('RABBITMQ_HOST', 'rabbitmq'))
        )
        return connection
    except Exception as e:
        logger.error(f"RabbitMQ connection error: {e}")
        return None

@app.route('/health', methods=['GET'])
def health():
    try:
        conn = connect_rabbitmq()
        if conn:
            conn.close()
            return jsonify({'status': 'healthy'}), 200
    except:
        pass
    return jsonify({'status': 'unhealthy'}), 503

@app.route('/notifications/send', methods=['POST'])
def send_notification():
    try:
        conn = connect_rabbitmq()
        if not conn:
            return jsonify({'error': 'RabbitMQ unavailable'}), 503
        
        channel = conn.channel()
        channel.queue_declare(queue='notifications', durable=True)
        
        notification = {
            'type': 'order_confirmation',
            'user_id': 1,
            'message': 'Your order has been placed'
        }
        
        channel.basic_publish(
            exchange='',
            routing_key='notifications',
            body=json.dumps(notification),
            properties=pika.BasicProperties(delivery_mode=2)
        )
        
        conn.close()
        return jsonify({'status': 'sent'}), 200
    except Exception as e:
        logger.error(f"Error sending notification: {e}")
        return jsonify({'error': str(e)}), 500

def process_notifications():
    conn = connect_rabbitmq()
    if not conn:
        logger.error("Cannot connect to RabbitMQ")
        return
    
    channel = conn.channel()
    channel.queue_declare(queue='notifications', durable=True)
    
    def callback(ch, method, properties, body):
        notification = json.loads(body)
        logger.info(f"Processing notification: {notification}")
        ch.basic_ack(delivery_tag=method.delivery_tag)
    
    channel.basic_consume(queue='notifications', on_message_callback=callback)
    logger.info("Waiting for notifications...")
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        channel.stop_consuming()
        conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)