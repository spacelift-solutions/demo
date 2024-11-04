package spacelift

module_version := version {
    version := trim_prefix(input.push.tag, "v")
    not propose
}

module_version := "999999999999999.99999999999999.99999999999" {
    propose
}

propose { 
  not is_null(input.pull_request) 
}

track { 
  module_version != "999999999999999.99999999999999.99999999999"
  not propose
}

sample := true