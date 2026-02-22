---
name: setup
description: Initialize git-native-issue in the current repository and configure Claude integration
disable-model-invocation: true
---

# git-native-issue — Setup

Guide the user through initializing git-native-issue in the current repository and configuring the integration with Claude Code.

## Steps

### 1. Check prerequisites

Run these checks in parallel:
- `which git-issue 2>/dev/null` — verify git-issue is installed
- `git rev-parse --git-dir 2>/dev/null` — verify we are in a git repo

If git-issue is not installed:
- Tell the user: "git-native-issue is not installed."
- Provide the install command: `brew install remenoscodes/git-native-issue/git-native-issue`
- Stop here until installed.

If not in a git repo:
- Tell the user: "You are not in a git repository. git-native-issue requires a git repo."
- Stop here.

### 2. Check if already initialized

Run `git config --get issue.remote 2>/dev/null`

If already configured:
- Tell the user: "git-native-issue is already initialized with remote: `<remote>`"
- Skip to step 4.

### 3. Initialize

Determine the remote name. Check available remotes with `git remote`.

- If only one remote exists, use it automatically.
- If multiple remotes exist, ask the user which one to use (default: `origin`).
- If no remotes exist, tell the user git-issue will work locally without sync.

Run `git issue init <remote>` (skip if no remote).

Verify with `git config --get issue.remote`.

### 4. Detect and configure platform provider

Detect the platform from the remote URL to enable automatic sync with GitHub/GitLab/Gitea.

```bash
REMOTE_URL=$(git remote get-url <remote> 2>/dev/null)
```

**Auto-detection**:
- `github.com` → `github:owner/repo`
- `gitlab.com` → `gitlab:group/project`
- Other hosts → ask the user if it is Gitea/Forgejo, or skip

**For self-hosted instances**: Ask the user for the provider string. Examples:
- `gitea:owner/repo` for Gitea
- `gitlab:group/project` for self-hosted GitLab

**Store the provider** for automatic sync:
```bash
git config git-issue.provider "<detected-or-user-provided>"
```

**Verify platform access**:
- GitHub: `gh auth status` (must be authenticated)
- GitLab: `glab auth status` or check `GITLAB_TOKEN`
- Gitea/Forgejo: check `GITEA_TOKEN` or `FORGEJO_TOKEN`

If the user is not authenticated, provide the auth command and skip provider config for now.

### 5. Configure auto-sync refspecs (optional)

Ask the user if they want bidirectional sync for issue refs (auto-fetch and auto-push when running `git fetch` / `git push`).

If yes, check the current remote config and add these refspecs if not already present:

```bash
git config --get-all remote.<remote>.fetch | grep -q 'refs/issues' || \
  git config --add remote.<remote>.fetch '+refs/issues/*:refs/issues/*'

git config --get-all remote.<remote>.push | grep -q 'refs/issues' || \
  git config --add remote.<remote>.push 'refs/issues/*'
```

### 6. Initial sync

If a provider was configured, run the first sync to import existing issues from the platform:

```bash
PROVIDER=$(git config --get git-issue.provider 2>/dev/null)
if [ -n "$PROVIDER" ]; then
  git issue sync "$PROVIDER" --state all
fi
```

Report how many issues were imported.

### 7. CLAUDE.md integration (optional)

Ask the user if they want to add the git-issue task management section to their CLAUDE.md.

Determine the location:
- `~/.claude/CLAUDE.md` — global (all projects)
- Project-level CLAUDE.md — current project only

Check if a `# Task Management: git-native-issue` section already exists. If so, tell the user it is already configured and skip.

If not present, add a minimal section with:
- Task lifecycle mapping table
- Status convention
- Priority mapping
- Label conventions

Keep it concise. The full reference is in the `git-issue-tracker` skill.

### 8. Verify

Run `git issue ls` to verify everything works.

Summarize what was configured:
- Remote: `<remote>` (or "local only")
- Provider: `<provider>` (e.g., `github:owner/repo`) or "none (local only)"
- Auto-sync refspecs: enabled/disabled
- Platform sync: enabled/disabled (with number of issues imported)
- CLAUDE.md: updated/skipped
- Tell the user the `UserPromptSubmit` hook is already active from the plugin install
- Tell the user that issues will be automatically synced with the platform after create/close operations
- Suggest: "Try `git issue create \"Test issue\" -l test` to create your first issue"
