# Spaces & promotion tiers

Managed by the admin stack in this directory.

```
root                      locked down; admin stack only
├─ modules                module registry (read-only for people)
├─ prod                   stable demos; read + trigger; stacks track `main`
│  ├─ aws  (+ tooling)
│  ├─ gcp  (+ tooling)
│  ├─ azure (+ tooling)
│  └─ examples
└─ dev                    reserved staging tier; empty for now
```

## Access

The team's access is the existing `default_solutions_engineering_role`
(`SPACE_READ`, `RUN_TRIGGER`, run-management actions; no write/admin), mapped
to the `solutions-engineering` GitHub team and attached at `root`, so it
propagates to every tier. Customers consume the modules through the **public**
registry, not through space access.

## Promotion

- `main` is prod; branch-protected. PRs against `main` produce proposed
  (plan-only) runs. Merge to deploy.
- Modules promote by git **tag** (`v*`) via the tag-driven release policy,
  co-located in the `modules` space. No human writes to `modules`.

## Deferred

- **Per-tier role attachment.** The SE role is attached at `root` today, which
  also grants trigger in `modules`. To make `modules` strictly read-only for the
  team, move that attachment to `prod` (+ `dev`) and attach a read-only role at
  `modules`. Left as a separate access decision to avoid lockout risk.
- **`dev` population**, per-tier cloud integrations, and admin-stack
  decomposition are all separate follow-ups.
- **Nesting assumes a fresh admin build.** `parent_space_id` is immutable
  server-side, so nesting the cloud spaces under `prod` works on a clean create,
  not as an in-place re-parent of existing spaces.
