import os

# Get the list of all environment variables
env_vars = os.environ

# Print the variables
for var, value in env_vars.items():
    print(f"{var}: {value}")

project_name = os.getenv('GCP_PROJECT_NAME')
dataset_name = os.getenv('BIQ_QUERY_DATASET_STG')
table_name = os.getenv('BIG_QUERY_TABLE_NAME_STG')
table_id = f'{project_name}.{dataset_name}.{table_name}'
print(os.getenv('BIQ_QUERY_DATASET_STG'))