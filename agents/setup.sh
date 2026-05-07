#!/usr/bin/env bash
# Setup script for multi-agent configuration system
# Detects installed coding assistants and configures them to reference shared conventions

set -euo pipefail

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directory paths
AGENTS_DIR="$HOME/.config/agents"

# Marker for detecting existing configuration blocks
REFERENCE_MARKER="<!-- AUTO-GENERATED: Reference to AGENTS.md -->"

# Tool registry: name|config_dir|config_file|source_template
# Format: Each entry defines where a tool's config lives and which template to use
TOOLS=(
  "Claude Code|$HOME/.claude|CLAUDE.md|platform-specific-configurations/claude/CLAUDE.md"
  "Gemini CLI|$HOME/.gemini|GEMINI.md|platform-specific-configurations/gemini/GEMINI.md"
  "OpenClaw|$HOME/.openclaw|OPENCLAW.md|platform-specific-configurations/openclaw/OPENCLAW.md"
  "Cursor|$HOME/.cursor|rules.md|platform-specific-configurations/cursor/rules.md"
  "Aider|$HOME/.aider|CONVENTIONS.md|platform-specific-configurations/aider/CONVENTIONS.md"
  "Windsurf|$HOME/.windsurf|rules.md|platform-specific-configurations/windsurf/rules.md"
)

# Verify AGENTS.md exists
if [[ ! -f "$AGENTS_DIR/AGENTS.md" ]]; then
  echo -e "${RED}Error: AGENTS.md not found at $AGENTS_DIR/AGENTS.md${NC}"
  echo "Please ensure the agents directory is properly set up with AGENTS.md"
  exit 1
fi

echo -e "${GREEN}✓ AGENTS.md found${NC}"
echo -e "${BLUE}Setup script initialized successfully${NC}"

# ============================================================================
# Helper Functions - All designed to be idempotent
# ============================================================================

# Check if path is a regular file (not a symlink)
is_regular_file() {
  local path="$1"
  [[ -f "$path" && ! -L "$path" ]]
}

# Check if path is a symlink pointing to the expected target
is_correct_symlink() {
  local path="$1"
  local expected_target="$2"

  if [[ -L "$path" ]]; then
    local actual_target
    actual_target=$(readlink "$path")
    [[ "$actual_target" == "$expected_target" ]]
  else
    return 1
  fi
}

# Check if file already contains the reference block marker
has_reference_block() {
  local file="$1"

  if [[ -f "$file" ]]; then
    grep -qF "$REFERENCE_MARKER" "$file"
  else
    return 1
  fi
}

# Create backup of file (idempotent - only creates if backup doesn't exist)
backup_file() {
  local file="$1"
  local backup="${file}.backup"

  if [[ -f "$backup" ]]; then
    echo -e "${YELLOW}  Backup already exists: $backup${NC}"
    return 0
  fi

  if [[ -f "$file" ]]; then
    cp "$file" "$backup"
    echo -e "${GREEN}  Created backup: $backup${NC}"
  else
    echo -e "${YELLOW}  No file to backup: $file${NC}"
    return 1
  fi
}

# Prepend reference block to file (idempotent - only adds if not present)
prepend_reference_block() {
  local file="$1"

  # Check if reference block already exists
  if has_reference_block "$file"; then
    echo -e "${BLUE}  Reference block already present in $file${NC}"
    return 0
  fi

  # Create reference block content
  local reference_block="$REFERENCE_MARKER
# IMPORTANT: Read Global Conventions First

**Before proceeding, read:** \`~/.config/agents/AGENTS.md\`

This file contains all shared conventions, style preferences, and working practices.
The instructions below are tool-specific technical features only.

---

"

  # Create temporary file with reference block + original content
  local temp_file="${file}.tmp"
  echo "$reference_block" > "$temp_file"

  if [[ -f "$file" ]]; then
    cat "$file" >> "$temp_file"
  fi

  # Replace original with new content
  mv "$temp_file" "$file"
  echo -e "${GREEN}  Prepended reference block to $file${NC}"
}

# Create symlink (idempotent - only creates if not already correct)
create_config_symlink() {
  local link_path="$1"
  local target_path="$2"

  # Check if correct symlink already exists
  if is_correct_symlink "$link_path" "$target_path"; then
    echo -e "${BLUE}  Symlink already correct: $link_path -> $target_path${NC}"
    return 0
  fi

  # If something exists at link_path but isn't the correct symlink
  if [[ -e "$link_path" || -L "$link_path" ]]; then
    echo -e "${YELLOW}  Removing existing file/symlink at $link_path${NC}"
    rm "$link_path"
  fi

  # Create the symlink
  ln -s "$target_path" "$link_path"
  echo -e "${GREEN}  Created symlink: $link_path -> $target_path${NC}"
}

# Show summary of what was set up and next steps
show_summary() {
  echo -e "${GREEN}✓ Setup Complete!${NC}"
  echo ""

  echo -e "${BLUE}=== Global Configuration ===${NC}"
  echo "  Core conventions: ~/.config/agents/AGENTS.md"
  echo "  Templates:        ~/.config/agents/templates/"
  echo "  Workflows:        ~/.config/agents/workflows/"
  echo ""

  # Detect which tools were actually configured
  local configured_tools=()
  if [[ -f "$HOME/.claude/CLAUDE.md" || -L "$HOME/.claude/CLAUDE.md" ]]; then
    configured_tools+=("~/.claude/CLAUDE.md")
  fi
  if [[ -f "$HOME/.gemini/GEMINI.md" || -L "$HOME/.gemini/GEMINI.md" ]]; then
    configured_tools+=("~/.gemini/GEMINI.md")
  fi
  if [[ -f "$HOME/.openclaw/OPENCLAW.md" || -L "$HOME/.openclaw/OPENCLAW.md" ]]; then
    configured_tools+=("~/.openclaw/OPENCLAW.md")
  fi
  if [[ -f "$HOME/.cursor/rules.md" || -L "$HOME/.cursor/rules.md" ]]; then
    configured_tools+=("~/.cursor/rules.md")
  fi
  if [[ -f "$HOME/.aider/CONVENTIONS.md" || -L "$HOME/.aider/CONVENTIONS.md" ]]; then
    configured_tools+=("~/.aider/CONVENTIONS.md")
  fi
  if [[ -f "$HOME/.windsurf/rules.md" || -L "$HOME/.windsurf/rules.md" ]]; then
    configured_tools+=("~/.windsurf/rules.md")
  fi

  if [[ ${#configured_tools[@]} -gt 0 ]]; then
    echo -e "${BLUE}=== Tool Configurations ===${NC}"
    for tool_config in "${configured_tools[@]}"; do
      echo "  $tool_config"
    done
    echo ""
  fi

  echo -e "${BLUE}=== Quick Start for New Projects ===${NC}"
  echo "  1. Navigate to your project directory"
  echo "  2. Create project-specific agents directory:"
  echo "     mkdir .agents"
  echo "  3. Subdirectories (specs/, plans/, workflows/) are created automatically"
  echo ""

  echo -e "${BLUE}=== Learn More ===${NC}"
  echo "  cat ~/.config/agents/README.md"
  echo ""

  echo "Your coding assistants are now configured to reference shared conventions."
  echo "Happy building!"
  echo ""
}

# Show permission configuration suggestions to reduce prompts
show_permission_suggestions() {
  echo -e "${BLUE}=== Permission Configuration Suggestions ===${NC}"
  echo ""
  echo "To reduce permission prompts when agents read from ~/.config/agents/,"
  echo "you can configure auto-approval patterns in your settings files."
  echo ""

  echo -e "${YELLOW}Claude Code${NC}"
  echo -e "  Settings file: ${YELLOW}~/.claude/settings.json${NC}"
  echo "  Add these patterns to: autoApprove → Read"
  echo "    - ~/.config/agents/**/*.md"
  echo "    - ~/.config/agents/templates/**"
  echo "    - ~/.config/agents/workflows/**"
  echo ""

  echo -e "${YELLOW}Gemini CLI${NC}"
  echo -e "  Settings file: ${YELLOW}~/.gemini/settings.json${NC}"
  echo "  Add similar patterns to reduce prompts"
  echo ""

  echo "For details, see the settings-additions.json files in each"
  echo "platform-specific configuration directory."
  echo ""
}

# ============================================================================
# Main Configuration Loop
# ============================================================================

# Initialize counters
configured_count=0
skipped_count=0

echo ""
echo -e "${BLUE}=== Detecting Installed Coding Assistants ===${NC}"
echo ""

# Loop through all registered tools
for tool_entry in "${TOOLS[@]}"; do
  # Parse pipe-delimited fields
  IFS='|' read -r tool_name config_dir config_file source_template <<< "$tool_entry"

  echo -e "${BLUE}Checking: $tool_name${NC}"

  # Check if config directory exists
  if [[ ! -d "$config_dir" ]]; then
    echo -e "${YELLOW}  Skipped: Directory not found ($config_dir)${NC}"
    ((skipped_count++))
    echo ""
    continue
  fi

  echo -e "${GREEN}  Detected: $tool_name is installed${NC}"

  # Full path to config file
  config_path="$config_dir/$config_file"

  # Full path to source template
  source_path="$AGENTS_DIR/$source_template"

  # ---- FILE STATE HANDLING ----

  # Case 1: Config file exists as regular file
  if is_regular_file "$config_path"; then
    echo -e "${BLUE}  Found existing $config_file${NC}"

    # Backup the existing file
    backup_file "$config_path"

    # Prepend reference block
    prepend_reference_block "$config_path"

    echo -e "${GREEN}  ✓ Configured $tool_name (modified existing file)${NC}"
    ((configured_count++))

  # Case 2: Config file is already correct symlink
  elif is_correct_symlink "$config_path" "$source_path"; then
    echo -e "${BLUE}  Already configured (symlink to $source_template)${NC}"
    ((configured_count++))

  # Case 3: Config file doesn't exist and source template exists
  elif [[ ! -e "$config_path" && -f "$source_path" ]]; then
    echo -e "${YELLOW}  No existing $config_file found${NC}"

    # Create symlink to template
    create_config_symlink "$config_path" "$source_path"

    echo -e "${GREEN}  ✓ Configured $tool_name (created symlink)${NC}"
    ((configured_count++))

  # Case 4: Config file doesn't exist and source template missing
  elif [[ ! -e "$config_path" && ! -f "$source_path" ]]; then
    echo -e "${RED}  Warning: No existing $config_file and template not found at $source_template${NC}"

  # Case 5: File exists but is wrong symlink or other unexpected state
  else
    if [[ -L "$config_path" ]]; then
      actual_target=$(readlink "$config_path")
      echo -e "${YELLOW}  Found symlink to unexpected target: $actual_target${NC}"
      echo -e "${YELLOW}  Updating to correct target...${NC}"

      # Use helper to fix symlink
      create_config_symlink "$config_path" "$source_path"

      echo -e "${GREEN}  ✓ Configured $tool_name (fixed symlink)${NC}"
      ((configured_count++))
    else
      echo -e "${RED}  Warning: Unexpected file state for $config_path${NC}"
    fi
  fi

  echo ""
done

# ============================================================================
# Summary Report
# ============================================================================

echo -e "${BLUE}=== Configuration Summary ===${NC}"
echo -e "${GREEN}  Configured: $configured_count tool(s)${NC}"
echo -e "${YELLOW}  Skipped: $skipped_count tool(s) (not installed)${NC}"
echo ""

if [[ $configured_count -gt 0 ]]; then
  echo -e "${GREEN}✓ Setup complete! Your coding assistants are now configured.${NC}"
  echo -e "${BLUE}All tools will reference: $AGENTS_DIR/AGENTS.md${NC}"
else
  echo -e "${YELLOW}No tools were configured. Install a supported coding assistant and run this script again.${NC}"
fi

echo ""
show_summary
show_permission_suggestions
