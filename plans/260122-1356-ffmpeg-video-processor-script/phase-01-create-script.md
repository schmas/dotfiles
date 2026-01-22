# Phase 01: Create Video Processor Script

## Context

- Parent: [plan.md](./plan.md)
- Docs: [Code Standards](../../docs/code-standards.md)

## Overview

- **Date**: 2026-01-22
- **Priority**: P3
- **Implementation Status**: pending
- **Review Status**: pending

Create a bash script that wraps FFmpeg for common video processing operations: resize, speed change, and compression.

## Key Insights

- FFmpeg `scale` filter handles resizing: `scale=iw*0.5:ih*0.5`
- Video speed: `setpts=0.5*PTS` (0.5 = 2x speed)
- Audio speed: `atempo=2.0` (supports 0.5-2.0, chain for >2x)
- CRF controls quality/size: lower=better quality, higher=smaller file
- Existing bin scripts use `#!/usr/bin/env bash` with `set -euo pipefail`

## Requirements

### Functional
- Accept input video file as positional argument
- Resize by scale factor (default: 0.5)
- Speed up video/audio (default: 2x)
- Compress with configurable quality (default: CRF 28)
- Generate output filename: `{name}_processed.mp4`
- Allow custom output filename

### Non-functional
- Fast single-pass encoding
- Preserve aspect ratio during resize
- Handle audio correctly at different speeds

## Architecture

```
vidproc INPUT [OPTIONS]
  │
  └─► Parse args → Validate → Build FFmpeg command → Execute
```

**FFmpeg Command Structure:**
```bash
ffmpeg -i input.mp4 \
  -vf "scale=iw*SCALE:ih*SCALE,setpts=PTS/SPEED" \
  -af "atempo=SPEED" \
  -c:v libx264 -crf CRF -preset fast \
  -c:a aac \
  output.mp4
```

## Related Code Files

### Create
- `home/bin/executable_vidproc` - Main script

### Reference
- `home/bin/executable_gpg-backup` - Example bash script with error handling

## Implementation Steps

1. Create script file with shebang and strict mode
2. Define default values (scale=0.5, speed=2, crf=28)
3. Implement help function
4. Parse CLI arguments using getopts/manual parsing
5. Validate input file exists
6. Check FFmpeg is installed
7. Generate output filename if not provided
8. Build FFmpeg command with filters
9. Execute FFmpeg command
10. Report success/failure

## Todo List

- [ ] Create `home/bin/executable_vidproc` script
- [ ] Add argument parsing for all flags
- [ ] Add input validation
- [ ] Add help text
- [ ] Test with sample video

## Success Criteria

- Script runs without errors on valid input
- `vidproc video.mp4` uses all defaults
- `vidproc video.mp4 -s 0.25` resizes to 25%
- `vidproc video.mp4 -x 4` speeds up 4x
- `vidproc video.mp4 -q 18` uses high quality
- `vidproc video.mp4 -o custom.mp4` uses custom output name
- `vidproc -h` shows usage help
- Error message when input file missing
- Error message when FFmpeg not installed

## Risk Assessment

- **Audio speed >2x**: atempo only supports 0.5-2.0, need chaining for higher speeds
- **Mitigation**: Chain multiple atempo filters (e.g., 4x = atempo=2.0,atempo=2.0)

## Security Considerations

- Validate input file path (no command injection)
- Use quotes around all variables

## Next Steps

After implementation:
1. Run `code-simplifier` agent
2. Test with actual video file
3. Apply chezmoi to install
