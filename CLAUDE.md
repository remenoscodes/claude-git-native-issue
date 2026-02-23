# claude-git-native-issue

Claude Code plugin that replaces internal task management with git-native-issue. Autonomous issue creation, tracking, and resolution stored as Git refs.

Inherits workspace conventions from `~/CLAUDE.md`.

## Status
- **Version**: 1.0.1
- **State**: active
- **Deploy**: Claude Code plugin via `remenoscodes/claude-plugin-marketplace`

## Stack
Claude Code plugin system: shell hooks (Bash), Markdown skills.
Requires: `git-native-issue` CLI installed (`brew install remenoscodes/git-native-issue/git-native-issue`).

## Key Commands
```bash
/claude-git-native-issue:setup       # Initialize git-issue in repo and configure integration
/claude-git-native-issue:create      # Create a new issue
/claude-git-native-issue:issues      # List issues with filtering
/claude-git-native-issue:show <id>   # Show issue details and comments
/claude-git-native-issue:close <id>  # Close an issue
/claude-git-native-issue:sync        # Sync issues with remote or platform
```

## Architecture
- `hooks/` — UserPromptSubmit hook injecting context on every prompt (autonomous trigger rules)
- `skills/` — Ambient skill (`git-issue-tracker`, full CLI reference) + 6 user-invocable slash commands
- Three-layer activation: hook (every prompt) + ambient skill (decision rules) + slash commands (manual)
- Autonomous behavior: auto-create on multi-step work, auto-update with progress, auto-close on completion
- Flat plugin structure required: `.claude-plugin/`, `hooks/`, `skills/` at repo root (not nested)

## Related Projects
- `~/source/remenoscodes.git-native-issue` — The CLI tool this plugin wraps
- `~/source/remenoscodes.claude-plugin-marketplace` — Central marketplace distributing this plugin
