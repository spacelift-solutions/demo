import importlib.util
import io
import json
import os
import unittest
from pathlib import Path
from typing import ClassVar
from unittest.mock import patch

from graphql import parse

spec = importlib.util.spec_from_file_location(
    "bootstrap", Path(__file__).parents[1] / "bootstrap_intent.py"
)
bootstrap = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bootstrap)


class BootstrapTest(unittest.TestCase):
    environment: ClassVar[dict[str, str]] = {
        "SPACELIFT_API_TOKEN": "administrative-run-token",
        "MAYDAY_BOOTSTRAP_API_KEY_ID": "bootstrap-key-id",
        "MAYDAY_BOOTSTRAP_API_KEY_SECRET": "bootstrap-key-secret",
        "MAYDAY_INTENT_SPACE_ID": "space",
        "MAYDAY_INTENT_POLICY_ID": "policy",
        "MAYDAY_AWS_INTEGRATION_ID": "aws",
    }

    def test_api_key_session_is_used_instead_of_run_token(self):
        calls = []

        def urlopen(request, timeout):
            body = json.loads(request.data)
            parse(body["query"])
            calls.append(request)
            if "apiKeyUser" in body["query"]:
                self.assertIsNone(request.get_header("Authorization"))
                self.assertEqual(body["variables"]["secret"], "bootstrap-key-secret")
                data = {"apiKeyUser": {"jwt": "api-key-session"}}
            else:
                self.assertEqual(
                    request.get_header("Authorization"), "Bearer api-key-session"
                )
                data = {
                    "intentProjects": [
                        {
                            "id": "project",
                            "name": "Mayday license",
                            "space": {"id": "space"},
                            "attachedPolicies": [{"policyId": "policy"}],
                            "awsIntegrationIntentProjectAttachment": {
                                "awsIntegration": {"id": "aws"}
                            },
                        }
                    ]
                }
            return io.BytesIO(json.dumps({"data": data}).encode())

        with (
            patch.dict(os.environ, self.environment, clear=True),
            patch.object(bootstrap.urllib.request, "urlopen", side_effect=urlopen),
            patch("sys.stdout", new_callable=io.StringIO),
        ):
            bootstrap.main()
        self.assertEqual(len(calls), 2)

    def test_api_errors_are_reported_without_credentials(self):
        response = {
            "errors": [{"message": "rejected bootstrap-key-id bootstrap-key-secret"}]
        }
        with (
            patch.dict(os.environ, self.environment, clear=True),
            patch.object(
                bootstrap.urllib.request,
                "urlopen",
                return_value=io.BytesIO(json.dumps(response).encode()),
            ),
            self.assertRaises(RuntimeError) as raised,
        ):
            bootstrap.main()
        self.assertIn("rejected", str(raised.exception))
        self.assertNotIn("bootstrap-key-id", str(raised.exception))
        self.assertNotIn("bootstrap-key-secret", str(raised.exception))

    def test_existing_project_is_idempotent(self):
        calls = []

        def api(query, variables):
            parse(query)
            calls.append(query)
            return {
                "intentProjects": [
                    {
                        "id": "project",
                        "name": "Mayday license",
                        "space": {"id": "space"},
                        "attachedPolicies": [{"policyId": "policy"}],
                        "awsIntegrationIntentProjectAttachment": {
                            "awsIntegration": {"id": "aws"}
                        },
                    }
                ]
            }

        self.assertEqual(bootstrap.reconcile(api, "space", "policy", "aws"), "project")
        self.assertEqual(len(calls), 1)

    def test_creation_attaches_policy_before_cloud_access(self):
        calls = []

        def api(query, variables):
            parse(query)
            calls.append(query)
            if query.startswith("query"):
                return {"intentProjects": []}
            if "intentProjectCreate" in query:
                return {"intentProjectCreate": {"id": "project"}}
            return {}

        bootstrap.reconcile(api, "space", "policy", "aws")
        self.assertIn("policyIntentProjectAttach", calls[2])
        self.assertIn("awsIntegrationIntentProjectAttach", calls[3])


if __name__ == "__main__":
    unittest.main()
