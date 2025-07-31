package spacelift

module_version := version {
    version := trim_prefix(input.push.tag, "v")
    not propose
}

module_version := "999999999999999.99999999999999.99999999999" {
    propose
}

propose {
  input.push.branch != ""
  input.push.tag == ""
}

track {
  not propose
}

flag["is_fork"] {
    input.pull_request.head_owner != "spacelift-solutions"
}

# Allow runs triggered from forks. In this case the `is_fork` flag will be attached
# which will cause an approval to be required because of https://spacelift-io.app.spacelift.io/policy/require-approval-from-forks.
allow_fork {
  true
}

sample := true