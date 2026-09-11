resource "spacelift_role" "admin" {
  name        = "Admin Role"
  description = "Role with full administrative privileges"
  actions     = ["SPACE_ADMIN"]
}

data "spacelift_idp_group_mapping" "solutions_engineering" {
  name = "solutions-engineering"
}
resource "spacelift_role" "default_solutions_engineering_role" {
  name = "default solutions engineering role"

  actions = [
    "RUN_CANCEL",
    "RUN_CANCEL_BLOCKING",
    "RUN_COMMENT",
    "RUN_CONFIRM",
    "RUN_DISCARD",
    "RUN_KILL",
    "RUN_KILL_BLOCKING",
    "RUN_PRIORITIZE_SET",
    "RUN_RETRY",
    "RUN_RETRY_BLOCKING",
    "RUN_REVIEW",
    "RUN_STOP",
    "RUN_STOP_BLOCKING",
    "RUN_TARGETED_REPLAN",
    "RUN_TRIGGER",
    "SPACE_READ",
  ]
}

resource "spacelift_role_attachment" "default_solutions_engineering_role_attachment" {
  idp_group_mapping_id = data.spacelift_idp_group_mapping.solutions_engineering.id
  role_id              = spacelift_role.default_solutions_engineering_role.id
  space_id             = "root"
}
