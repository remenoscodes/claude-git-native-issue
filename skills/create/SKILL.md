---
name: create
description: Create a new git-native-issue in the current repository
argument-hint: "<title> [-m description] [-l label...] [-p priority]"
disable-model-invocation: true
---

# git-native-issue — Create

Create a new issue in the current repository using git-native-issue.

## Arguments

Parse `$ARGUMENTS` as the issue creation parameters:

- First positional argument or quoted string: issue title (required)
- `-m "description"`: issue body/description
- `-l label`: label (can be repeated for multiple labels)
- `-p priority`: priority level (low, medium, high, critical)
- `-a email`: assignee email

If `$ARGUMENTS` is empty, ask the user for at least a title.

## Steps

1. **Verify prerequisites**:
   - Run `git rev-parse --git-dir 2>/dev/null` to confirm we are in a git repo
   - Run `which git-issue 2>/dev/null` to confirm git-issue is installed
   - If git-issue is not initialized (`git config --get issue.remote` fails and there is a remote), run `git issue init` first

2. **Construct the command** from parsed arguments. Pass the title as the first positional argument, flags after.

3. **Execute** `git issue create` and capture the output.

4. **Report** the created issue ID and suggest next actions:
   - `git issue show <id>` to see details
   - `git issue edit <id> --add-label in-progress` to start working on it

## Examples

```
/claude-git-native-issue:create "Fix auth bug" -l bug -p high
/claude-git-native-issue:create "Add dark mode" -m "Users requested dark theme support" -l feature
/claude-git-native-issue:create "Refactor database layer" -l refactor -l elixir -p medium
```
