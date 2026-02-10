# Phase 2: Create Fish source_posix_env Function

## Context

- Parent plan: [plan.md](plan.md)
- Depends on: None (can run parallel with Phase 1)

## Overview

- **Priority:** High (Phase 3 fish loader depends on this)
- **Status:** complete
- **Description:** Create fish-idiomatic autoloaded function to parse POSIX KEY=VALUE .env files

## Key Insights

- Fish can't `source` POSIX files natively — needs a parser
- Fish autoloads functions from `~/.config/fish/functions/` on first use
- Existing functions dir has 12 files — established pattern
- Parser handles: `KEY=VALUE`, `KEY="value"`, `KEY='value'`, comments, blank lines
- Performance: sub-millisecond for 5-10 line files (builtins only, no subshells)

## Requirements

- Parse POSIX `.env` format: `KEY=VALUE` lines
- Handle unquoted, double-quoted, and single-quoted values
- Skip comment lines (`#`) and blank lines
- Export vars globally (`set -gx`)
- Return error code 1 if file doesn't exist

## Related Code Files

- `home/dot_config/private_fish/functions/` — existing function files (12 files)
- `home/dot_config/private_fish/conf.d/05-shared-env.fish` — will call this function (Phase 3)

## Implementation Steps

### 1. Create `home/dot_config/private_fish/functions/source_posix_env.fish`

```fish
function source_posix_env --description "Source a POSIX KEY=VALUE .env file into fish environment"
    test -f $argv[1]; or return 1
    while read -l line
        string match -qr '^\s*(#|$)' -- $line; and continue
        set -l kv (string match -r '^([A-Za-z_]\w*)=(.*)$' -- $line)
        test (count $kv) -ge 3; or continue
        set -l val (string replace -r '^["\'](.*)["\']$' '$1' -- $kv[3])
        set -gx $kv[2] $val
    end < $argv[1]
end
```

**Line-by-line:**
1. Check file exists, return 1 if not
2. Read file line by line
3. Skip comments and empty lines via regex
4. Match `KEY=VALUE` pattern, capture key and value
5. Need at least 3 captures (full match + key + value)
6. Strip surrounding quotes if present
7. Export as global fish variable

## Todo

- [x] Create `source_posix_env.fish` in fish functions dir
- [x] Test with sample .env file: bare values, quoted values, comments, blanks

## Success Criteria

- `source_posix_env /tmp/test.env` correctly sets all vars
- Handles: `KEY=value`, `KEY="value"`, `KEY='value'`, `# comment`, blank lines
- Returns 1 for nonexistent file
- Available via fish autoload (no explicit source needed)

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Values with `=` in them (e.g. base64) | Regex captures only first `=` split — rest goes to value | The regex `^([A-Za-z_]\w*)=(.*)$` captures everything after first `=` as value — correct |
| Multiline values | Won't parse correctly | Not supported — keep .env files single-line. Document in template comment |
| Values with unmatched quotes | Quote stripping regex won't match, value kept as-is | Acceptable — falls through gracefully |

## Next Steps

- Phase 3: Create shell loaders that call this function
