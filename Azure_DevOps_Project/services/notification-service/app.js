const express = require('express');
const amqp = require('amqplib');
const app = express();
const port = 5003;

app.use(express.json());

const RABBITMQ_HOST = process.env.RABBITMQ_HOST || 'rabbitmq';

async function connectRabbitMQ() {
    try {
        const connection = await amqp.connect(`amqp://${RABBITMQ_HOST}`);
        return connection;
    } catch (error) {
        console.error('RabbitMQ connection error:', error);
        return null;
    }
}

app.get('/health', async (req, res) => {
    try {
        const conn = await connectRabbitMQ();
        if (conn) {
            await conn.close();
            res.json({ status: 'healthy' });
        } else {
            res.status(503).json({ status: 'unhealthy' });
        }
    } catch (error) {
        res.status(503).json({ status: 'unhealthy' });
    }
});

app.post('/notifications/send', async (req, res) => {
    try {
        const conn = await connectRabbitMQ();
        if (!conn) {
            return res.status(503).json({ error: 'RabbitMQ unavailable' });
        }

        const channel = await conn.createChannel();
        await channel.assertQueue('notifications', { durable: true });

        const notification = {
            type: 'order_confirmation',
            user_id: 1,
            message: 'Your order has been placed',
            timestamp: new Date().toISOString()
        };

        channel.sendToQueue('notifications', Buffer.from(JSON.stringify(notification)), {
            persistent: true
        });

        await channel.close();
        await conn.close();

        res.json({ status: 'sent' });
    } catch (error) {
        console.error('Error sending notification:', error);
        res.status(500).json({ error: error.message });
    }
});

async function processNotifications() {
    const conn = await connectRabbitMQ();
    if (!conn) {
        console.error('Cannot connect to RabbitMQ');
        return;
    }

    const channel = await conn.createChannel();
    await channel.assertQueue('notifications', { durable: true });

    console.log('Waiting for notifications...');

    channel.consume('notifications', (msg) => {
        if (msg !== null) {
            const notification = JSON.parse(msg.content.toString());
            console.log('Processing notification:', notification);
            channel.ack(msg);
        }
    });
}

app.listen(port, '0.0.0.0', () => {
    console.log(`Notification service listening on port ${port}`);
    // Start processing notifications
    processNotifications();
});