const axios = require('axios');

async function testUserService() {
    try {
        const response = await axios.get('http://localhost:5000/users');
        console.log('User service test passed:', response.data);
    } catch (error) {
        console.error('User service test failed:', error.message);
    }
}

testUserService();