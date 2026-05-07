from fastapi import FastAPI

app = FastAPI()

products = [
    {'id': 1, 'name': 'Laptop', 'price': 1000},
    {'id': 2, 'name': 'Phone', 'price': 500}
]

@app.get("/products")
def get_products():
    return products

@app.get("/products/{product_id}")
def get_product(product_id: int):
    product = next((p for p in products if p['id'] == product_id), None)
    if product:
        return product
    return {"error": "Product not found"}