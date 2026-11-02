# Wiz plugin

`plugin.yaml` is the unmodified generated manifest from [spacelift-io/plugins](https://github.com/spacelift-io/plugins/tree/930c4509a7895bcd60ee6f81e1fe104187d012d1/plugins/wiz), version **3.0.3**, commit `930c4509a7895bcd60ee6f81e1fe104187d012d1`.
Its upstream license is included alongside it.

`admin/plugin_wiz.tf` creates a managed template from this manifest and removes only its top-level `policies` list to preserve the demo's existing findings-only integration.
The plugin uses the latest Wiz CLI v1, authenticates through `WIZ_CLIENT_ID` and `WIZ_CLIENT_SECRET`, and scans after planning, including an exported plan when available.
Credentials continue to come from the sensitive `wiz_client_id` and `wiz_client_secret` inputs; never place them in this directory.

Applying this change replaces the existing Wiz installation and recreates its context with the same `wiz` attachment label.
Existing runs retain their captured configuration; start a fresh preview after apply to exercise the new plugin.
Other stacks carrying the `wiz` label also receive the upgrade.

To upgrade, replace the manifest with the generated `plugins/wiz/plugin.yaml` from a reviewed upstream commit and update this source reference and license as needed.
Do not edit the generated manifest directly.
Template changes trigger replacement of the installed plugin so it cannot remain on an old manifest snapshot.
