import googleapiclient.discovery
import os

def start_or_stop_resources(request):
    action = request.get_json().get('action')
    project = os.getenv('PROJECT_ID')
    region = os.getenv('REGION')
    gke_cluster = os.getenv('GKE_CLUSTER')
    sql_instance = os.getenv('SQL_INSTANCE')

    container_service = googleapiclient.discovery.build('container', 'v1')
    sql_service = googleapiclient.discovery.build('sqladmin', 'v1')

    if action == 'start':
        # Start GKE cluster
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
    elif action == 'stop':
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
    else:
        raise ValueError("Invalid action. Use 'start' or 'stop'.")