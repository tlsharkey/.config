# Gemini CLI Configuration

## Tools (Gemini-Specific)

- **skill**: Invoke workflows (available skills listed in system context)
    - Skills stored in `~/.gemini/antigravity/skills/`
- **Extensions**: Additional capabilities via MCP protocol
    - Extensions stored in `~/.gemini/extensions/`

## .agents/ Directory Access

- **Permissions**: Gemini CLI will read and write `.agents/` directory without manual confirmation. Ensure `security.folderTrust` is configured to trust directories containing `.agents/` or use YOLO mode (`--yolo`) when running autonomous tasks.
- **Conventions**: Refer to global `AGENTS.md` for conventions on `.agents/` layout and workflows.

## Orchestration Strategy

- **Heavily use skills**: Gemini CLI is designed around skill-based workflows
- **Multiple perspectives**: Use different skills to get varied approaches to problems
- **Compose solutions**: Chain skills together for complex tasks
