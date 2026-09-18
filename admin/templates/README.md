# Stack templates

Terraform registers the stack templates in this directory through
[`../templates.tf`](../templates.tf). Published template versions are immutable:
change their source only before publishing. Create a new version resource and
YAML file for later changes.

## GitHub Repository Template

The GitHub Repository Template creates a private, public, or internal repository
in `spacelift-solutions` from
[`repository-template`](https://github.com/spacelift-solutions/repository-template),
then configures its shared rulesets with the latest
[`git-hooks`](https://github.com/spacelift-solutions/git-hooks) setup CLI.

### Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `repository_name` | yes | | GitHub repository name |
| `description` | no | empty | Repository description |
| `visibility` | no | `private` | `private`, `public`, or `internal` |
| `import_existing` | no | `false` | Import an existing repository into the new stack |

### Repository starter files

When creating a repository, GitHub copies these files into it once:

- `README.md`
- `CONTRIBUTING.md`
- `LICENSE`
- `AGENTS.md`
- `.github/CODEOWNERS`
- `adr/README.md`
- `Makefile`
- empty `.betterleaksignore` and `.gitignore` files

Run `make hooks` after cloning to install the shared local Git hooks from
`spacelift-solutions/git-hooks`. The files are not added to the generated
stack's state, so repository owners can change or delete them without a later
stack run restoring the template copies.

### Importing an existing repository

Version `1.2.0` adds the **Import existing repository** option. After OpenTofu
initializes, the stack checks whether `github_repository.this` is already in
state. If it is not, the stack runs:

```sh
tofu import github_repository.this "$TF_VAR_repository_name"
```

The import is idempotent across later runs. It does not copy or backfill files
from `repository-template`; it only brings the existing repository under the
stack's OpenTofu state before planning.

### GitHub App authentication

Versions `1.1.0` and later attach the `Spacelift-Solutions[Bot]` context. Before
using the template, replace these context placeholders in the Spacelift UI:

- `TF_VAR_github_app_id`: the GitHub App ID
- `TF_VAR_github_app_installation_id`: the organization installation ID
- `github-app.pem`: the GitHub App private key uploaded as a mounted file

The mounted file is available to runs at `/mnt/workspace/github-app.pem`. The
GitHub provider reads it directly. The released Go setup CLI uses the same file
to issue the short-lived token needed by the post-apply repository setup hook.
