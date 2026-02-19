# forestadmin/.github

Shared GitHub configuration and reusable workflows for the Forest Admin organization.

## Security auto-fix workflows

Automatically detect and fix security vulnerabilities across all Forest Admin repositories using [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

### How it works

```
Dependabot alert (high/critical, production only)
        │
        ▼
  Fetch EPSS score (exploitation probability)
        │
        ▼
  Is it a Forest Admin dependency?
        │
   no───┴───yes
   │          │
Claude      Open tracking issue
Code        (label: blocked-upstream)
bumps &     SLA based on EPSS score
opens PR         │
                 ▼
          ┌──────────────┐
          │  Daily cron   │ ◄── retries weekdays 8am UTC
          │  + upstream   │ ◄── immediate dispatch on security PR merge
          │  dispatch     │
          └──────┬───────┘
                 │
          Fix available?
                 │
          no─────┴─────yes
          │              │
        flag        Claude Code
        if SLA      bumps & opens PR
        breached    + closes issue
```

### Reusable workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `fix-vulnerability.yml` | `dependabot_alert` | Fetch EPSS, analyze dependency chain, either fix with Claude Code or open tracking issue |
| `retry-upstream-vulnerabilities.yml` | Scheduled (cron) / dispatch | Check blocked issues daily (or on upstream notification), auto-fix when upstream ships |
| `notify-downstream.yml` | Security PR merged | Notify downstream repos to immediately retry blocked issues |
| `notify-slack-security-pr.yml` | Security PR labeled | Send Slack notification to a channel with user group mention |

### Setup for a new repository

1. **Copy the caller workflows** to your repo's `.github/workflows/`:

   ```bash
   # Deploy to a single repo
   ./scripts/rollout.sh my-repo-name

   # Deploy to all configured repos
   ./scripts/rollout.sh
   ```

   Or manually copy from `caller-workflows/`:
   - `security-auto-fix.yml`
   - `security-retry-upstream.yml`
   - `security-notify-downstream.yml` (for repos with downstream dependents)
   - `security-slack-notify.yml`

2. **Configure `security-notify-downstream.yml`** in repos that have downstream dependents. Set `downstream_repos` to the list of repos that depend on this repo's packages:
   - `agent-nodejs` → `'["forestadmin-server"]'`
   - Other repos → `'[]'` (no downstream dependents)

3. **Add a `CLAUDE.md`** to the repo root using `CLAUDE.md.template` as a starting point. Customize the lint/test/format commands for your project.

4. **Ensure required labels exist** in the repo:
   - `:lock: security`
   - `blocked-upstream`

5. **Verify secrets** (see below).

### Configuration

Caller workflows can override these defaults via `with:` inputs:

| Input | Default | Description |
|-------|---------|-------------|
| `forest_package_patterns` | `@forestadmin/\|^forest-` | Regex to identify org-owned packages |
| `default_assignee_team` | `forestadmin/platform` | Team or user to assign PRs/issues |
| `node_version` | `22` | Node.js version for CI |
| `package_manager` | _(auto-detected)_ | Package manager: `npm`, `yarn`. Auto-detected from lockfile if omitted |
| `stale_days` | `14` | Default days before a blocked issue is flagged stale (overridden by EPSS-based SLA) |
| `security_label` | `:lock: security` | Label name for security issues/PRs |

### EPSS integration

Each vulnerability is scored using the [EPSS](https://www.first.org/epss/) (Exploit Prediction Scoring System), which predicts the probability of exploitation within 30 days. This drives:

- **SLA on tracking issues**: EPSS > 0.7 → 3-day SLA, EPSS 0.4–0.7 → 7-day SLA, otherwise default `stale_days`
- **Priority labels**: EPSS > 0.7 → `critical-exploitable` label
- **PR context**: EPSS score is included in the Claude Code prompt and PR description

### Cross-repo dispatch

When a security PR is merged in an upstream repo (e.g., `agent-nodejs`), the `notify-downstream` workflow triggers the retry workflow in downstream repos (e.g., `forestadmin-server`) immediately, instead of waiting for the daily cron.

This requires a `CROSS_REPO_TOKEN` secret with `actions:write` permission on the downstream repos.

### Required secrets

| Secret | Scope | Description |
|--------|-------|-------------|
| `ANTHROPIC_API_KEY` | Org-level | API key for Claude Code |
| `CROSS_REPO_TOKEN` | Org-level | PAT or GitHub App token with `actions:write` on downstream repos (for cross-repo dispatch) |
| `SLACK_BOT_TOKEN` | Org-level | Slack bot token with `chat:write` permission (for PR notifications) |

Set them at the org level:

```bash
gh secret set ANTHROPIC_API_KEY --org forestadmin --visibility selected --repos repo1,repo2,repo3
gh secret set CROSS_REPO_TOKEN --org forestadmin --visibility selected --repos repo1,repo2,repo3
```

### File structure

```
forestadmin/.github/
├── .github/
│   └── workflows/
│       ├── fix-vulnerability.yml              # Reusable: fix or track vulnerabilities
│       ├── retry-upstream-vulnerabilities.yml  # Reusable: daily retry for upstream fixes
│       ├── notify-downstream.yml              # Reusable: cross-repo dispatch on fix merge
│       └── notify-slack-security-pr.yml       # Reusable: Slack notification on security PR
├── caller-workflows/
│   ├── security-auto-fix.yml                  # Copy to each repo
│   ├── security-retry-upstream.yml            # Copy to each repo
│   ├── security-notify-downstream.yml         # Copy to repos with downstream dependents
│   └── security-slack-notify.yml              # Copy to each repo
├── scripts/
│   └── rollout.sh                             # Deploy caller workflows to repos
├── CLAUDE.md.template                         # Template for repo-level CLAUDE.md
└── README.md
```
