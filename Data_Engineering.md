# Data Engineering

Focus: ETL, pipelines, data validation.

## Key Concepts
- **ETL**: Extract, Transform, Load. Move data from sources to destinations.
- **Pipelines**: Automated workflows for data processing.
- **Data Validation**: Ensure data quality (e.g., schema checks, null values).

## Tools
- Python libraries: Pandas, PySpark.
- Frameworks: Apache Airflow for pipelines.

## Code Examples
Simple ETL with Pandas:
```python
import pandas as pd

# Extract
data = pd.read_csv('source.csv')

# Transform
data['new_column'] = data['old_column'] * 2

# Load
data.to_csv('destination.csv')
```

Airflow DAG example:
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def extract():
    # Extract logic

def transform():
    # Transform logic

dag = DAG('etl_pipeline', start_date=datetime(2023,1,1))
extract_task = PythonOperator(task_id='extract', python_callable=extract, dag=dag)
```

## Real-Time Scenarios
- **Scenario 1**: Ingest data from API. Use requests to fetch, validate JSON schema.
- **Scenario 2**: Pipeline failure. Implement retries and logging.
- **Scenario 3**: Data validation. Check for duplicates, handle missing values.
- **Scenario 4**: Scalable processing. Use PySpark for large datasets.