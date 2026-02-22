---
name: show
description: Show details and comments for a git-native-issue
argument-hint: "<issue-id>"
disable-model-invocation: true
---

# git-native-issue — Show Issue

Show full details and comment history of a specific issue.

## Arguments

`$ARGUMENTS` should be an issue ID (full UUID or abbreviated 4+ char prefix).

If `$ARGUMENTS` is empty, run `git issue ls` to show open issues and ask the user which one they want to see.

## Steps

1. Verify prerequisites (git repo, git-issue installed).
2. Run `git issue show <id>`.
3. If the ID is ambiguous (matches multiple issues), display the matches and ask the user to clarify.
4. If the issue is not found, suggest `git issue ls` or `git issue search "<keyword>"`.
5. Display the full output.

## Examples

```
/claude-git-native-issue:show a7f3b2c
/claude-git-native-issue:show                → prompts user to pick an issue
```
