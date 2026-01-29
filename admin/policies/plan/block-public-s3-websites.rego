package spacelift

# Block public S3 website deployments while allowing private S3 buckets

# Allow: S3 bucket creation (private buckets are fine)
allow[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket"
    input.resource.operation == "create"

    msg := sprintf(
        "S3 bucket creation allowed: %s",
        [input.resource.resource_id]
    )
}

# Allow: S3 objects (if the bucket is private)
allow[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_object"
    input.resource.operation == "create"

    msg := sprintf(
        "S3 object upload allowed: %s",
        [input.resource.resource_id]
    )
}

# Deny: S3 bucket website configuration (public hosting)
deny[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket_website_configuration"
    input.resource.operation == "create"

    msg := sprintf(
        "POLICY VIOLATION: Public S3 website hosting is not allowed. Attempted to create website configuration for bucket '%s'. Contact security team for exceptions.",
        [input.resource.proposed_state.bucket]
    )
}

# Deny: S3 public access block with ANY public setting enabled
deny[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket_public_access_block"
    input.resource.operation == "create"

    proposed := input.resource.proposed_state
    proposed.block_public_acls == false

    msg := sprintf(
        "POLICY VIOLATION: Public S3 access is not allowed. Bucket '%s' has block_public_acls set to false. All public access must be blocked.",
        [proposed.bucket]
    )
}

deny[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket_public_access_block"
    input.resource.operation == "create"

    proposed := input.resource.proposed_state
    proposed.block_public_policy == false

    msg := sprintf(
        "POLICY VIOLATION: Public S3 access is not allowed. Bucket '%s' has block_public_policy set to false. All public access must be blocked.",
        [proposed.bucket]
    )
}

deny[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket_public_access_block"
    input.resource.operation == "create"

    proposed := input.resource.proposed_state
    proposed.ignore_public_acls == false

    msg := sprintf(
        "POLICY VIOLATION: Public S3 access is not allowed. Bucket '%s' has ignore_public_acls set to false. All public access must be blocked.",
        [proposed.bucket]
    )
}

deny[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket_public_access_block"
    input.resource.operation == "create"

    proposed := input.resource.proposed_state
    proposed.restrict_public_buckets == false

    msg := sprintf(
        "POLICY VIOLATION: Public S3 access is not allowed. Bucket '%s' has restrict_public_buckets set to false. All public access must be blocked.",
        [proposed.bucket]
    )
}

# Deny: S3 bucket policy with public principal
deny[{"msg": msg}] {
    input.resource.resource_type == "aws_s3_bucket_policy"
    input.resource.operation == "create"

    # Parse the policy JSON
    policy_json := json.unmarshal(input.resource.proposed_state.policy)

    # Check for statements with public principal
    some i
    statement := policy_json.Statement[i]
    statement.Effect == "Allow"
    statement.Principal == "*"

    msg := sprintf(
        "POLICY VIOLATION: Public S3 bucket policies are not allowed. Bucket '%s' has a policy allowing public access (Principal: \"*\"). Use private access methods instead.",
        [input.resource.proposed_state.bucket]
    )
}