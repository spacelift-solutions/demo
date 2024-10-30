package spacelift.notification

# Default deny notifications
allow = false

# Allow notifications upon successful deployment
allow {
  input.status == "SUCCESS"
}

# Allow notifications upon failed deployment
allow {
  input.status == "FAILURE"
}