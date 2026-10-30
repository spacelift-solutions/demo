#!/usr/bin/env python3
"""Reconcile project access until flows_project_id ships in the provider."""

import json
import os
import urllib.request


def reconcile(api, project_id, space_id, role_id):
    projects = api(
        "query { flowsProjects { id name roleBindings { id space { id } role { id } } } }",
        {},
    )["flowsProjects"]
    project = next((p for p in projects if p["id"] == project_id), None)
    if not project or project["name"] != "Mayday":
        raise RuntimeError("Expected the Mayday Flows project in the solutions account")
    bindings = project["roleBindings"]
    matches = [
        b
        for b in bindings
        if b["space"]["id"] == space_id and b["role"]["id"] == role_id
    ]
    # This demo has one deliberately scoped binding. Do not silently retain or
    # remove unexpected grants when adopting a manually configured project.
    if len(bindings) != len(matches) or len(matches) > 1:
        raise RuntimeError(
            "Unexpected Mayday project role bindings; review access first"
        )
    if matches:
        return matches[0]["id"]
    result = api(
        """mutation($input: FlowsProjectRoleBindingBatchInput!) {
          flowsProjectRoleBindingBatchCreate(input:$input) { id }
        }""",
        {
            "input": {
                "bindings": [
                    {
                        "flowsProjectID": project_id,
                        "spaceID": space_id,
                        "roleID": role_id,
                    }
                ]
            }
        },
    )["flowsProjectRoleBindingBatchCreate"]
    if len(result) != 1:
        raise RuntimeError("Expected exactly one Mayday project role binding")
    return result[0]["id"]


def main():
    # Administrative run tokens can manage space role bindings. No persistent
    # recovery API key or additional bootstrap credential is needed.
    token = os.environ["SPACELIFT_API_TOKEN"]

    def api(query, variables):
        request = urllib.request.Request(
            "https://spacelift-solutions.app.spacelift.io/graphql",
            data=json.dumps({"query": query, "variables": variables}).encode(),
            headers={
                "Content-Type": "application/json",
                "Authorization": "Bearer " + token,
            },
        )
        with urllib.request.urlopen(request, timeout=30) as response:
            body = json.load(response)
        if body.get("errors"):
            # Error text can echo inputs. Keep credentials out of runner logs.
            raise RuntimeError("Spacelift rejected the Mayday project access operation")
        return body["data"]

    binding = reconcile(
        api,
        os.environ["MAYDAY_FLOWS_PROJECT_ID"],
        os.environ["MAYDAY_FLOWS_SPACE_ID"],
        os.environ["MAYDAY_FLOWS_ROLE_ID"],
    )
    print("Mayday Flows project access configured: " + binding)


if __name__ == "__main__":
    main()
