---
title: "FFmpeg Video Processor Script"
description: "Standalone bash script to resize, speed up, and compress videos"
status: completed
priority: P3
effort: 30m
branch: main
tags: [ffmpeg, video, utility, bash, automation]
created: 2026-01-22
---

# FFmpeg Video Processor Script

## Overview

Create a standalone bash script for quick video processing using FFmpeg. The script will resize videos by 50%, increase playback speed by 2x, and compress output - all with sensible defaults and optional CLI flags for customization.

## Phases

| Phase | Description | Status | File |
|-------|-------------|--------|------|
| 01 | Create video processor script | ✅ done | [phase-01-create-script.md](./phase-01-create-script.md) |

## Key Features

- **Resize**: Scale video by configurable factor (default: 0.5)
- **Speed**: Increase playback speed (default: 2x)
- **Compress**: H.264 encoding with CRF (default: 28)
- **CLI flags**: Override defaults via `--scale`, `--speed`, `--crf`, `--output`
- **Help**: Built-in usage documentation

## Target Location

`home/bin/executable_vidproc` → Installs to `~/bin/vidproc`

## Dependencies

- FFmpeg (must be installed on system)

## Success Criteria

- [x] Script processes videos with default settings
- [x] CLI flags override defaults correctly
- [x] Help message displays usage
- [x] Error handling for missing input/ffmpeg
- [x] Output file naming works correctly
