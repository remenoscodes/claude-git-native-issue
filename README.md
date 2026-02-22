# claude-git-native-issue

Claude Code plugin that replaces internal task management with [git-native-issue](https://github.com/remenoscodes/git-native-issue). Distributed, offline-first issue tracking stored as Git refs.

## What it does

This plugin teaches Claude to **autonomously** manage issues using `git issue` commands:

- **Auto-create** issues when multi-step work begins, plans are approved, or bugs are discovered
- **Auto-update** issues with progress comments and status labels
- **Auto-close** issues when tasks complete successfully
- **Skip tracking** for trivial changes, questions, and exploratory work

It also provides slash commands for manual issue management.

## Prerequisites

- [git-native-issue](https://github.com/remenoscodes/git-native-issue) installed:
  ```bash
  brew install remenoscodes/git-native-issue/git-native-issue
  ```
- A git repository (issues are stored as git refs)

## Installation

```bash
# Add the marketplace
/plugin marketplace add remenoscodes/claude-plugin-marketplace

# Install the plugin
/plugin install claude-git-native-issue
```

## Setup

After installing, run the setup skill in any git repository:

```
/claude-git-native-issue:setup
```

This will:
1. Initialize git-native-issue in the repo
2. Optionally configure auto-sync for issue refs
3. Optionally add task management instructions to your CLAUDE.md

## Slash Commands

| Command | Description |
|---------|-------------|
| `/claude-git-native-issue:setup` | Initialize git-issue in repo and configure integration |
| `/claude-git-native-issue:create` | Create a new issue |
| `/claude-git-native-issue:issues` | List issues with filtering |
| `/claude-git-native-issue:show` | Show issue details and comments |
| `/claude-git-native-issue:close` | Close an issue |
| `/claude-git-native-issue:sync` | Sync issues with remote or platform |

### Examples

```bash
# Create an issue
/claude-git-native-issue:create "Fix auth bug" -l bug -p high

# List in-progress issues
/claude-git-native-issue:issues in-progress

# Show issue details
/claude-git-native-issue:show a7f3b2c

# Close with message
/claude-git-native-issue:close a7f3b2c -m "All tests passing"

# Sync with GitHub
/claude-git-native-issue:sync github:owner/repo
```

## How It Works

### Architecture

Three-layer activation (same pattern as [claude-language-coach](https://github.com/remenoscodes/claude-language-coach)):

1. **UserPromptSubmit hook** — injects context on every prompt, reminding Claude to use `git issue` and defining autonomous trigger rules
2. **Ambient skill** (`git-issue-tracker`) — full CLI reference, autonomous decision rules, status conventions, error handling
3. **User-invocable skills** — slash commands for convenience

### Autonomous Behavior

Claude creates, updates, and closes issues without being asked:

| Trigger | Action |
|---------|--------|
| User starts multi-step work | Create tracking issue |
| Plan approved | Create issue(s) per work stream |
| Bug discovered during work | Create bug issue |
| Starting work on an issue | Add `in-progress` label |
| Progress milestone | Add comment |
| Task completed | Close issue |

### Status Convention

| Status | git-issue Representation |
|--------|--------------------------|
| Pending | `[open]` (no in-progress label) |
| In Progress | `[open]` + `in-progress` label |
| Completed | `[closed]` |
| Blocked | `[open]` + `blocked` label |

## Why git-native-issue?

- **Distributed** — Issues travel with `git clone`, no central server needed
- **Offline-first** — Works without network, syncs when ready
- **No pollution** — Stored in `refs/issues/`, not in the working tree
- **Auditable** — Full history via `git log refs/issues/<uuid>`
- **AI-friendly** — Structured metadata, no rate limits, no API keys
- **Standard tools** — Uses `git log`, `git for-each-ref`, standard trailers

## License

GPL-2.0 — same as git-native-issue.
