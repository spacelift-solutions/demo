import googleapiclient.discovery
import os
import logging
from googleapiclient.errors import HttpError
from flask import Request
from time import sleep

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def retry_with_backoff(func, max_retries=3):
    """Retry a function with exponential backoff."""
    for retry in range(max_retries):
        try:
            return func()
        except Exception as e:
            if retry == max_retries - 1:
                raise
            sleep_time = (2 ** retry) + 1
            logger.warning(f"Attempt {retry + 1} failed. Retrying in {sleep_time} seconds...")
            sleep(sleep_time)

def start_or_stop_resources(request: Request):
    """HTTP Cloud Function to manage GCP resources.
    Args:
        request (flask.Request): The request object.
    Returns:
        tuple: A response string and status code.
    """
    
    # Get environment variables
    project = os.getenv('PROJECT_ID')
    region = os.getenv('REGION')
    gke_cluster = os.getenv('GKE_CLUSTER')
    sql_instance = os.getenv('SQL_INSTANCE')

    # Validate environment variables
    required_env_vars = {
        "PROJECT_ID": project,
        "REGION": region,
        "GKE_CLUSTER": gke_cluster,
        "SQL_INSTANCE": sql_instance
    }

    for var_name, value in required_env_vars.items():
        if not value:
            error_msg = f"Environment variable '{var_name}' is not set"
            logger.error(error_msg)
            return {"error": error_msg}, 500

    # Extract action from request
    try:
        request_json = request.get_json(silent=True)
        if not request_json:
            raise ValueError("Request body is empty")
        action = request_json.get('action')
        if not action:
            raise ValueError("'action' field is missing")
    except Exception as e:
        error_msg = f"Failed to parse request: {str(e)}"
        logger.error(error_msg)
        return {"error": error_msg}, 400

    if action not in ['start', 'stop']:
        error_msg = "Invalid action. Use 'start' or 'stop'"
        logger.error(error_msg)
        return {"error": error_msg}, 400

    # Initialize API clients
    try:
        container_service = googleapiclient.discovery.build('container', 'v1')
        sql_service = googleapiclient.discovery.build('sqladmin', 'v1')
    except Exception as e:
        error_msg = f"Failed to initialize Google API clients: {str(e)}"
        logger.error(error_msg)
        return {"error": error_msg}, 500

    try:
        if action == 'start':
            logger.info(f"Starting resources in project {project}")
            
            # Start GKE cluster
            def start_gke():
                return container_service.projects().locations().clusters().nodePools().setSize(
                    name=f'projects/{project}/locations/{region}/clusters/{gke_cluster}/nodePools/default-pool',
                    body={"nodeCount": 3}
                ).execute()
            
            retry_with_backoff(start_gke)
            logger.info(f"Successfully scaled up GKE cluster {gke_cluster}")

            # Start Cloud SQL
            def start_sql():
                return sql_service.instances().patch(
                    project=project,
                    instance=sql_instance,
                    body={"settings": {"activationPolicy": "ALWAYS"}}
                ).execute()
            
            retry_with_backoff(start_sql)
            logger.info(f"Successfully started SQL instance {sql_instance}")

        elif action == 'stop':
            logger.info(f"Stopping resources in project {project}")
            
            # Stop GKE cluster
            def stop_gke():
                return container_service.projects().locations().clusters().nodePools().setSize(
                    name=f'projects/{project}/locations/{region}/clusters/{gke_cluster}/nodePools/default-pool',
                    body={"nodeCount": 0}
                ).execute()
            
            retry_with_backoff(stop_gke)
            logger.info(f"Successfully scaled down GKE cluster {gke_cluster}")

            # Stop Cloud SQL
            def stop_sql():
                return sql_service.instances().patch(
                    project=project,
                    instance=sql_instance,
                    body={"settings": {"activationPolicy": "NEVER"}}
                ).execute()
            
            retry_with_backoff(stop_sql)
            logger.info(f"Successfully stopped SQL instance {sql_instance}")

    except Exception as e:
        error_msg = f"Failed to {action} resources: {str(e)}"
        logger.error(error_msg)
        return {"error": error_msg}, 500

    success_msg = f"Successfully completed {action} operation"
    logger.info(success_msg)
    return {"message": success_msg}, 200