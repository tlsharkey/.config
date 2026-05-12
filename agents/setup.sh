#!/usr/bin/env bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Multi-Agent Configuration Setup${NC}"
echo ""

AGENTS_DIR="$HOME/.config/agents"
GENERATED_DIR="$AGENTS_DIR/.generated"

# Check if processor is available
check_processor() {
    local processor="$1"
    command -v "$processor" >/dev/null 2>&1
}

# Get merge strategy by file extension
get_merge_strategy() {
    local filename="$1"
    local ext="${filename##*.}"

    # Handle special case: settings-additions.json → target is settings.json
    if [[ "$filename" == "settings-additions.json" ]]; then
        if check_processor jq; then
            echo "json:settings.json"
        else
            echo "skip:no-jq"
        fi
        return
    fi

    case "$ext" in
        md)
            # Uppercase .md files get AGENTS.md prepended
            if [[ "$filename" =~ ^[A-Z] ]]; then
                echo "concat_with_agents"
            else
                echo "copy"
            fi
            ;;
        txt)
            echo "copy"
            ;;
        json)
            if check_processor jq; then
                echo "json"
            else
                echo "skip:no-jq"
            fi
            ;;
        yaml|yml)
            if check_processor yq; then
                echo "yaml"
            else
                echo "skip:no-yq"
            fi
            ;;
        *)
            echo "skip:unknown-format"
            ;;
    esac
}

# Get target path for a platform and filename
get_target_path() {
    local platform="$1"
    local filename="$2"
    echo "$HOME/.$platform/$filename"
}

# Get shadow path
get_shadow_path() {
    local platform="$1"
    local filename="$2"
    echo "$GENERATED_DIR/$platform/$filename"
}

# Verify AGENTS.md exists
if [ ! -f "$AGENTS_DIR/AGENTS.md" ]; then
    echo -e "${RED}Error: AGENTS.md not found in $AGENTS_DIR${NC}"
    echo "Ensure ~/.config/agents/ is set up with AGENTS.md before running."
    exit 1
fi

echo -e "${GREEN}[ok]${NC} Found configuration directory: $AGENTS_DIR"

# Compare files based on format
files_equal() {
    local file1="$1"
    local file2="$2"
    local format="$3"

    case "$format" in
        json)
            # Normalize and compare JSON structure
            local norm1=$(jq --sort-keys -c '.' "$file1" 2>/dev/null)
            local norm2=$(jq --sort-keys -c '.' "$file2" 2>/dev/null)
            [[ "$norm1" == "$norm2" ]]
            ;;
        yaml)
            # Normalize and compare YAML structure
            local norm1=$(yq eval --prettyPrint=false '.' "$file1" 2>/dev/null | sort)
            local norm2=$(yq eval --prettyPrint=false '.' "$file2" 2>/dev/null | sort)
            [[ "$norm1" == "$norm2" ]]
            ;;
        concat_with_agents|copy)
            # Byte comparison for text files
            cmp -s "$file1" "$file2"
            ;;
        *)
            return 1
            ;;
    esac
}

# Generate merged config from AGENTS.md + tool template
generate_config() {
    local source_template="$1"
    local output_file="$2"

    local temp_file="${output_file}.tmp"

    # AGENTS.md content
    cat "$AGENTS_DIR/AGENTS.md" > "$temp_file"

    # Separator
    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"

    # Tool-specific content
    cat "$source_template" >> "$temp_file"

    echo "$temp_file"
}

# Perform merge based on strategy
perform_merge() {
    local source="$1"
    local target="$2"
    local output="$3"
    local strategy="$4"

    case "$strategy" in
        concat_with_agents)
            # Concatenate AGENTS.md + source
            cat "$AGENTS_DIR/AGENTS.md" > "$output"
            echo "" >> "$output"
            echo "---" >> "$output"
            echo "" >> "$output"
            cat "$source" >> "$output"
            ;;
        copy)
            # Simple copy
            cp "$source" "$output"
            ;;
        json)
            # JSON merge with strategy
            if jq -e '.merge_strategy' "$source" >/dev/null 2>&1; then
                # Structured merge
                local target_path=$(jq -r '.merge_strategy.target_path' "$source")
                local method=$(jq -r '.merge_strategy.method' "$source")
                local values=$(jq -c '.merge_strategy.values' "$source")

                case "$method" in
                    array_append_unique)
                        jq --argjson new_values "$values" \
                           --arg path "$target_path" \
                           'getpath($path | split(".")) as $current |
                            setpath($path | split("."); ($current + $new_values | unique))' \
                           "$target" > "$output"
                        ;;
                    *)
                        echo "ERROR: Unknown merge method: $method"
                        return 1
                        ;;
                esac
            else
                # No merge strategy - copy source
                cp "$source" "$output"
            fi
            ;;
        yaml)
            # YAML merge with strategy
            if yq eval -e '.merge_strategy' "$source" >/dev/null 2>&1; then
                # Structured merge
                local target_path=$(yq eval '.merge_strategy.target_path' "$source")
                local method=$(yq eval '.merge_strategy.method' "$source")

                case "$method" in
                    array_append_unique)
                        # yq syntax for array merge
                        yq eval-all "
                            .${target_path} = (.${target_path} + load(\"$source\").merge_strategy.values | unique)
                        " "$target" > "$output"
                        ;;
                    *)
                        echo "ERROR: Unknown merge method: $method"
                        return 1
                        ;;
                esac
            else
                # No merge strategy - copy source
                cp "$source" "$output"
            fi
            ;;
        *)
            echo "ERROR: Unknown merge strategy: $strategy"
            return 1
            ;;
    esac
}

# Validate merged output
validate_merge() {
    local file="$1"
    local format="$2"

    case "$format" in
        json)
            jq empty "$file" 2>/dev/null
            ;;
        yaml)
            yq eval '.' "$file" >/dev/null 2>&1
            ;;
        *)
            # Text files - just check readable
            [[ -r "$file" ]]
            ;;
    esac
}

# Get path to shadow copy for a tool (legacy - kept for compatibility)
get_baseline_path() {
    local tool_slug="$1"
    local config_file="$2"
    echo "$GENERATED_DIR/$tool_slug/${config_file##*/}"
}

# Install new config and update baseline
install_config() {
    local new_file="$1"
    local target_file="$2"
    local baseline_file="$3"

    # Ensure baseline directory exists
    mkdir -p "$(dirname "$baseline_file")"

    # Install to both locations
    cp "$new_file" "$target_file"
    cp "$new_file" "$baseline_file"
}

# Apply three-way merge with shadow copy
apply_three_way_merge() {
    local platform="$1"
    local filename="$2"
    local source_file="$3"
    local target_file="$4"
    local shadow_file="$5"
    local strategy="$6"

    # Check if target exists - if not, create initial version
    if [[ ! -f "$target_file" ]]; then
        echo "      → Initial install (target doesn't exist)"

        # Generate merged result
        local temp_merged=$(mktemp)

        # For concat_with_agents, we need a dummy target for merge
        if [[ "$strategy" == "concat_with_agents" ]]; then
            # Just concatenate AGENTS.md + source
            cat "$AGENTS_DIR/AGENTS.md" > "$temp_merged"
            echo "" >> "$temp_merged"
            echo "---" >> "$temp_merged"
            echo "" >> "$temp_merged"
            cat "$source_file" >> "$temp_merged"
        else
            # For other strategies, just copy source
            cp "$source_file" "$temp_merged"
        fi

        # Validate merged result
        if ! validate_merge "$temp_merged" "$strategy"; then
            echo "      ✗ Merge produced invalid $strategy file"
            rm -f "$temp_merged"
            return 1
        fi

        # Install merged result
        mkdir -p "$(dirname "$target_file")"
        mkdir -p "$(dirname "$shadow_file")"
        cp "$temp_merged" "$target_file"
        cp "$temp_merged" "$shadow_file"

        rm -f "$temp_merged"
        echo "      ${GREEN}✓ Created${NC}"
        return 0
    fi

    # Generate what the merged result should be
    local temp_merged=$(mktemp)
    if ! perform_merge "$source_file" "$target_file" "$temp_merged" "$strategy"; then
        rm -f "$temp_merged"
        return 1
    fi

    # Validate merged result
    if ! validate_merge "$temp_merged" "$strategy"; then
        echo "      ✗ Merge produced invalid $strategy file"
        rm -f "$temp_merged"
        return 1
    fi

    # First merge (no shadow)
    if [[ ! -f "$shadow_file" ]]; then
        echo "      → First merge (no shadow)"

        # Backup target
        cp "$target_file" "${target_file}.backup"

        # Install merged result
        mkdir -p "$(dirname "$shadow_file")"
        cp "$temp_merged" "$target_file"
        cp "$temp_merged" "$shadow_file"

        rm -f "$temp_merged"
        echo "      ${GREEN}✓ Merged${NC} (backup: ${target_file}.backup)"
        return 0
    fi

    # Three-way merge
    if files_equal "$target_file" "$shadow_file" "$strategy"; then
        # User unchanged
        if files_equal "$temp_merged" "$shadow_file" "$strategy"; then
            # Source unchanged too
            echo "      ${BLUE}→ No changes needed${NC}"
            rm -f "$temp_merged"
            return 0
        else
            # Source changed - auto-update
            echo "      ${GREEN}→ Auto-updating${NC} (source changed, user unchanged)"
            cp "$target_file" "${target_file}.backup"
            cp "$temp_merged" "$target_file"
            cp "$temp_merged" "$shadow_file"
            rm -f "$temp_merged"
            echo "      ${GREEN}✓ Updated${NC}"
            return 0
        fi
    else
        # User modified
        if files_equal "$temp_merged" "$shadow_file" "$strategy"; then
            # Source unchanged - preserve user changes
            echo "      ${YELLOW}→ Preserving user changes${NC} (source unchanged)"
            rm -f "$temp_merged"
            return 0
        else
            # Both changed - conflict
            echo "      ${YELLOW}⚠ CONFLICT${NC}: Both user and source changed"
            echo "        User:   $target_file"
            echo "        Source: $source_file"
            echo "        Shadow: $shadow_file"
            echo "        Please merge manually"
            rm -f "$temp_merged"
            return 1
        fi
    fi
}

# Handle conflict when both user and AGENTS.md changed
handle_conflict() {
    local baseline="$1"
    local current="$2"
    local new="$3"
    local tool_name="$4"

    echo ""
    echo -e "${YELLOW}⚠ Conflict detected for $tool_name:${NC}"
    echo "  - Your config has been modified"
    echo "  - AGENTS.md has also changed"
    echo ""
    echo "Options:"
    echo "  [v] View diff between versions"
    echo "  [a] Accept new (lose your changes)"
    echo "  [k] Keep current (skip AGENTS.md updates)"
    echo "  [m] Merge interactively"
    echo "  [s] Skip (decide later)"
    echo ""
    read -p "Choose: " -n 1 -r </dev/tty 2>/dev/null || { echo "k"; REPLY="k"; }
    echo

    case "$REPLY" in
        v)
            echo ""
            echo -e "${BLUE}--- Your changes (vs baseline) ---${NC}"
            diff -u "$baseline" "$current" || true
            echo ""
            echo -e "${BLUE}--- AGENTS.md changes (vs baseline) ---${NC}"
            diff -u "$baseline" "$new" || true
            echo ""
            handle_conflict "$baseline" "$current" "$new" "$tool_name"  # Re-prompt
            ;;
        a)
            install_config "$new" "$current" "$baseline"
            echo -e "${GREEN}✓${NC} Installed new version"
            return 0
            ;;
        k)
            echo -e "${YELLOW}⊘${NC} Keeping current version (will ask again next run)"
            return 1
            ;;
        m)
            # Use git mergetool for proper 3-way merge
            if command -v git >/dev/null 2>&1; then
                # Create temporary git repo for merge
                local merge_dir=$(mktemp -d)
                cp "$baseline" "$merge_dir/file"
                (
                    cd "$merge_dir"
                    git init -q
                    git config user.email "setup@config"
                    git config user.name "Setup Script"
                    git config commit.gpgsign false
                    git add file
                    git commit -q -m "baseline"

                    # Create "ours" branch with user's version
                    cp "$current" file
                    git commit -q -am "current"

                    # Create "theirs" branch with new version
                    git checkout -q -b theirs HEAD~1
                    cp "$new" file
                    git commit -q -am "new"

                    # Merge and resolve with mergetool
                    git checkout -q main 2>/dev/null || git checkout -q master
                    git merge theirs -q --no-commit || true

                    if git diff --quiet; then
                        echo -e "${GREEN}✓${NC} No conflicts - changes merged automatically"
                    else
                        git mergetool
                    fi

                    # Copy result back
                    cp file "$current"
                )
                rm -rf "$merge_dir"
                cp "$current" "$baseline"  # Update baseline to merged result
                echo -e "${GREEN}✓${NC} Merged and updated baseline"
                return 0
            else
                echo -e "${RED}git not found (required for merge)${NC}"
                handle_conflict "$baseline" "$current" "$new" "$tool_name"
                return $?
            fi
            ;;
        s)
            echo -e "${YELLOW}⊘${NC} Skipped"
            return 1
            ;;
        *)
            echo "Invalid choice"
            handle_conflict "$baseline" "$current" "$new" "$tool_name"
            return $?
            ;;
    esac
}

# Main universal configuration merge
merge_all_configs() {
    echo ""
    echo -e "${BLUE}=== Universal Configuration Merge ===${NC}"
    echo ""

    local platform_dir="$AGENTS_DIR/platform-specific-configurations"
    local total_processed=0
    local total_updated=0
    local total_preserved=0
    local total_skipped=0
    local total_conflicts=0

    # Find all platform directories
    for platform_path in "$platform_dir"/*; do
        [[ ! -d "$platform_path" ]] && continue

        local platform=$(basename "$platform_path")
        local tool_dir="$HOME/.$platform"

        # Check if tool is installed
        if [[ ! -d "$tool_dir" ]]; then
            echo -e "${YELLOW}[-]${NC} $platform: not installed, skipping"
            ((total_skipped++)) || true
            continue
        fi

        echo -e "${GREEN}[+]${NC} $platform: processing..."

        # Find all files in platform config dir
        local processed=0
        local updated=0
        local preserved=0
        local skipped=0
        local conflicts=0

        for source_file in "$platform_path"/*; do
            [[ ! -f "$source_file" ]] && continue

            local filename=$(basename "$source_file")

            # Skip metadata files
            case "$filename" in
                README.*|.*)
                    continue
                    ;;
            esac

            # Determine merge strategy
            local strategy_result=$(get_merge_strategy "$filename")

            # Handle special case: settings-additions.json
            local target_filename="$filename"
            local strategy="$strategy_result"
            if [[ "$strategy_result" == json:* ]]; then
                target_filename="${strategy_result#json:}"
                strategy="json"
            fi

            case "$strategy" in
                skip:*)
                    local reason="${strategy#skip:}"
                    echo "    [$filename] Skipping: $reason"
                    ((skipped++)) || true
                    continue
                    ;;
            esac

            # Get paths
            local target_file=$(get_target_path "$platform" "$target_filename")
            local shadow_file=$(get_shadow_path "$platform" "$target_filename")

            echo "    [$filename] → $target_filename (strategy: $strategy)"

            # Apply three-way merge
            ((processed++)) || true
            if apply_three_way_merge "$platform" "$target_filename" "$source_file" "$target_file" "$shadow_file" "$strategy"; then
                # Check if actually updated (new backup exists)
                if [[ -f "${target_file}.backup" ]] && [[ "${target_file}.backup" -nt "$shadow_file" ]]; then
                    ((updated++)) || true
                fi
            else
                # Check if preserved or conflict
                if files_equal "$target_file" "$shadow_file" "$strategy" 2>/dev/null; then
                    ((preserved++)) || true
                else
                    ((conflicts++)) || true
                fi
            fi
        done

        # Platform summary
        echo "    Summary: processed=$processed, updated=$updated, preserved=$preserved, skipped=$skipped, conflicts=$conflicts"
        echo ""

        total_processed=$((total_processed + processed))
        total_updated=$((total_updated + updated))
        total_preserved=$((total_preserved + preserved))
        total_skipped=$((total_skipped + skipped))
        total_conflicts=$((total_conflicts + conflicts))
    done

    # Global summary
    echo -e "${BLUE}---${NC}"
    echo ""
    echo -e "${GREEN}Setup complete.${NC}"
    echo "  Processed: $total_processed"
    echo "  Updated: $total_updated"
    echo "  Preserved (user-modified): $total_preserved"
    echo "  Skipped: $total_skipped"
    echo "  Conflicts: $total_conflicts"
}

# Run the merge
merge_all_configs

# Additional info
echo ""
echo -e "${BLUE}Global configuration:${NC}"
echo "  $AGENTS_DIR/AGENTS.md"
echo ""
echo -e "${BLUE}Shadow copies (change detection):${NC}"
echo "  $GENERATED_DIR/"
echo ""
echo -e "${BLUE}For new projects:${NC}"
echo "  mkdir .agents"
echo ""
echo -e "${BLUE}Learn more:${NC}"
echo "  cat $AGENTS_DIR/README.md"
