package spacelift

# Require a human approval before applying any run that creates or changes an
# Azure VM with a "large" SKU. Smaller SKUs are auto-approved so routine changes
# flow through without friction.

# Large Azure VM SKUs that require manual approval.
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

# True if the run creates or updates an Azure VM with a large SKU.
requests_large_vm {
	some i
	change := input.run.changes[i]
	change.action != "deleted"
	change.entity.type == "azurerm_linux_virtual_machine"
	large_vm_sizes[change.entity.data.size]
}

# Auto-approve runs that do not request a large VM SKU.
approve {
	not requests_large_vm
}

# When a large VM SKU is requested, require at least one human approval.
approve {
	requests_large_vm
	count(input.reviews.current.approvals) > 0
}

# Anyone may block a run by rejecting it.
reject {
	count(input.reviews.current.rejections) > 0
}

# Sample evaluations so we can inspect inputs from the policy view.
sample := true
