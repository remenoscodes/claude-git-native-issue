---
name: issues
description: List git-native-issues with optional filtering and shorthands
argument-hint: "[all|in-progress|closed|bugs|critical] [--state s] [-l label] [--priority p]"
disable-model-invocation: true
---

# git-native-issue — List Issues

List issues in the current repository with filtering support and convenience shorthands.

## Arguments

Parse `$ARGUMENTS` for filter flags. If empty, lists all open issues.

### Shorthands

These convenience words are translated before execution:

| Shorthand | Translates to |
|-----------|---------------|
| `all` | `git issue ls --state all` |
| `in-progress` | `git issue ls -l in-progress` |
| `closed` | `git issue ls --state closed` |
| `bugs` | `git issue ls -l bug` |
| `critical` | `git issue ls --priority critical` |
| `blocked` | `git issue ls -l blocked` |

### Full flags

All `git issue ls` flags are supported:
- `--state open|closed|all` (default: open)
- `-l <label>` — filter by label
- `--priority <level>` — filter by priority
- `--assignee <email>` — filter by assignee
- `-f short|full|oneline` (default: short)
- `--sort created|updated|priority|state`
- `--reverse` — reverse sort order

## Steps

1. Verify we are in a git repo and git-issue is installed.
2. Parse `$ARGUMENTS` and translate any shorthands.
3. Run `git issue ls` with the constructed flags.
4. Display the results.
5. If no issues found, say so and suggest creating one with `/claude-git-native-issue:create`.

## Examples

```
/claude-git-native-issue:issues                          → all open issues
/claude-git-native-issue:issues all                      → all issues (open + closed)
/claude-git-native-issue:issues in-progress              → currently active work
/claude-git-native-issue:issues -l feature --sort priority  → features by priority
/claude-git-native-issue:issues closed                   → completed/cancelled issues
```
