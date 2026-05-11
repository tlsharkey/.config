# Agent Conventions

## Documentation Structure

All projects should use the `.agents/` directory for AI-readable documentation:

```
.agents/
├── AGENTS.md          # Optional: project-specific instructions
├── docs/              # Architecture and design documentation
├── specs/             # Feature specifications
├── plans/             # Implementation plans
└── decisions/         # Architecture decision records (ADRs)
```

### Documentation Lookup Priority

When working in a project, check for documentation in this order:

1. **Project-specific**: `./.agents/` (always check here first)
2. **Project instructions**: `./.agents/AGENTS.md` (if exists, contains project-specific conventions)
3. **Global conventions**: `~/.config/agents/AGENTS.md` (your personal working style)
4. **Templates**: `~/.config/agents/templates/` (starting points for new documents)

## Markdown File Naming Conventions

- **Use kebab-case**: `user-authentication.md`, `api-refactor.md`
- **Date implementation plans**: `2026-05-06-api-refactor.md`
- **Number architecture decisions**: `001-database-choice.md`, `002-auth-strategy.md`
- **Lowercase for docs/**: All files in `docs/` should be lowercase
- **Uppercase exceptions**: Only `README.md` and `TODO.md` should be uppercase, in repository root

## Commit Workflow

### Pre-Commit Requirements

- **Run tests first**: Always run tests before committing anything more than a couple of lines
- **Verify with user**: Always verify with user before committing
- **Evaluate changes**: Before committing, list all changes and evaluate each for necessity
- **Update documentation**: Check if README.md or docs/ need updates before committing

### What NOT to Commit

- Logs and working memory files
- Reports used for LLM orchestration and planning
- Temporary files or session data
- `.claude/`, `.gemini/`, `.agents/` directories (tool-specific, should be gitignored)

### What to Commit

- Repository documentation (README.md, docs/)
- Source code and tests
- Configuration files needed by the project

## Code Style

### Readability Principles

- **Code should read like a book**: Write for human comprehension first
- **Self-explanatory implementation**: The code itself should explain how it works
- **Goal-oriented comments**: Comments should state objectives and why, not what
- **Minimal docstrings**: Use docstring-compatible comments that are minimal and only verbose when necessary

### Complex Code

- **For complex algorithms**: Extra comments and diagrams are acceptable
- **Pseudo code first**: Write pseudo code with high-level goals and structure first, then replace with actual code

## Communication Style

### Precision of Language

- Avoid sycophancy
- Report factually
- Fact-check yourself
- Don't oversell or overstate
- Don't brag
- Make concrete, measurable, humble statements

## Working Practices

### Reflection

- **Consistently self-reflect**: What are you doing, why, and how is it helpful?
- **Check for task drift**: Have you lost sight of the original task?
- **Question assumptions**: Challenge your own understanding regularly

### Upskilling the User

- **Teach while working**: The more you teach, the more effective collaboration becomes long-term
- **Orient in the codebase**: When making large changes, explain the structure and context
- **Describe data flow**: Help the user understand how information moves through the system
- **Explain decisions**: Share the reasoning behind technical choices

### Environment Variables

- **Always ask first**: Before reading potentially sensitive files (`.env`, `.venv/bin/activate`, etc.)
- **Protect secrets**: Never read environment variables that might contain API keys or sensitive information without explicit permission
- **Flag sensitive data**: If you encounter credentials or secrets, warn the user immediately

### Using Specialized Workflows

- **Default to specialized workflows**: Always check for and use available specialist workflows before attempting complex tasks manually
- **Require multiple perspectives**: Before any significant decision, actively seek opposing viewpoints — arguments for AND against
- **Adversarial review before finalizing**: Run critical/red-team review on proposed changes, architectures, and decisions. Do not skip this step
- **Multi-step orchestration**: Decompose complex problems into structured workflow chains rather than attempting monolithic solutions
- **Never commit to the first approach**: Explore at least two viable alternatives before proceeding

## Diagrams

### Diagram Policy

- Never use browser-rendered diagrams (no Mermaid, DOT/Graphviz, PlantUML, or similar)
- ASCII diagrams only
- Present all decision information inline in text before asking for user input
- Keep diagrams simple and readable in monospace font
