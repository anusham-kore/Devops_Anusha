const axios = require('axios');

async function testNotificationService() {
    try {
        // Test health endpoint
        const healthResponse = await axios.get('http://localhost:5003/health');
        console.log('Notification service health check passed:', healthResponse.data);

        // Test send notification endpoint
        const sendResponse = await axios.post('http://localhost:5003/notifications/send');
        console.log('Notification service send test passed:', sendResponse.data);
    } catch (error) {
        console.error('Notification service test failed:', error.message);
    }
}

testNotificationService();