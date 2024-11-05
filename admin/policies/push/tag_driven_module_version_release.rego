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

sample := true