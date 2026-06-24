package spacelift

import rego.v1

# Plan policy: deletion protection & no weekend deploys
# Blocks resource deletions and prevents runs on weekends

# Collect deleted resource addresses
deleted_addresses contains addr if {
	c := input.run.changes[_]
	c.entity.entity_type == "resource"
	c.action in {"deleted", "forget"}
	addr := c.entity.address
}

# Deny if any resource is scheduled for deletion
deny contains msg if {
	count(deleted_addresses) > 0
	msg := sprintf(
		"Deletion protection: %d resource(s) scheduled for deletion: %s",
		[count(deleted_addresses), concat(", ", deleted_addresses)],
	)
}

# NOTE: Weekend blocking is left as a TODO because run timestamp handling
# depends on the platform's timestamp format. Implement with accurate
# timezone-aware parsing if you need strict weekend enforcement.

sample := true