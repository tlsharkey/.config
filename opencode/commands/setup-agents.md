---
description: Set up .agents directory structure with opencode.json config
agent: build
---

Set up project for .agents/ based opencode configuration:

!`mkdir -p .agents/{memory,sessions,tasks,docs}`

!`ln -sfn .agents .opencode`

!`[ -f .agents/AGENTS.md ] || printf '# Project Instructions\n\n## Overview\nBrief description of this project.\n\n## Conventions\n- Code style, patterns, etc.\n\n## Key Files\n- Important files and their purposes\n' > .agents/AGENTS.md`

!`if [ -f opencode.json ]; then
  if ! grep -q '"instructions"' opencode.json; then
    if command -v jq >/dev/null 2>&1; then
      jq '.instructions = [".agents/AGENTS.md"]' opencode.json > opencode.json.tmp && mv opencode.json.tmp opencode.json
    else
      echo "opencode.json exists - please manually add: \"instructions\": [\".agents/AGENTS.md\"]"
    fi
  fi
else
  printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "instructions": [".agents/AGENTS.md"]\n}\n' > opencode.json
fi
`

!`grep -q "^.opencode$" .gitignore 2>/dev/null || echo ".opencode" >> .gitignore`
!`grep -q "^.agents$" .gitignore 2>/dev/null || echo ".agents" >> .gitignore`

!`[ -f .ignore ] || touch .ignore`
!`grep -q "^.opencode$" .ignore 2>/dev/null || echo ".opencode" >> .ignore`
!`grep -q "^.agents$" .ignore 2>/dev/null || echo ".agents" >> .ignore`

Done! Project configured with:
- `.agents/{memory,sessions,tasks,docs}/` directories
- `.opencode` → `.agents` symlink
- `.agents/AGENTS.md` template
- `opencode.json` with instructions config
- Both dirs added to `.gitignore` and `.ignore`