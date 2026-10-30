import importlib.util
import unittest
from pathlib import Path

from graphql import parse

spec = importlib.util.spec_from_file_location(
    "bootstrap", Path(__file__).parents[1] / "bootstrap_intent.py"
)
bootstrap = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bootstrap)


class BootstrapTest(unittest.TestCase):
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
