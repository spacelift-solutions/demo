package spacelift

# Require a human approval for runs the plan policy flagged as containing a large
# Azure VM SKU (flag set in policies/plan/azure_large_vm_sku.rego). Everything
# else is auto-approved so routine changes flow through.

requires_approval {
	input.run.flags[_] == "azure-large-vm-sku"
}

# Auto-approve runs that weren't flagged.
approve {
	not requires_approval
}

# Flagged runs need at least one human approval.
approve {
	requires_approval
	count(input.reviews.current.approvals) > 0
}

# Anyone may block a run by rejecting it.
reject {
	count(input.reviews.current.rejections) > 0
}

# Sample evaluations so we can inspect inputs from the policy view.
sample := true
