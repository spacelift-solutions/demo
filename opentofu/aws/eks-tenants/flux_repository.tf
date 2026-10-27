locals {
  flux_repository_name = "flux"
  flux_repository_url  = "ssh://git@github.com/spacelift-solutions/flux.git"

  # GitHub-published SSH host keys from https://api.github.com/meta. Keep these
  # reviewable rather than trusting keys collected dynamically during a run.
  github_known_hosts = trimspace(<<-EOT
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
  EOT
  )
}

resource "tls_private_key" "flux_repository" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "flux" {
  title      = "Spacelift Solutions EKS Flux"
  repository = local.flux_repository_name
  key        = tls_private_key.flux_repository.public_key_openssh
  read_only  = true
}

resource "kubernetes_secret_v1" "flux_repository_auth" {
  metadata {
    name      = "flux-repository-auth"
    namespace = helm_release.flux_operator.namespace
  }

  data = {
    identity       = tls_private_key.flux_repository.private_key_openssh
    "identity.pub" = tls_private_key.flux_repository.public_key_openssh
    known_hosts    = local.github_known_hosts
  }

  type = "Opaque"

  depends_on = [
    github_repository_deploy_key.flux,
    helm_release.flux_operator,
  ]
}
