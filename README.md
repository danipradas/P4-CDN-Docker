# P4 — CDN & Docker Lab Report

**Course:** Video Processing
**Authors:** Soulayman, Daniela, Daniel
**Date:** February 2026

## Objective

Run virtual containers (Docker) to understand video processing, packaging (HLS/DASH), DRM encryption, VOD platform analysis, and CDN architecture.

## Table of Contents

| Task | Topic | Document |
|------|-------|----------|
| 1 | Environment Setup | [docs/task1-environment-setup.md](docs/task1-environment-setup.md) |
| 2 | Video Packaging (HLS & DASH) | [docs/task2-video-packaging.md](docs/task2-video-packaging.md) |
| 3 | DRM with Bento4 | [docs/task3-drm-bento4.md](docs/task3-drm-bento4.md) |
| 4 | VOD Platform Investigation | [docs/task4-vod-investigation.md](docs/task4-vod-investigation.md) |
| 5 | CDN Implementation | [docs/task5-cdn-implementation.md](docs/task5-cdn-implementation.md) |

## Tech Stack

- **Docker / Docker Compose** — container orchestration
- **FFmpeg** — video transcoding, cutting, and packaging
- **Bento4** (`mp4fragment`, `mp4encrypt`, `mp4dash`, `mp4hls`) — MP4 tools and DRM packaging
- **HLS** — HTTP Live Streaming (H.264 + AAC, `.m3u8` playlists, `.ts` segments)
- **MPEG-DASH** — Dynamic Adaptive Streaming (VP9 + AAC, `.mpd` manifests)

## Project Structure

```
README.md                          ← This file (main entry point)
docs/
├── task1-environment-setup.md     ← Docker + FFmpeg container setup
├── task2-video-packaging.md       ← HLS & DASH packaging
├── task3-drm-bento4.md            ← Bento4 DRM encryption pipeline
├── task4-vod-investigation.md     ← VOD platform analysis
├── task5-cdn-implementation.md    ← CDN tutorial walkthrough
screenshots/
├── task1/                         ← Screenshots for Task 1
├── task2/                         ← Screenshots for Task 2
├── task3/                         ← Screenshots for Task 3
├── task4/                         ← Screenshots for Task 4
├── task5/                         ← Screenshots for Task 5
dockerfiles/                       ← Dockerfiles for FFmpeg, Bento4, etc.
media/                             ← Source videos and outputs (not in git)
scripts/                           ← Automation scripts
```

## How to Reproduce

### Prerequisites

- Docker Desktop (or Docker Engine + CLI)
- Git
- A web browser with developer tools

### Quick Start

```bash
# 1. Build the FFmpeg container
docker build -t ffmpeg-lab -f dockerfiles/Dockerfile.ffmpeg .

# 2. Run FFmpeg inside the container
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab -version

# 3. Build the Bento4 container
docker build -t bento4-lab -f dockerfiles/Dockerfile.bento4 .

# 4. For the CDN task, clone the tutorial repo separately
git clone https://github.com/leandromoreira/cdn-up-and-running.git
```

See each task document for detailed step-by-step instructions.
