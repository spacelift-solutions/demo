package spacelift_test

import rego.v1

resource := {
  "provider": "hashicorp/aws",
  "resource_type": "aws_s3_object",
  "operation": "create",
  "current_state": null,
  "proposed_state": {
    "bucket": "example-license", "key": "license/demo-license.json",
    "server_side_encryption": "AES256", "acl": "private",
    "content": "{\"service\":\"mayday\",\"license_key\":\"DEMO-ONLY\",\"enabled\":true}"
  }
}

test_allowed_restore if {
  count(data.spacelift.allow) == 1 with input as {"resource": resource}
  count(data.spacelift.deny) == 0 with input as {"resource": resource}
}
test_scoped_update_allowed if {
  r := object.union(resource, {"operation":"update", "current_state":resource.proposed_state})
  count(data.spacelift.allow) == 1 with input as {"resource":r}
}
test_update_cannot_move_unrelated_object if {
  original := object.union(resource.proposed_state, {"bucket":"unrelated"})
  r := object.union(resource, {"operation":"update", "current_state":original})
  count(data.spacelift.deny) > 0 with input as {"resource":r}
  count(data.spacelift.allow) == 0 with input as {"resource":r}
}
test_delete_denied_with_null_proposed_state if {
  r := object.union(resource, {"operation":"delete", "current_state":resource.proposed_state, "proposed_state":null})
  count(data.spacelift.deny) > 0 with input as {"resource":r}
  count(data.spacelift.allow) == 0 with input as {"resource":r}
}
test_other_bucket_denied if {
  r := object.union(resource, {"proposed_state":object.union(resource.proposed_state, {"bucket":"unrelated"})})
  count(data.spacelift.deny) > 0 with input as {"resource":r}
}
test_public_object_denied if {
  r := object.union(resource, {"proposed_state":object.union(resource.proposed_state, {"acl":"public-read"})})
  count(data.spacelift.deny) > 0 with input as {"resource":r}
}
test_invalid_entitlement_denied if {
  r := object.union(resource, {"proposed_state":object.union(resource.proposed_state, {"content":"{}"})})
  count(data.spacelift.deny) > 0 with input as {"resource":r}
}
test_refresh_allowed if {
  r := object.union(resource, {"operation":"refresh", "current_state":resource.proposed_state, "proposed_state":null})
  count(data.spacelift.allow) == 1 with input as {"resource":r}
}
test_bucket_resource_denied if {
  r := object.union(resource, {"resource_type":"aws_s3_bucket"})
  count(data.spacelift.deny) > 0 with input as {"resource":r}
}
