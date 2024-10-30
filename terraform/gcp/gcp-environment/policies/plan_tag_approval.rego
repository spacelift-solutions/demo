package spacelift.plan

# Default deny the plan
allow = false

# Allow the plan if terraform validate and terraform fmt have been executed
allow {
  input.before_plan.executed[_].command == "terraform validate"
  input.before_plan.executed[_].command == "terraform fmt"
}