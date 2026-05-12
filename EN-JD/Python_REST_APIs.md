# Python + REST APIs

Very important for this JD.

## REST API Basics

- **What is REST API**: Architectural style for web services using HTTP. Stateless, client-server.
- **HTTP Methods**: GET (retrieve), POST (create), PUT (update), DELETE (remove).
- **Status Codes**: 200 OK, 404 Not Found, 500 Internal Server Error, 401 Unauthorized.

## Frameworks

### Flask/FastAPI Basics
- **Flask**: Lightweight, use decorators for routes.
- **FastAPI**: Modern, async support, auto docs.

Example Flask App:
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run()
```

Example FastAPI App:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}
```

## requests Module

- **Usage**: Send HTTP requests.
- **Example**:
```python
import requests

response = requests.get('https://api.example.com/data')
if response.status_code == 200:
    data = response.json()
    print(data)
else:
    print(f"Error: {response.status_code}")
```

## JSON Parsing

- Use `json` module: `import json; data = json.loads(response.text)`

## Exception Handling

- Handle errors: `try: ... except requests.RequestException as e: print(e)`

## Key Concepts

- **GET vs POST**: GET for safe reads, POST for changes.
- **Synchronous vs Asynchronous**: Sync waits for response; async uses callbacks/promises.
- **Virtual Environment**: Isolate dependencies with `python -m venv env; env\Scripts\activate`.

## Real-Time Scenarios

- **Scenario 1**: Fetch user data from API. Handle pagination: Loop with offset.
- **Scenario 2**: Post form data. Use `requests.post(url, data=payload)`.
- **Scenario 3**: API rate limiting. Implement retries with `time.sleep` on 429 status.
- **Scenario 4**: Authentication. Add headers: `headers = {'Authorization': 'Bearer token'}`.
- **Scenario 5**: Error handling in production. Log errors and retry on failures.