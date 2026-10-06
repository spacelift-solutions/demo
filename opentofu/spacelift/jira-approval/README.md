# Jira Approval Plugin Demo

Cost-gated change approvals: any stack labeled `jira` that plans a change costing more than $5/month gets held, a Jira issue is created with the plan summary and cost estimate, and moving that issue to Approved or Denied approves or kills the Spacelift run.
Everything here (plugin, flow, app installations, secrets, API key) is managed by this OpenTofu config via the [plugin-jira-approval](https://github.com/spacelift-solutions/plugin-jira-approval) module.

## Where everything lives

| Thing | Location |
| --- | --- |
| Jira board (issues land here) | <https://spacelift-solutions.atlassian.net/jira/software/projects/SOLUTIONS/boards/2> |
| Jira login | `joeys@spacelift.io` |
| Flows project ("Jira Spacelift Flow", useflows.eu) | <https://useflows.eu/project/01a0348d-6000-773e-81f3-3d8ec22ba3ce> |
| Demo target stack (trigger this one) | <https://spacelift-solutions.app.spacelift.io/stack/tofusible-opentofu> |
| Infra stack (manages all of the above) | <https://spacelift-solutions.app.spacelift.io/stack/jira-approval-plugin> |

The Jira API token is supplied through the sensitive `jira_api_token` variable
on the admin stack and passed to the plugin stack as `TF_VAR_jira_api_token`.
Its source value is stored in Joey Vault as
`jira-api-token-spacelift-solutions`.

## Demo runbook

1. Trigger a tracked run on the `Tofusible - OpenTofu` stack, which recreates its EC2 servers every run, so every run carries a cost diff.
   Its `jira` label lives in the tofusible repo (`stacks/admin/main.tf`), not here.
2. Infracost estimates the plan; anything over $5/month gets flagged `infracost:too_costly` by the plan policy and the run holds at Unconfirmed.
3. The plugin creates a Jira issue in SOLUTIONS ("[Terraform Plan] ... - N change(s)") with the plan summary, cost estimate, and a signed JWT identifying the run.
   New issues start in the "To Do" column.
4. Drag the issue to **Approved**: the flow verifies the JWT, approves the run with its own API key, and the run applies.
   Drag to **Denied** instead and the run is killed.
   Roughly ten seconds either way.

## Sharp edges

- Do not set `initial_status` on the module: the plugin sends it as a create-time `status` field, which Jira rejects and no issue gets created.
  The SOLUTIONS workflow starts issues in "To Do" instead.
- Recreating the "Spacelift Info" custom field changes the field id in `main.tf` AND the `JIRA_CUSTOM_FIELD_ID` Flows secret.
- The Jira webhook (Issue Updated, project = SOLUTIONS) points at the Jira app installation's endpoint URL, which is only visible in the app's config screen in Flows.
  Reinstalling the app means re-registering the webhook.
