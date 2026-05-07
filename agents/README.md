# Multi-Agent Configuration

Unified configuration and conventions for AI coding assistants (Claude Code, Gemini CLI, etc.).

## Structure

```
~/.config/agents/
├── AGENTS.md                           # Core conventions (READ THIS FIRST)
├── templates/                          # Reusable document templates
│   ├── spec-template.md               # Feature specification template
│   ├── plan-template.md               # Implementation plan template
│   └── adr-template.md                # Architecture decision record template
├── workflows/                          # Standard workflows
│   ├── feature-development.md         # Complete feature development process
│   └── bug-fix-workflow.md            # Systematic bug fixing process
└── platform-specific-configurations/  # Tool-specific configs
    ├── claude/
    │   ├── CLAUDE.md                  # Claude Code configuration
    │   └── settings-additions.json    # Permission suggestions
    └── gemini/
        ├── GEMINI.md                  # Gemini CLI configuration
        └── settings-additions.json    # Permission suggestions
```

## Quick Start

### First Time Setup

Run the setup script (when created):
```bash
~/.config/agents/setup.sh
```

This will:
- Back up existing `~/.claude/CLAUDE.md` and `~/.gemini/GEMINI.md` (if they exist)
- Either prepend references to AGENTS.md or create symlinks
- Suggest permission additions for easier access

### Using in Projects

Agents will automatically create `.agents/` and subdirectories when writing documentation. If agents aren't creating documentation and you want them to, you can manually create the directory as a hint:

```bash
mkdir .agents
```

That's it! No symlinks, no per-project scripts needed.

## Documentation Hierarchy

Both Claude and Gemini will check for documentation in this order:

1. **Project-specific**: `./.agents/` - Documentation for this specific project
2. **Project conventions**: `./.agents/AGENTS.md` - Project-specific conventions (optional)
3. **Global conventions**: `~/.config/agents/AGENTS.md` - Your personal working style
4. **Templates**: `~/.config/agents/templates/` - Starting points for new documents

## Key Files

### AGENTS.md
Contains all your working conventions, code style, communication preferences, and documentation structure. Both Claude and Gemini read this file to understand how you work.

### Platform-Specific Configurations
- **CLAUDE.md**: Claude Code-specific tool usage (Agent tool, Skills, etc.)
- **GEMINI.md**: Gemini CLI-specific tool usage (skills, extensions, etc.)

These contain ONLY technical instructions for using each tool's features. All style and conventions are in AGENTS.md.

## Templates

### spec-template.md
Use for new feature specifications. Copy to project `.agents/specs/` and fill in.

### plan-template.md
Use for implementation plans. Copy to project `.agents/plans/` and track progress.

### adr-template.md
Use for architecture decision records. Copy to project `.agents/decisions/` and number sequentially (001-, 002-, etc.).

## Workflows

### feature-development.md
Complete workflow from planning through deployment for new features.

### bug-fix-workflow.md
Systematic approach to investigating and fixing bugs.

## Design Philosophy

### Single Source of Truth
- `AGENTS.md` is the canonical source for conventions
- Templates provide starting points, not rigid rules
- Project `.agents/` directories override global settings when needed

### Tool-Agnostic
- Avoid naming conflicts ("agents" vs "skills")
- Core conventions work with any AI coding assistant
- Tool-specific configs only cover technical features

### Zero Project Setup
- Just create `.agents/` directory in project
- No symlinks required
- No per-project scripts

### Minimal and Clean
- Tool configs are brief (reference AGENTS.md for details)
- Templates are comprehensive but not prescriptive
- Workflows provide structure without rigidity

## Maintenance

### Updating Conventions
Edit `AGENTS.md` directly. Changes will be picked up on next read by both tools.

### Updating Tool Configs
- **If symlinked**: Edit files in `platform-specific-configurations/`, changes apply immediately
- **If customized**: Edit `~/.claude/CLAUDE.md` or `~/.gemini/GEMINI.md` directly

### Adding Templates
Add new `.md` files to `templates/` directory. Reference them in AGENTS.md or tool configs as needed.

### Adding Workflows
Add new `.md` files to `workflows/` directory. These serve as reference documentation.

## Troubleshooting

### Agent not following conventions
1. Check that tool config references `~/.config/agents/AGENTS.md`
2. Verify AGENTS.md is readable (check permissions)
3. Ask agent directly: "Have you read ~/.config/agents/AGENTS.md?"

### Can't find templates
1. Verify `~/.config/agents/templates/` exists
2. Check file permissions
3. Templates are references, not auto-loaded - you need to copy them to projects

### Project .agents/ not being used
1. Verify `.agents/` directory exists in project root
2. Check that documentation files exist in `.agents/docs/`, `.agents/specs/`, etc.
3. Explicitly reference files in conversations: "Check .agents/specs/feature-name.md"

## Further Customization

### Project-Specific Conventions
Create `.agents/AGENTS.md` in your project with project-specific rules. This supplements (or overrides) global AGENTS.md.

### Custom Templates
Copy templates to your project and modify them. Or create new templates in `~/.config/agents/templates/` for reuse.

### Tool-Specific Overrides
Edit `~/.claude/CLAUDE.md` or `~/.gemini/GEMINI.md` directly for tool-specific customizations.
