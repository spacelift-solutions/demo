package spacelift.approval

# Default deny all approvals
allow = false

# Allow approval if user explicitly approves
allow {
  input.approved_by[_] == "user"
}