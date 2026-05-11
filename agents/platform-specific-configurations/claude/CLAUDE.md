# Claude Code Configuration

## Tools (Claude-Specific)

- **Agent**: Launch specialized subagents (code-reviewer, clean-code-writer, etc.)
- **Skill**: Invoke workflows (brainstorming, systematic-debugging, test-driven-development, etc.)
    - Skills stored in `~/.claude/agents/`
- **Read/Write/Edit**: Prefer these over Bash for file operations
- **Task**: Create/update/list tasks for multi-step work

## Permission Model

Configure auto-approve patterns in `~/.claude/settings.json` to reduce prompts when reading from `~/.config/agents/`
