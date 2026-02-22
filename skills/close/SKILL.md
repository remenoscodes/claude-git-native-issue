---
name: close
description: Close a git-native-issue with an optional message
argument-hint: "<issue-id> [-m message] [--reason reason]"
disable-model-invocation: true
---

# git-native-issue — Close Issue

Close an issue, optionally with a closing message and reason.

## Arguments

Parse `$ARGUMENTS`:
- First argument: issue ID (required, or interactive if empty)
- `-m "message"`: closing message (optional, defaults to "Completed")
- `--reason <reason>`: closing reason — `completed`, `duplicate`, `wontfix`, `invalid`
- `--fixed-by <sha>`: commit SHA that fixed the issue

If `$ARGUMENTS` is empty, run `git issue ls -l in-progress` to show current work and ask which to close. If no in-progress issues, fall back to `git issue ls` and ask.

## Steps

1. Verify prerequisites (git repo, git-issue installed).
2. Parse the issue ID, message, and reason from `$ARGUMENTS`.
3. Run `git issue state <id> --close -m "<message>"` with optional `--reason` and `--fixed-by`.
4. Confirm closure to the user with the issue title and ID.

## Examples

```
/claude-git-native-issue:close a7f3b2c -m "All tests passing"
/claude-git-native-issue:close a7f3b2c --reason duplicate
/claude-git-native-issue:close a7f3b2c --fixed-by abc1234
/claude-git-native-issue:close              → interactive selection from open issues
```
