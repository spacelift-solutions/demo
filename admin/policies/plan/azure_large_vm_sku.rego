package spacelift

# Flag any plan that creates or changes an Azure VM with a "large" SKU so the run
# is marked for human review before it can apply (requires the stack to have
# autodeploy enabled). Smaller SKUs plan and apply without review.
#
# This is a PLAN policy (not APPROVAL) on purpose: plan policies receive the real,
# unredacted resource attributes (input.terraform.resource_changes), whereas
# approval-policy run.changes values are hashed and can't be matched on a SKU.

# Large Azure VM SKUs that require human review.
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

warn[msg] {
	some i
	rc := input.terraform.resource_changes[i]
	rc.type == "azurerm_linux_virtual_machine"
	rc.change.actions[_] != "delete"
	size := rc.change.after.size
	large_vm_sizes[size]

	msg := sprintf(
		"Large VM SKU '%s' requested on %s — requires human review/approval before apply. Contact the platform team for an exception.",
		[size, rc.address],
	)
}

# Sample evaluations so we can inspect inputs from the policy view.
sample := true
