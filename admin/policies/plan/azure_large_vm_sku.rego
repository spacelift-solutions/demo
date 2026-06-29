package spacelift

# Detect plans that create or change an Azure VM to a "large" SKU, warn (which
# stops auto-deploy by marking the run for human review), and set a flag that the
# companion APPROVAL policy uses to require sign-off.
#
# NOTE on value hashing: Spacelift sanitizes resource attribute *values* in policy
# inputs — each value is sha256-hashed and exposed as the last 8 hex chars (e.g.
# "Standard_D8s_v5" -> "f49cf0ed"). Resource type and address are NOT hashed. So
# we match on the hash of each known SKU (computed here with crypto.sha256), not
# the literal string.

# Large Azure VM SKUs that require human review/approval.
large_vm_sizes := {
	"Standard_D8s_v5",
	"Standard_D16s_v5",
	"Standard_D32s_v5",
	"Standard_D8s_v4",
	"Standard_D16s_v4",
	"Standard_D32s_v4",
	"Standard_E8s_v5",
	"Standard_E16s_v5",
	"Standard_E32s_v5",
	"Standard_F8s_v2",
	"Standard_F16s_v2",
	"Standard_F32s_v2",
}

# The sanitized form Spacelift exposes: last 8 hex chars of sha256(sku).
large_vm_size_hashes[h] {
	some s
	large_vm_sizes[s]
	full := crypto.sha256(s)
	h := substring(full, count(full) - 8, 8)
}

# Addresses of VMs being created/changed to a large SKU.
large_vm_changes[address] {
	some i
	rc := input.terraform.resource_changes[i]
	rc.type == "azurerm_linux_virtual_machine"
	rc.change.actions[_] != "delete"
	large_vm_size_hashes[rc.change.after.size]
	address := rc.address
}

# Warn (marks the run for human review when the stack has autodeploy enabled).
warn[msg] {
	large_vm_changes[address]
	msg := sprintf(
		"Large VM SKU requested on %s — requires approval before apply.",
		[address],
	)
}

# Flag the run so the companion APPROVAL policy requires sign-off.
flag[f] {
	count(large_vm_changes) > 0
	f := "azure-large-vm-sku"
}

# Sample evaluations so we can inspect inputs from the policy view.
sample := true
