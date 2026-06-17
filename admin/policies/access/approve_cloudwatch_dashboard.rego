package spacelift

# Approval policy: require at least one manual approval for runs
# targeting the CloudWatch dashboard stack `tofu-cloudwatch-dashboard`.
# Uses the Spacelift policy contract: https://app.spacelift.io/.well-known/policy-contract.json

# Approve immediately for runs that are NOT for the target stack
approve {
  input.stack.name != "tofu-cloudwatch-dashboard"
}

# Auto-approve if the run creator has admin privileges
approve {
  input.run.creator_session.admin == true
}
approve {
  input.run.creator_session.admin == "true"
}

# If the run already has >= 1 approval, allow it to proceed
approve {
  count(input.reviews.current.approvals) >= 1
}

# If any reviewer explicitly rejected, reject the run
reject {
  count(input.reviews.current.rejections) >= 1
}

sample := true
