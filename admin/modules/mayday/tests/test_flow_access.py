import importlib.util
import io
import json
import os
import unittest
from pathlib import Path
from unittest.mock import patch

from graphql import parse

spec = importlib.util.spec_from_file_location(
    "flow_access", Path(__file__).parents[1] / "bootstrap_flow_access.py"
)
access = importlib.util.module_from_spec(spec)
spec.loader.exec_module(access)


class FlowAccessTest(unittest.TestCase):
    def project(self, bindings=None):
        return {"id": "project", "name": "Mayday", "roleBindings": bindings or []}

    def binding(self, space="operations", role="recovery"):
        return {"id": "binding", "space": {"id": space}, "role": {"id": role}}

    def test_adopts_existing_binding_without_mutating(self):
        def api(query, variables):
            parse(query)
            self.assertTrue(query.startswith("query"))
            return {"flowsProjects": [self.project([self.binding()])]}

        self.assertEqual(
            access.reconcile(api, "project", "operations", "recovery"), "binding"
        )

    def test_creates_only_the_requested_scoped_binding(self):
        calls = []

        def api(query, variables):
            parse(query)
            calls.append(variables)
            if query.startswith("query"):
                return {"flowsProjects": [self.project()]}
            return {"flowsProjectRoleBindingBatchCreate": [{"id": "binding"}]}

        access.reconcile(api, "project", "operations", "recovery")
        self.assertEqual(
            calls[1],
            {
                "input": {
                    "bindings": [
                        {
                            "flowsProjectID": "project",
                            "spaceID": "operations",
                            "roleID": "recovery",
                        }
                    ]
                }
            },
        )

    def test_wrong_project_or_unexpected_grants_fail_closed(self):
        for projects in [
            [],
            [{**self.project(), "name": "Other"}],
            [self.project([self.binding(role="admin")])],
            [self.project([self.binding(), self.binding(space="root")])],
        ]:
            with self.subTest(projects=projects), self.assertRaises(RuntimeError):
                access.reconcile(
                    lambda *_, projects=projects: {"flowsProjects": projects},
                    "project",
                    "operations",
                    "recovery",
                )

    def test_uses_administrative_run_token_without_printing_it(self):
        environment = {
            "SPACELIFT_API_TOKEN": "run-token",
            "MAYDAY_FLOWS_PROJECT_ID": "project",
            "MAYDAY_FLOWS_SPACE_ID": "operations",
            "MAYDAY_FLOWS_ROLE_ID": "recovery",
        }

        def urlopen(request, timeout):
            self.assertEqual(
                request.full_url, "https://spacelift-solutions.app.spacelift.io/graphql"
            )
            self.assertEqual(request.get_header("Authorization"), "Bearer run-token")
            return io.BytesIO(
                json.dumps(
                    {"data": {"flowsProjects": [self.project([self.binding()])]}}
                ).encode()
            )

        with (
            patch.dict(os.environ, environment, clear=True),
            patch.object(access.urllib.request, "urlopen", side_effect=urlopen),
            patch("sys.stdout", new_callable=io.StringIO) as output,
        ):
            access.main()
        self.assertNotIn("run-token", output.getvalue())


if __name__ == "__main__":
    unittest.main()
