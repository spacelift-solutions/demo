package spacelift_test

import rego.v1

request_state := {
  "bucket": "example-license", "key": "license-requests/demo.json",
  "content": "{\"service\":\"mayday\",\"license_key\":\"DEMO-ONLY\",\"enabled\":true}",
  "server_side_encryption": "AES256", "acl": null,
}

request_input(state) := {"terraform": {"resource_changes": [{
  "mode": "managed", "type": "aws_s3_object",
  "change": {"before": null, "after": state, "actions": ["create"]},
}]}}

test_valid_request_allowed if {
  count(data.spacelift.deny) == 0 with input as request_input(request_state)
}
test_invalid_key_denied if {
  state := object.union(request_state, {"content": "{\"service\":\"mayday\",\"license_key\":\"INVALID\",\"enabled\":true}"})
  count(data.spacelift.deny) > 0 with input as request_input(state)
}
test_live_license_denied if {
  state := object.union(request_state, {"key": "license/demo-license.json"})
  count(data.spacelift.deny) > 0 with input as request_input(state)
}
test_other_bucket_denied if {
  state := object.union(request_state, {"bucket": "unrelated"})
  count(data.spacelift.deny) > 0 with input as request_input(state)
}
test_public_request_denied if {
  state := object.union(request_state, {"acl": "public-read"})
  count(data.spacelift.deny) > 0 with input as request_input(state)
}
test_malformed_content_denied if {
  state := object.union(request_state, {"content": "not-json"})
  count(data.spacelift.deny) > 0 with input as request_input(state)
}
test_sandbox_cleanup_allowed if {
  plan := {"terraform": {"resource_changes": [{"mode": "managed", "type": "aws_s3_object", "change": {"before": request_state, "after": null, "actions": ["delete"]}}]}}
  count(data.spacelift.deny) == 0 with input as plan
}
test_live_license_cleanup_denied if {
  state := object.union(request_state, {"key": "license/demo-license.json"})
  plan := {"terraform": {"resource_changes": [{"mode": "managed", "type": "aws_s3_object", "change": {"before": state, "after": null, "actions": ["delete"]}}]}}
  count(data.spacelift.deny) > 0 with input as plan
}
