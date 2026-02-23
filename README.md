# P4 — CDN & Docker Lab Report

**Course:** Video Processing

**Authors:** Soulayman, Daniela, Daniel

**Date:** February 2026

## Objective

Run virtual containers (Docker) to understand video processing, packaging (HLS/DASH), DRM encryption, VOD platform analysis, and CDN architecture.

## Table of Contents

| Task | Topic | Document |
|------|-------|----------|
| 1 | FFmpeg Docker container | [task1/README.md](task1/README.md) |
| 2 | Video Packaging (HLS & DASH) | [task2/README.md](task2/README.md) |
| 3 | DRM with Bento4 | [task3/README.md](task3/README.md) |
| 4 | VOD Platform Investigation | [task4/README.md](task4/README.md) |
| 5 | CDN Implementation | [task5/README.md](task5/README.md) |

## Tech Stack

- **Docker / Docker Compose** — container orchestration
- **FFmpeg** — video transcoding, cutting, and packaging
- **Bento4** (`mp4fragment`, `mp4encrypt`, `mp4dash`, `mp4hls`) — MP4 tools and DRM packaging
- **HLS** — HTTP Live Streaming (H.264 + AAC, `.m3u8` playlists, `.ts` segments)
- **MPEG-DASH** — Dynamic Adaptive Streaming (VP9 + AAC, `.mpd` manifests)

## Project Structure

```
README.md                       ← This file (main entry point)
├── task1/
│   ├── Dockerfile              ← FFmpeg Docker image definition
│   └── README.md               ← Task 1 report
├── task2/
│   ├── original_video.mp4      ← Source video
│   ├── video_1min.mp4          ← 1-minute cut used for packaging
│   ├── run_task2.sh            ← Packaging script (HLS + DASH)
│   ├── task2_output.log        ← FFmpeg run logs
│   ├── part_a/                 ← HLS output (.m3u8 playlist + .m4s segments)
│   ├── part_b/                 ← DASH output (.mpd manifest + .mkv segments)
│   └── README.md               ← Task 2 report
├── task3/
│   ├── Dockerfile              ← Bento4 Docker image definition
│   ├── video_1min.mp4          ← Source video for DRM packaging
│   ├── run_task3.sh            ← DRM pipeline script
│   ├── task3_output.log        ← Bento4 run logs
│   ├── output_task3/
│   │   ├── ladder/             ← Encoded renditions (480p, 720p, 1080p)
│   │   ├── fragmented/         ← Fragmented MP4s (required before CENC encryption)
│   │   └── packaged/           ← Final HLS + DASH output with CENC encryption
│   └── README.md               ← Task 3 report
├── task4/
│   └── README.md               ← Task 4 report (browser dev tools)
└── task5/
    └── README.md               ← Task 5 report
```

## Prerequisites

- Docker Desktop (or Docker Engine + CLI)
- Git
- A web browser with developer tools

See each task document for detailed step-by-step instructions.
