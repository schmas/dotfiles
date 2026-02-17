# Phase 02: Create Per-Shell Loaders and Parsers

## Context Links
- Parent: [plan.md](./plan.md)
- Env loader references: `05-shared-env.{fish,zsh,bash}`
- Fish parser reference: `home/dot_config/private_fish/functions/source_posix_env.fish`

## Overview
- **Priority:** High (core implementation)
- **Status:** Complete
- **Description:** Create 3 loader scripts (one per shell) and 3 parser functions that read `.path` files and add entries to PATH with flag support.

## Key Insights
- Fish: uses `fish_add_path` (built-in dedup). Parser as standalone function file in `functions/`.
- Zsh: uses `path=()` array + `typeset -U path` (dedup already set in `10-common.env.zsh.tmpl`). Function defined inline in loader — avoids fpath timing issues.
- Bash: uses `PATH=` string concat. No built-in dedup — add manual dedup after loading. Function defined inline in loader.
- All parsers share identical logic: read line, skip comments, parse flags, expand `$HOME`, add path.

## Requirements
- Parse `.path` format: path + optional `--check`, `--glob`, `--append` flags
- Expand `$HOME` in paths
- Handle quoted paths (strip quotes before processing)
- `--glob`: add dir itself + all immediate subdirectories
- `--check`: skip if dir doesn't exist
- `--append`: add to end of PATH (default: prepend)
- Startup perf: no external tools (no awk/sed/python)

## Related Code Files

### Files to Create
| File | Description |
|------|-------------|
| `home/dot_config/private_fish/functions/source_path_file.fish` | Fish parser function |
| `home/dot_config/private_fish/conf.d/05-shared-path.fish` | Fish loader |
| `home/dot_config/private_zsh/conf.d/05-shared-path.zsh` | Zsh loader (parser inline) |
| `home/dot_config/private_bash/conf.d/05-shared-path.bash` | Bash loader (parser inline) |

### Reference Files
| File | Purpose |
|------|---------|
| `home/dot_config/private_fish/functions/source_posix_env.fish` | Fish function pattern |
| `home/dot_config/private_fish/conf.d/05-shared-env.fish` | Fish loader pattern |
| `home/dot_config/private_zsh/conf.d/05-shared-env.zsh` | Zsh loader pattern |
| `home/dot_config/private_bash/conf.d/05-shared-env.bash` | Bash loader pattern |

## Architecture

```
~/.config/path/*.path  ──►  05-shared-path.{fish,zsh,bash}  ──►  source_path_file()
                                  (loader loops files)            (parser adds to PATH)
```

## Implementation Steps

### 1. Fish Parser: `source_path_file.fish`

Location: `home/dot_config/private_fish/functions/source_path_file.fish`

```fish
function source_path_file --description "Load a .path file into fish PATH"
    test -f $argv[1]; or return 1
    while read -l line
        # Skip comments and empty lines
        string match -qr '^\s*(#|$)' -- $line; and continue

        # Parse flags
        set -l check 0
        set -l do_glob 0
        set -l do_append 0
        set -l dir ""

        for token in (string split ' ' -- $line)
            switch $token
                case '--check'
                    set check 1
                case '--glob'
                    set do_glob 1
                case '--append'
                    set do_append 1
                case '*'
                    # Path token — strip quotes, expand $HOME
                    set dir (string replace -r '^["\'](.*)["\']$' '$1' -- $token)
                    set dir (string replace -a '$HOME' "$HOME" -- $dir)
            end
        end

        test -n "$dir"; or continue

        # --check: skip if dir doesn't exist
        if test $check -eq 1 -a ! -d "$dir"
            continue
        end

        # Build list of dirs to add
        set -l dirs $dir
        if test $do_glob -eq 1
            for subdir in $dir/*/
                set -a dirs $subdir
            end
        end

        # Add to PATH
        if test $do_append -eq 1
            fish_add_path --global --append $dirs
        else
            fish_add_path --global $dirs
        end
    end < $argv[1]
end
```

### 2. Fish Loader: `05-shared-path.fish`

Location: `home/dot_config/private_fish/conf.d/05-shared-path.fish`

```fish
# Load all .path files from ~/.config/path/
for f in $HOME/.config/path/*.path
    source_path_file $f
end
```

### 3. Zsh Loader + Parser: `05-shared-path.zsh`

Location: `home/dot_config/private_zsh/conf.d/05-shared-path.zsh`

```zsh
#!/usr/bin/env zsh
# Load all .path files from ~/.config/path/

_source_path_file() {
    local file="$1"
    [ -f "$file" ] || return 1
    local line dir token check do_glob do_append
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue

        check=0; do_glob=0; do_append=0; dir=""
        for token in ${=line}; do
            case "$token" in
                --check)  check=1 ;;
                --glob)   do_glob=1 ;;
                --append) do_append=1 ;;
                *)
                    dir="${token//\"/}"    # Strip double quotes
                    dir="${dir//\'/}"      # Strip single quotes
                    dir="${dir//\$HOME/$HOME}"  # Expand $HOME
                    ;;
            esac
        done

        [ -z "$dir" ] && continue
        [ "$check" -eq 1 ] && [ ! -d "$dir" ] && continue

        if [ "$do_glob" -eq 1 ]; then
            if [ "$do_append" -eq 1 ]; then
                path+=("$dir")
                for d in "$dir"/*(/-N); do path+=("$d"); done
            else
                for d in "$dir"/*(/-N); do path=("$d" $path); done
                path=("$dir" $path)
            fi
        else
            if [ "$do_append" -eq 1 ]; then
                path+=("$dir")
            else
                path=("$dir" $path)
            fi
        fi
    done < "$file"
}

for f in "$HOME"/.config/path/*.path(N); do
    _source_path_file "$f"
done
unfunction _source_path_file
```

Notes:
- `${=line}` splits on whitespace (zsh word splitting)
- `*(/-N)` globs directories only, null glob if empty
- `unfunction` cleans up after use — function not needed after startup
- `typeset -U path` already set in `10-common.env.zsh.tmpl` handles dedup

### 4. Bash Loader + Parser: `05-shared-path.bash`

Location: `home/dot_config/private_bash/conf.d/05-shared-path.bash`

```bash
#!/usr/bin/env bash
# Load all .path files from ~/.config/path/

_source_path_file() {
    local file="$1"
    [ -f "$file" ] || return 1
    local line dir token check do_glob do_append
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue

        check=0; do_glob=0; do_append=0; dir=""
        for token in $line; do
            case "$token" in
                --check)  check=1 ;;
                --glob)   do_glob=1 ;;
                --append) do_append=1 ;;
                *)
                    dir="${token//\"/}"
                    dir="${dir//\'/}"
                    dir="${dir//\$HOME/$HOME}"
                    ;;
            esac
        done

        [ -z "$dir" ] && continue
        [ "$check" -eq 1 ] && [ ! -d "$dir" ] && continue

        if [ "$do_glob" -eq 1 ]; then
            if [ "$do_append" -eq 1 ]; then
                PATH="$PATH:$dir"
                for d in "$dir"/*/; do [ -d "$d" ] && PATH="$PATH:$d"; done
            else
                for d in "$dir"/*/; do [ -d "$d" ] && PATH="$d:$PATH"; done
                PATH="$dir:$PATH"
            fi
        else
            if [ "$do_append" -eq 1 ]; then
                PATH="$PATH:$dir"
            else
                PATH="$dir:$PATH"
            fi
        fi
    done < "$file"
}

for f in "$HOME"/.config/path/*.path; do
    [ -f "$f" ] && _source_path_file "$f"
done
unset -f _source_path_file

# Deduplicate PATH (preserve order, keep first occurrence)
PATH=$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')
export PATH
```

Notes:
- Bash has no built-in path dedup — awk one-liner after loading
- `unset -f` cleans up function
- `$line` without quotes intentionally splits on whitespace for token parsing
- Trailing slash glob `*/` with `-d` test for subdirs

## Todo List
- [ ] Create `source_path_file.fish` function
- [ ] Create `05-shared-path.fish` loader
- [ ] Create `05-shared-path.zsh` loader with inline parser
- [ ] Create `05-shared-path.bash` loader with inline parser + dedup
- [ ] Verify Fish function autoloads correctly
- [ ] Verify Zsh/Bash parsers handle all flag combinations

## Success Criteria
- Each shell loads paths from `~/.config/path/*.path`
- `--check` skips non-existent dirs
- `--glob` expands immediate subdirectories
- `--append` adds to end of PATH
- Default (no flags) prepends without existence check
- Quoted paths with spaces handled correctly
- No startup perf regression (no external tool calls in parsers, except Bash dedup)

## Risk Assessment
- **Fish `fish_add_path` with `--append`:** Verify flag exists in Fish 3.x+. Fallback: manual `set -ga fish_user_paths`.
- **Zsh word splitting:** `${=line}` is zsh-specific — correct for this context.
- **Bash glob trailing slash:** `"$dir"/*/` may not match if dir has no subdirs — guarded with `[ -d "$d" ]`.
- **Bash dedup awk:** Single external call after all files loaded — acceptable perf tradeoff.

## Security Considerations
- No eval or exec — only string manipulation and PATH assignment
- No user input — files generated by chezmoi from templates

## Next Steps
- Phase 03: Remove old files after loaders verified working
