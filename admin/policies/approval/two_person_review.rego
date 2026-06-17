package spacelift

# ----------------------------------------------------------------------------
# Two-person review for the CloudWatch dashboard stack.
#
# A run waiting at the confirmation gate (state == "UNCONFIRMED") may only be
# applied after at least TWO distinct people approve it, with zero rejections.
# The person who triggered the run does NOT count as one of the approvers, so
# the two approvals must come from independent reviewers (separation of duties).
#
# Contract:  https://app.spacelift.io/.well-known/policy-contract.json
# Reference: https://docs.spacelift.io/concepts/policy/approval-policy
# ----------------------------------------------------------------------------

# Number of independent approvals required.
#   - Set to 2 for "two people must review" (default).
#   - Set to 1 for the classic four-eyes rule (run author + one other reviewer).
required_approvals := 2

# Login of whoever triggered the run (safe default if the field is absent/null).
trigger_user := object.get(input.run, "triggered_by", "")

# Set of distinct approver logins, excluding the run's triggerer.
# To let the triggerer's own approval count, remove the `author != trigger_user`
# line below.
approvers[author] {
  author := input.reviews.current.approvals[_].author
  author != trigger_user
}

# Reject the run the moment anyone rejects the current change.
reject {
  count(input.reviews.current.rejections) > 0
}

# At the confirmation gate, require the configured number of independent
# approvals and zero rejections.
approve {
  input.run.state == "UNCONFIRMED"
  count(approvers) >= required_approvals
  count(input.reviews.current.rejections) == 0
}

# Don't gate the rest of the run lifecycle (planning, applying, finished) or
# non-deployment run types -- only the confirmation gate needs the two approvals.
approve {
  input.run.state != "UNCONFIRMED"
  count(input.reviews.current.rejections) == 0
}

# Enable policy sampling so you can validate real input (e.g. how `triggered_by`
# and `author` are populated) in the Spacelift policy workbench.
sample := true
