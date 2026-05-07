import os
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
import asyncio
import psycopg2
import logging

app = FastAPI()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Payment(BaseModel):
    order_id: int
    amount: float
    payment_method: str

@app.get("/health")
async def health():
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            database=os.getenv('DB_NAME', 'payments'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        conn.close()
        return {"status": "healthy"}
    except:
        return {"status": "unhealthy"}, 503

@app.get("/payments")
async def get_payments():
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            database=os.getenv('DB_NAME', 'payments'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        cur = conn.cursor()
        cur.execute('SELECT * FROM payments')
        columns = [desc[0] for desc in cur.description]
        payments = [dict(zip(columns, row)) for row in cur.fetchall()]
        cur.close()
        conn.close()
        return payments
    except Exception as e:
        logger.error(f"Error fetching payments: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/payments")
async def process_payment(payment: Payment):
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            database=os.getenv('DB_NAME', 'payments'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO payments (order_id, amount, status, created_at) VALUES (%s, %s, %s, %s) RETURNING id',
            (payment.order_id, payment.amount, 'processed', datetime.utcnow())
        )
        payment_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        
        # Publish payment event (mock)
        logger.info(f"Payment processed: order_id={payment.order_id}, payment_id={payment_id}")
        
        return {"id": payment_id, "status": "processed"}
    except Exception as e:
        logger.error(f"Error processing payment: {e}")
        raise HTTPException(status_code=500, detail=str(e))
