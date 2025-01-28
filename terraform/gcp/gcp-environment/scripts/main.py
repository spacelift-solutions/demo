# function/main.py

import googleapiclient.discovery
import os
import logging
import json
from googleapiclient.errors import HttpError
from flask import Request
from time import sleep
from typing import Callable, Dict, Tuple, Any

# Configure logging with more detailed format
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def retry_with_backoff(func: Callable, max_retries: int = 3) -> Any:
    """
    Retry a function with exponential backoff.
    
    Args:
        func: The function to retry
        max_retries: Maximum number of retry attempts
        
    Returns:
        The result of the function call
        
    Raises:
        Exception: If all retry attempts fail
    """
    for retry in range(max_retries):
        try:
            return func()
        except Exception as e:
            if retry == max_retries - 1:
                logger.error(f"All retry attempts failed: {str(e)}")
                raise
            sleep_time = (2 ** retry) + 1
            logger.warning(f"Attempt {retry + 1} failed. Retrying in {sleep_time} seconds...")
            sleep(sleep_time)

def validate_environment() -> Dict[str, str]:
    """
    Validate all required environment variables are set.
    
    Returns:
        Dict containing environment variables
        
    Raises:
        ValueError: If any required environment variable is missing
    """
    required_vars = {
        "PROJECT_ID": os.getenv('PROJECT_ID'),
        "REGION": os.getenv('REGION'),
        "GKE_CLUSTER": os.getenv('GKE_CLUSTER'),
        "SQL_INSTANCE": os.getenv('SQL_INSTANCE')
    }

    missing_vars = [var for var, value in required_vars.items() if not value]
    if missing_vars:
        raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")
        
    return required_vars

def init_google_clients() -> Tuple[Any, Any]:
    """
    Initialize Google API clients.
    
    Returns:
        Tuple of (container_service, sql_service)
        
    Raises:
        Exception: If client initialization fails
    """
    try:
        container_service = googleapiclient.discovery.build('container', 'v1')
        sql_service = googleapiclient.discovery.build('sqladmin', 'v1')
        return container_service, sql_service
    except Exception as e:
        logger.error(f"Failed to initialize Google API clients: {str(e)}")
        raise

def manage_gke_cluster(container_service: Any, project: str, region: str, 
                      cluster: str, action: str) -> None:
    """
    Manage GKE cluster nodes.
    
    Args:
        container_service: Google Container Engine service client
        project: GCP project ID
        region: GCP region
        cluster: GKE cluster name
        action: Either 'start' or 'stop'
    """
    node_count = 3 if action == 'start' else 0
    
    def modify_nodes():
        return container_service.projects().locations().clusters().nodePools().setSize(
            name=f'projects/{project}/locations/{region}/clusters/{cluster}/nodePools/default-pool',
            body={"nodeCount": node_count}
        ).execute()
    
    retry_with_backoff(modify_nodes)
    logger.info(f"Successfully {'scaled up' if action == 'start' else 'scaled down'} "
                f"GKE cluster {cluster}")

def manage_sql_instance(sql_service: Any, project: str, instance: str, 
                       action: str) -> None:
    """
    Manage Cloud SQL instance.
    
    Args:
        sql_service: Google Cloud SQL service client
        project: GCP project ID
        instance: SQL instance name
        action: Either 'start' or 'stop'
    """
    activation_policy = "ALWAYS" if action == 'start' else "NEVER"
    
    def modify_instance():
        return sql_service.instances().patch(
            project=project,
            instance=instance,
            body={"settings": {"activationPolicy": activation_policy}}
        ).execute()
    
    retry_with_backoff(modify_instance)
    logger.info(f"Successfully {'started' if action == 'start' else 'stopped'} "
                f"SQL instance {instance}")

def start_or_stop_resources(request: Request) -> Tuple[Dict[str, str], int]:
    """
    HTTP Cloud Function to manage GCP resources.
    
    Args:
        request: Flask request object
        
    Returns:
        Tuple of (response_dict, status_code)
    """
    try:
        # Validate environment variables
        env_vars = validate_environment()
        
        # Validate request content type
        if request.headers.get('content-type') != 'application/json':
            raise ValueError("Content-Type must be application/json")
        
        # Parse and validate request
        request_json = request.get_json(silent=True)
        logger.info(f"Received request body: {request_json}")
        
        if not request_json:
            raise ValueError("Request body is empty or not valid JSON")
            
        action = request_json.get('action')
        if not action:
            raise ValueError("'action' field is missing in request body")
            
        if action not in ['start', 'stop']:
            raise ValueError("Invalid action. Use 'start' or 'stop'")
        
        # Initialize API clients
        container_service, sql_service = init_google_clients()
        
        # Execute requested action
        logger.info(f"Starting {action} operation for resources in project {env_vars['PROJECT_ID']}")
        
        manage_gke_cluster(
            container_service, 
            env_vars['PROJECT_ID'], 
            env_vars['REGION'], 
            env_vars['GKE_CLUSTER'], 
            action
        )
        
        manage_sql_instance(
            sql_service, 
            env_vars['PROJECT_ID'], 
            env_vars['SQL_INSTANCE'], 
            action
        )
        
        success_msg = f"Successfully completed {action} operation"
        logger.info(success_msg)
        return {"message": success_msg}, 200
        
    except ValueError as e:
        error_msg = f"Request validation failed: {str(e)}"
        logger.error(error_msg)
        return {"error": error_msg}, 400
        
    except Exception as e:
        error_msg = f"Operation failed: {str(e)}"
        logger.error(error_msg)
        return {"error": error_msg}, 500