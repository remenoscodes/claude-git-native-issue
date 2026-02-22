---
name: git-issue-tracker
description: Autonomous task management via git-native-issue. When Claude needs to track work, create issues, update progress, or close completed tasks, this skill provides the full protocol and CLI reference. Activates when task management context is detected.
user-invocable: false
---

# git-native-issue — Autonomous Task Tracker

You are an autonomous task manager using `git issue` (git-native-issue) for ALL task tracking. You replace Claude's internal TaskCreate/TaskUpdate/TaskList tools with distributed, Git-native issue tracking.

## Core Principle

Issues are stored as Git refs (`refs/issues/<uuid>`). They are distributed, offline-first, and travel with the code via `git push/pull`. No API, no external service, no rate limits.

## Task Operation Mapping

| Internal Tool | git-issue Command |
|---------------|-------------------|
| TaskCreate(subject, description) | `git issue create "<subject>" -m "<description>"` |
| TaskList() | `git issue ls` |
| TaskGet(taskId) | `git issue show <id>` |
| TaskUpdate(status: in_progress) | `git issue edit <id> --add-label in-progress` |
| TaskUpdate(status: completed) | `git issue state <id> --close -m "Completed"` |
| Delete task | `git issue state <id> --close -m "Cancelled"` |

## Autonomous Decision Rules

### When to Auto-Create Issues

Create an issue WITHOUT being asked when:

1. **Multi-step work begins** — User describes a task that requires 3+ steps or touches multiple files. Create a tracking issue before starting.
2. **Plan approved** — After a plan is approved in plan mode, create issue(s) for each distinct work stream.
3. **Bug discovered** — While working, you discover an unexpected bug. Create a bug issue with `-l bug` and the appropriate priority.
4. **User says "let's work on X"** — For non-trivial X, create a feature/task issue to track it.
5. **Sub-tasks emerge** — While working on an issue, you discover additional work. Create child issues and comment on the parent.

### When to Auto-Update Issues

Update an issue WITHOUT being asked when:

1. **Starting work** — Before beginning work that matches an open issue, mark it: `git issue edit <id> --add-label in-progress`
2. **Progress milestones** — After completing a significant sub-step, comment: `git issue comment <id> -m "progress summary"`
3. **Blocked** — If work is blocked, add the blocked label: `git issue edit <id> --add-label blocked`

### When to Auto-Close Issues

Close an issue WITHOUT being asked when:

1. **Task completed** — All work described in the issue is done: `git issue state <id> --close -m "Completed: summary"`
2. **Bug fixed** — Fix is verified (tests pass, behavior correct): `git issue state <id> --close -m "Fixed: explanation"`
3. **Plan implemented** — All steps of an approved plan are done. Close the tracking issue.

### When to Auto-Sync with Provider

After any issue mutation (create, close, edit, comment), sync with the remote platform:

1. **Detect the provider** — On the first issue operation in a session, determine the provider:
   ```bash
   # Check for cached provider string
   git config --get git-issue.provider 2>/dev/null

   # If not cached, detect from remote URL
   REMOTE_URL=$(git remote get-url origin 2>/dev/null)
   # github.com/owner/repo → github:owner/repo
   # gitlab.com/group/project → gitlab:group/project
   # Other hosts → check for gitea/forgejo API, or skip
   ```

2. **Cache the provider** — After detection, store it for the session:
   ```bash
   git config git-issue.provider "github:owner/repo"
   ```

3. **Sync after mutations** — After `create`, `state --close`, `edit`, or `comment`:
   ```bash
   PROVIDER=$(git config --get git-issue.provider 2>/dev/null)
   if [ -n "$PROVIDER" ]; then
     git issue sync "$PROVIDER" --state all
   fi
   ```

4. **Sync at session start** — When first listing issues, import from the provider to get any issues created on the platform:
   ```bash
   git issue sync "$PROVIDER" --state all
   ```

5. **Skip sync when**:
   - No remote configured
   - Provider detection fails (private/custom git server)
   - User explicitly disables sync
   - Network is unavailable (git-issue works offline, sync on next opportunity)

### When NOT to Track

Do NOT create issues for:

1. **Simple questions** — "What does this function do?", "Explain this error"
2. **Trivial changes** — Single-line fixes, typo corrections, simple renames
3. **Not a git repo** — If `git rev-parse --git-dir` fails, skip all tracking
4. **User opts out** — User explicitly says they don't want tracking
5. **Exploratory work** — Pure research, code reading, architecture review

### Issue Lifecycle Example (with sync)

```bash
# 0. Detect and cache provider (once per session)
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
# e.g., https://github.com/remenoscodes/match-os.git → github:remenoscodes/match-os
git config git-issue.provider "github:remenoscodes/match-os"
PROVIDER=$(git config --get git-issue.provider)

# 1. Import existing issues from platform
git issue sync "$PROVIDER" --state all

# 2. User says: "Let's implement JWT authentication"
git issue create "Implement JWT authentication" \
  -m "Add JWT-based auth with refresh tokens and role-based permissions" \
  -l feature -l auth -p high
# Output: Created issue a7f3b2c
git issue sync "$PROVIDER" --state all   # ← sync after create

# 3. Start working
git issue edit a7f3b2c --add-label in-progress

# 4. Progress update
git issue comment a7f3b2c -m "JWT signer implemented, working on refresh token rotation"

# 5. Discover a sub-task
git issue create "Add token blocklist for revocation" \
  -m "Need a blocklist to invalidate tokens before expiry" \
  -l feature -l auth -p medium
git issue sync "$PROVIDER" --state all   # ← sync after create

# 6. Complete the work
git issue state a7f3b2c --close -m "Completed: JWT auth with EdDSA signing, refresh tokens, role-based permissions. All tests passing."
git issue sync "$PROVIDER" --state all   # ← sync after close
```

## Status Convention

| Status | git-issue State | Representation |
|--------|----------------|----------------|
| pending | open (no in-progress label) | `[open]` in `git issue ls` |
| in_progress | open + `in-progress` label | `[open]` with label filter |
| completed | closed | `[closed]` in `git issue ls` |
| blocked | open + `blocked` label | `[open]` with label filter |

## Priority Mapping

| Priority | Flag | When to use |
|----------|------|-------------|
| critical | `-p critical` | Production down, data loss, security vulnerability |
| high | `-p high` | Blocking other work, significant feature |
| medium | `-p medium` | Normal work (default) |
| low | `-p low` | Nice-to-have, optional improvement |

## Label Conventions

### Status labels
- `in-progress` — Currently being worked on
- `blocked` — Cannot proceed, waiting on something

### Type labels
- `bug` — Something is broken
- `feature` — New functionality
- `refactor` — Code restructuring without behavior change
- `docs` — Documentation only
- `test` — Test improvements
- `chore` — Maintenance, dependencies, tooling
- `perf` — Performance improvement

### Language/framework tags
- `elixir`, `rust`, `python`, `typescript`, etc.

## Command Quick Reference

### Create
```bash
git issue create "<title>" [-m "<description>"] [-l <label>]... [-p <priority>] [-a <email>] [--milestone <name>]
# Output: Created issue <short-id>
```

### List
```bash
git issue ls [-s open|closed|all] [-l <label>] [--priority <level>] [--assignee <email>] [-f short|full|oneline] [--sort created|updated|priority|state] [--reverse]
# Default: open issues, short format, sorted by created
```

### Show
```bash
git issue show <issue-id>
# Accepts full UUID or abbreviated prefix (4+ chars)
# Shows title, metadata, body, and all comments
```

### Comment
```bash
git issue comment <issue-id> -m "<text>"
# Output: Added comment to <short-id>
```

### Edit
```bash
git issue edit <issue-id> [-t "<title>"] [--add-label <label>] [--remove-label <label>] [-l <label>]... [-p <priority>] [-a <email>] [--milestone <name>]
# -l replaces ALL labels; --add-label appends; --remove-label removes one
```

### State
```bash
git issue state <issue-id> --close [-m "<message>"] [--fixed-by <sha>] [--reason <reason>]
git issue state <issue-id> --open [-m "<message>"]
# Reasons: duplicate, wontfix, invalid, completed
```

### Search
```bash
git issue search "<pattern>" [-s open|closed|all] [-i]
# Fixed string match (not regex), searches titles, bodies, and comments
```

### Init
```bash
git issue init [<remote>]
# Configures remote for automatic issue ref fetching
```

### Sync
```bash
# Push issue refs to remote
git push origin 'refs/issues/*'

# Fetch issue refs from remote
git fetch origin 'refs/issues/*:refs/issues/*'

# Platform sync (GitHub)
git issue sync github:<owner>/<repo> [--state all] [--dry-run]

# Platform sync (GitLab, Gitea)
git issue sync gitlab:<group>/<project> [--state all]
git issue sync gitea:<owner>/<repo> [--state all]

# Merge divergent issues from remote
git issue merge <remote> [--check] [--no-fetch]
```

### Integrity check
```bash
git issue fsck [--quiet]
```

## Prerequisites Check

Before running any `git issue` command:

1. **Verify git repo**: `git rev-parse --git-dir 2>/dev/null` — if this fails, you are NOT in a git repo. Do not attempt git-issue operations.
2. **Verify git-issue installed**: `which git-issue 2>/dev/null` — if missing, tell the user: `brew install remenoscodes/git-native-issue/git-native-issue`
3. **Check initialization**: `git config --get issue.remote 2>/dev/null` — if not set, run `git issue init` before the first operation. This is a one-time setup per repo.

## Provider Detection

Detect the platform provider from the git remote URL to enable automatic sync.

### Detection Logic

```bash
# 1. Check cached provider
PROVIDER=$(git config --get git-issue.provider 2>/dev/null)

# 2. If not cached, detect from remote URL
if [ -z "$PROVIDER" ]; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null)
  case "$REMOTE_URL" in
    *github.com[:/]*)
      # Extract owner/repo from URL (handles both HTTPS and SSH)
      OWNER_REPO=$(echo "$REMOTE_URL" | sed -E 's#.*(github\.com)[:/]([^/]+/[^/.]+)(\.git)?$#\2#')
      PROVIDER="github:$OWNER_REPO"
      ;;
    *gitlab.com[:/]*)
      OWNER_REPO=$(echo "$REMOTE_URL" | sed -E 's#.*(gitlab\.com)[:/]([^/]+/[^/.]+)(\.git)?$#\2#')
      PROVIDER="gitlab:$OWNER_REPO"
      ;;
    *)
      # Could be Gitea/Forgejo or self-hosted — check API
      # For unknown hosts, leave PROVIDER empty (no auto-sync)
      PROVIDER=""
      ;;
  esac

  # 3. Cache for future use
  if [ -n "$PROVIDER" ]; then
    git config git-issue.provider "$PROVIDER"
  fi
fi
```

### Provider Format Examples

| Remote URL | Provider String |
|------------|----------------|
| `https://github.com/remenoscodes/match-os.git` | `github:remenoscodes/match-os` |
| `git@github.com:remenoscodes/match-os.git` | `github:remenoscodes/match-os` |
| `https://gitlab.com/group/project.git` | `gitlab:group/project` |
| `https://gitea.example.com/owner/repo.git` | Needs `gitea:owner/repo` (manual config) |

### Self-Hosted and Gitea/Forgejo

For self-hosted instances or Gitea/Forgejo, auto-detection may not work. The user should manually set the provider during setup:

```bash
git config git-issue.provider "gitea:owner/repo"
# For self-hosted GitLab:
git config git-issue.provider "gitlab:group/project"
```

The `setup` skill handles this interactively.

### Sync Frequency

- **After create**: Sync immediately so the issue appears on the platform
- **After close**: Sync immediately so the platform reflects the closure
- **After edit/comment**: Sync if the edit changes labels, priority, or title (skip for trivial comments to reduce API calls)
- **At session start**: Sync to import issues created on the platform since last session
- **Batch operations**: If creating multiple issues in a loop, sync ONCE after all creates (not per-create)

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| "Not a git repository" | Not in a git repo | Inform user, skip tracking |
| "command not found: git-issue" | Not installed | Suggest: `brew install remenoscodes/git-native-issue/git-native-issue` |
| "Ambiguous issue id" | Prefix matches multiple issues | Show matches, ask user to specify more characters |
| "Issue not found" | Invalid ID | Suggest `git issue ls` or `git issue search` |
| Exit code 1 | Validation failure or conflict | Read stderr, retry if concurrent modification |

## Team Coordination

When working with `TeamCreate` / multi-agent teams:

1. **Create issues per work stream**: `git issue create "Research X" -l research` and `git issue create "Implement Y" -l implementation`
2. **Track streams via labels** (not assignees): `git issue edit <id> --add-label stream-research`
3. **Assignees are for humans only**: Use `-a email` only when assigning to a person on the team, never for Claude instances
4. **Monitor progress**: `git issue ls -l in-progress` to see active work across the team

## Output Parsing

When you need to extract the issue ID from command output:

- `git issue create` outputs: `Created issue <short-id>` — extract the last word
- `git issue ls -f oneline` outputs: `<id> <state> <title>` — parse space-separated
- `git issue state --close` outputs: `Closed issue <short-id>` — extract the last word
