# Contributing

Contributions are welcome.

## Development

### Structure

```
.claude-plugin/plugin.json    # Plugin manifest
hooks/
├── hooks.json                # Hook definitions
└── task-intercept.sh         # UserPromptSubmit hook script
skills/
├── git-issue-tracker/SKILL.md  # Ambient reference (non-user-invocable)
├── setup/SKILL.md              # /setup command
├── create/SKILL.md             # /create command
├── issues/SKILL.md             # /issues command
├── show/SKILL.md               # /show command
├── close/SKILL.md              # /close command
└── sync/SKILL.md               # /sync command
```

### Adding a New Skill

1. Create a directory under `skills/<name>/`
2. Add a `SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: <name>
   description: <when this skill should activate>
   disable-model-invocation: true  # for user-invocable skills
   ---
   ```
3. Write step-by-step instructions in the body
4. Update CHANGELOG.md with the new feature
5. Bump version in `plugin.json`

### Skill Types

- **Ambient** (`user-invocable: false`): Claude invokes automatically when context matches the description
- **User-invocable** (`disable-model-invocation: true`): User calls via `/claude-git-native-issue:<name>`

### Testing

Run the CI validation locally:

```bash
# Validate JSON files
python3 -c "import json; json.load(open('.claude-plugin/plugin.json'))"
python3 -c "import json; json.load(open('hooks/hooks.json'))"

# Validate hook script output
bash hooks/task-intercept.sh | python3 -c "import json, sys; json.load(sys.stdin)"

# Check SKILL.md frontmatter
for f in skills/*/SKILL.md; do
  head -1 "$f" | grep -q "^---" && echo "OK: $f" || echo "FAIL: $f"
done
```

### Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new skills, commands, or hook features
- `fix:` bug fixes in existing skills
- `docs:` README, CONTRIBUTING, CHANGELOG updates
- `chore:` CI, tooling, metadata changes

## License

By contributing, you agree that your contributions will be licensed under GPL-2.0.
