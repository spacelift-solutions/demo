resource "spacelift_role" "admin" {
  name        = "Admin Role"
  description = "Role with full administrative privileges"
  actions     = ["SPACE_ADMIN"]
}
