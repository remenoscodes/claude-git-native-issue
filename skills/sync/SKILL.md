---
name: sync
description: Sync git-native-issues with remote or a platform (GitHub, GitLab, Gitea)
argument-hint: "[push|pull|merge|github:owner/repo|gitlab:group/project|gitea:owner/repo]"
disable-model-invocation: true
---

# git-native-issue — Sync

Synchronize issues with a remote or an external platform.

## Arguments

`$ARGUMENTS` determines the sync direction and target:

| Argument | Action |
|----------|--------|
| (empty) | Push and fetch issue refs to/from configured remote |
| `push` | Push issue refs: `git push origin 'refs/issues/*'` |
| `pull` | Fetch issue refs: `git fetch origin 'refs/issues/*:refs/issues/*'` |
| `merge` | Merge divergent issues from remote: `git issue merge origin` |
| `github:<owner>/<repo>` | Two-way sync with GitHub: `git issue sync github:<owner>/<repo> --state all` |
| `gitlab:<group>/<project>` | Two-way sync with GitLab: `git issue sync gitlab:<group>/<project> --state all` |
| `gitea:<owner>/<repo>` | Two-way sync with Gitea: `git issue sync gitea:<owner>/<repo> --state all` |

## Steps

1. **Verify prerequisites**: git repo, git-issue installed, remote configured (`git config --get issue.remote`).

2. **For platform syncs**, verify required CLI tools:
   - GitHub: `gh` CLI + `jq`
   - GitLab: `glab` CLI + `jq`
   - Gitea/Forgejo: `jq` only

3. **Execute the sync command**.

4. **Report results**: number of issues synced, any conflicts detected.

5. **For empty argument** (default sync): run both push and pull in sequence:
   ```bash
   git push origin 'refs/issues/*'
   git fetch origin 'refs/issues/*:refs/issues/*'
   ```

## Examples

```
/claude-git-native-issue:sync                              → push + pull issue refs
/claude-git-native-issue:sync push                         → push only
/claude-git-native-issue:sync github:remenoscodes/match-os → full GitHub sync
/claude-git-native-issue:sync merge                        → merge divergent remote issues
```
