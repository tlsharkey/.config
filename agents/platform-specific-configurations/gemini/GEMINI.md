# Gemini CLI Configuration

## Tools (Gemini-Specific)

- **skill**: Invoke workflows (available skills listed in system context)
    - Skills stored in `~/.gemini/antigravity/skills/`
- **Extensions**: Additional capabilities via MCP protocol
    - Extensions stored in `~/.gemini/extensions/`

## Orchestration Strategy

- **Heavily use skills**: Gemini CLI is designed around skill-based workflows
- **Multiple perspectives**: Use different skills to get varied approaches to problems
- **Compose solutions**: Chain skills together for complex tasks
