#!/usr/bin/env bash

# git-native-issue task intercept — injected on every user prompt via UserPromptSubmit hook.
# Reminds Claude to use `git issue` commands instead of internal TaskCreate/TaskUpdate/TaskList tools.
# Also defines autonomous behavior: when to create/update/close issues without being asked.
# Uses hookSpecificOutput.additionalContext for silent context injection (not shown to user).

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "git-native-issue is active. For ALL task tracking, use `git issue` commands via Bash instead of internal TaskCreate/TaskUpdate/TaskList tools. Quick reference: create → `git issue create \"title\" -m \"desc\" -l label -p priority`, list → `git issue ls`, show → `git issue show <id>`, progress → `git issue edit <id> --add-label in-progress`, close → `git issue state <id> --close -m \"reason\"`, search → `git issue search \"pattern\"`. AUTONOMOUS BEHAVIOR: (1) Auto-create issues when user starts multi-step work, approves a plan, or discovers a bug. (2) Auto-update with `--add-label in-progress` when starting work, `git issue comment` for progress. (3) Auto-close when task completes successfully. (4) Skip tracking for trivial changes, one-off questions, or when not in a git repo. (5) PLATFORM SYNC: After creating or closing issues, sync with the provider. Detect provider from git remote URL (github.com → github:owner/repo, gitlab.com → gitlab:group/project, gitea/forgejo → gitea:owner/repo). Run `git issue sync <provider>` after mutations. Check `git config --get git-issue.provider` for cached provider string. Before any git-issue command, verify you are in a git repo. Then verify the correct tool is installed: run `git issue create --help 2>/dev/null` — if this fails, the wrong `git issue` tool may be installed (Spinellis' git-issue uses `new` instead of `create`). If git-issue is not initialized, run `git issue init` first. Invoke the `git-issue-tracker` skill for full reference when needed."
  }
}
EOF
exit 0
