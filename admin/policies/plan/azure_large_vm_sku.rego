package spacelift

# Detect plans that create or change an Azure VM to a "large" SKU, warn (which
# stops auto-deploy by marking the run for human review), and set a flag that the
# companion APPROVAL policy uses to require sign-off.
#
# This is a PLAN policy on purpose: plan policies receive the real, unredacted
# resource attributes (input.terraform.resource_changes). Approval-policy
# run.changes values are hashed and can't be matched on a SKU.

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

# Addresses of VMs being created/changed to a large SKU.
large_vm_changes[address] {
	some i
	rc := input.terraform.resource_changes[i]
	rc.type == "azurerm_linux_virtual_machine"
	rc.change.actions[_] != "delete"
	large_vm_sizes[rc.change.after.size]
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
