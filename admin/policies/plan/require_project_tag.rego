package spacelift

import rego.v1

# Plan policy: every taggable resource being created or updated must carry a
# "project" tag (key match is case-insensitive) so it can be traced back to
# the project it belongs to. Resources whose schema has no "tags" attribute
# (data sources, IAM policy documents, spacelift_* resources, etc.) are
# skipped since there's nothing to tag.

is_creating_or_updating(rc) if {
	some action in rc.change.actions
	action in {"create", "update"}
}

has_tags_attribute(rc) if {
	"tags" in object.keys(rc.change.after)
}

has_project_tag(rc) if {
	some key
	rc.change.after.tags[key]
	lower(key) == "project"
}

missing_project_tag contains rc.address if {
	rc := input.terraform.resource_changes[_]
	is_creating_or_updating(rc)
	has_tags_attribute(rc)
	not has_project_tag(rc)
}

deny contains msg if {
	some address in missing_project_tag
	msg := sprintf("Resource %s is missing a required 'project' tag.", [address])
}

sample := true
