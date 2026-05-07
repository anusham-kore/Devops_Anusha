# Python & Backend Services

Focus: REST APIs, microservices, production experience.

## Key Concepts
- **REST APIs**: Stateless, HTTP-based. Methods: GET, POST, PUT, DELETE. Status codes: 200, 404, 500.
- **Microservices**: Independent services communicating via APIs.
- **Frameworks**: Flask (simple), FastAPI (async, docs).

## Code Examples
Flask API:
```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/users', methods=['GET'])
def get_users():
    return jsonify({'users': [{'id': 1, 'name': 'John'}]})

if __name__ == '__main__':
    app.run(debug=True)
```

FastAPI with async:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/items/{item_id}")
async def read_item(item_id: int):
    return {"item_id": item_id}
```

## Real-Time Scenarios
- **Scenario 1**: Build a REST API for user management. Handle authentication with JWT.
- **Scenario 2**: Microservice communication. Use requests for inter-service calls.
- **Scenario 3**: Error handling. Implement try-except for API failures.
- **Scenario 4**: Production deployment. Use Gunicorn for Flask, handle concurrency.