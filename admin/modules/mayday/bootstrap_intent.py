#!/usr/bin/env python3
"""Reconcile Intent project attachments until the provider supports them natively."""

import json
import os
import urllib.request


def reconcile(api, space, policy, integration):
    projects = api(
        """query {
          intentProjects {
            id
            name
            space { id }
            attachedPolicies { policyId }
            awsIntegrationIntentProjectAttachment { awsIntegration { id } }
          }
        }""",
        {},
    )["intentProjects"]
    matches = [p for p in projects if p["name"] == "Mayday license"]
    if len(matches) > 1:
        raise RuntimeError("Multiple Mayday license projects exist")
    if matches:
        project = matches[0]
        if project["space"]["id"] != space:
            raise RuntimeError("Mayday license project belongs to a different space")
    else:
        project = api(
            'mutation($space: ID!) { intentProjectCreate(name:"Mayday license", description:"Owns license/demo-license.json for Mayday. Bucket belongs to OpenTofu.", space:$space) { id } }',
            {"space": space},
        )["intentProjectCreate"]
    project_id = project["id"]
    if policy not in [p["policyId"] for p in project.get("attachedPolicies", [])]:
        api(
            "mutation($policy: ID!, $project: ID!) { policyIntentProjectAttach(id:$policy,intentProject:$project) { id } }",
            {"policy": policy, "project": project_id},
        )
    attachment = project.get("awsIntegrationIntentProjectAttachment")
    if attachment and attachment["awsIntegration"]["id"] != integration:
        raise RuntimeError("Mayday project has a different AWS integration")
    if not attachment:
        api(
            'mutation($project: ID!, $integration: ID!) { awsIntegrationIntentProjectAttach(intentProject:$project,integration:$integration,read:true,write:true,awsRegion:"us-east-1") { id } }',
            {"project": project_id, "integration": integration},
        )
    return project_id


def main():
    endpoint = os.environ.get(
        "SPACELIFT_API_KEY_ENDPOINT", "https://spacelift-solutions.app.spacelift.io"
    ).rstrip("/")
    if endpoint != "https://spacelift-solutions.app.spacelift.io":
        raise RuntimeError("Mayday bootstrap requires the solutions account endpoint")
    token = os.environ.get("SPACELIFT_API_TOKEN", "")

    def api(query, variables):
        headers = {"Content-Type": "application/json"}
        if token:
            headers["Authorization"] = "Bearer " + token
        req = urllib.request.Request(
            endpoint + "/graphql",
            data=json.dumps({"query": query, "variables": variables}).encode(),
            headers=headers,
        )
        with urllib.request.urlopen(req, timeout=30) as response:
            body = json.load(response)
        if body.get("errors"):
            raise RuntimeError("Spacelift rejected the Intent bootstrap operation")
        return body["data"]

    if not token:
        token = api(
            "mutation($id: ID!, $secret: String!) { apiKeyUser(id:$id,secret:$secret) { jwt } }",
            {
                "id": os.environ["SPACELIFT_API_KEY_ID"],
                "secret": os.environ["SPACELIFT_API_KEY_SECRET"],
            },
        )["apiKeyUser"]["jwt"]
    project_id = reconcile(
        api,
        os.environ["MAYDAY_INTENT_SPACE_ID"],
        os.environ["MAYDAY_INTENT_POLICY_ID"],
        os.environ["MAYDAY_AWS_INTEGRATION_ID"],
    )
    print("Mayday Intent project configured: " + project_id)


if __name__ == "__main__":
    main()
