import googleapiclient.discovery
import os
import logging
from googleapiclient.errors import HttpError
from flask import Request  # Flask is used as the framework for GCP Cloud Functions

# Configure logging for the Cloud Function
logging.basicConfig(level=logging.INFO)

def start_or_stop_resources(request: Request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
    Returns:
        A response string and status code.
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

    # Check if all environment variables are set
    for var_name, value in required_env_vars.items():
        if not value:
            logging.error(f"Environment variable '{var_name}' is not set.")
            return f"Error: Environment variable '{var_name}' is required but not set.", 500

    # Extract action from request body
    try:
        action = request.get_json().get('action')
    except Exception as e:
        logging.error(f"Failed to parse request JSON: {e}")
        return "Error: Failed to parse request JSON", 400

    if action not in ['start', 'stop']:
        logging.error("Invalid action received. Use 'start' or 'stop'.")
        return "Invalid action. Use 'start' or 'stop'.", 400

    # Initialize Google API clients
    try:
        container_service = googleapiclient.discovery.build('container', 'v1')
        sql_service = googleapiclient.discovery.build('sqladmin', 'v1')
    except HttpError as e:
        logging.error(f"Error creating Google API clients: {e}")
        return f"Error: Unable to initialize Google API clients: {e}", 500

    # Perform start or stop actions
    try:
        if action == 'start':
            logging.info(f"Starting resources: GKE cluster '{gke_cluster}' and SQL instance '{sql_instance}'")

            # Start GKE cluster node pool (set size to 3)
            container_service.projects().locations().clusters().nodePools().setSize(
                name=f'projects/{project}/locations/{region}/clusters/{gke_cluster}/nodePools/default-pool',
                body={"nodeCount": 3}
            ).execute()

            # Set Cloud SQL activation policy to ALWAYS
            sql_service.instances().patch(
                project=project,
                instance=sql_instance,
                body={"settings": {"activationPolicy": "ALWAYS"}}
            ).execute()

            logging.info(f"Successfully started resources: GKE cluster '{gke_cluster}' and SQL instance '{sql_instance}'")

        elif action == 'stop':
            logging.info(f"Stopping resources: GKE cluster '{gke_cluster}' and SQL instance '{sql_instance}'")

            # Scale GKE node pool to 0 nodes
            container_service.projects().locations().clusters().nodePools().setSize(
                name=f'projects/{project}/locations/{region}/clusters/{gke_cluster}/nodePools/default-pool',
                body={"nodeCount": 0}
            ).execute()

            # Set Cloud SQL activation policy to NEVER
            sql_service.instances().patch(
                project=project,
                instance=sql_instance,
                body={"settings": {"activationPolicy": "NEVER"}}
            ).execute()

            logging.info(f"Successfully stopped resources: GKE cluster '{gke_cluster}' and SQL instance '{sql_instance}'")

    except HttpError as e:
        logging.error(f"An error occurred during {action} action: {e}")
        return f"An error occurred: {e}", 500

    return f"Action '{action}' successfully performed.", 200
