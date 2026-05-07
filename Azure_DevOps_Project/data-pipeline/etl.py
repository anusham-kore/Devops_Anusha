import pandas as pd
from azure.storage.blob import BlobServiceClient
import os

# Simulate data extraction (in real scenario, from DB)
orders = pd.DataFrame({
    'order_id': [1, 2, 3],
    'user_id': [1, 2, 1],
    'product_id': [1, 2, 1],
    'quantity': [1, 2, 1],
    'price': [1000, 500, 1000]
})

# Transform: Calculate total
orders['total'] = orders['quantity'] * orders['price']

# Load to Azure Blob Storage
account_url = os.getenv('AZURE_STORAGE_ACCOUNT_URL')
credential = os.getenv('AZURE_STORAGE_CREDENTIAL')
blob_service_client = BlobServiceClient(account_url=account_url, credential=credential)
blob_client = blob_service_client.get_blob_client(container="data", blob="processed_orders.csv")
blob_client.upload_blob(orders.to_csv(index=False), overwrite=True)

print("ETL completed")