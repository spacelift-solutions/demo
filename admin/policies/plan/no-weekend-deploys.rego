package spacelift

import rego.v1

# Plan policy: deletion protection & no weekend runs

weekend_timezone := "EST"

now := input.request.timestamp_ns

is_weekend if {
	day := time.weekday([now, weekend_timezone])
	day in {"Saturday", "Sunday"}
}

# --- Deletion protection: blocks deletions every day ---
deleted_addresses contains addr if {
	c := input.run.changes[_]
	c.entity.entity_type == "resource"
	c.action in {"deleted", "forget"}
	addr := c.entity.address
}

deny contains msg if {
	count(deleted_addresses) > 0
	msg := sprintf(
		"Deletion protection: %d resource(s) scheduled for deletion: %s",
		[count(deleted_addresses), concat(", ", deleted_addresses)],
	)
}

# --- Weekend protection: blocks ALL runs on Sat/Sun ---
deny contains msg if {
	is_weekend
	msg := "No runs allowed on weekends (EST)"
}