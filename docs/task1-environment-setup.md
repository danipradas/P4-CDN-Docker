# Task 1: Environment Setup

[← Back to README](../README.md) | [Next: Task 2 →](task2-video-packaging.md)

## Objective

Download and install Docker, create a container with FFmpeg, and verify it can run FFmpeg commands.

## 1.1 Docker Installation

<!-- TODO: Add your Docker version and installation method -->

Verify Docker is installed:

```bash
docker --version
```

<!-- TODO: Screenshot of docker --version output -->
<!-- ![Docker version](../screenshots/task1/docker-version.png) -->

## 1.2 FFmpeg Dockerfile

<!-- TODO: Add your actual Dockerfile content below -->

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["ffmpeg"]
```

**Choices explained:**
- `ubuntu:22.04` as base image for broad package availability
- FFmpeg installed via `apt-get` for simplicity
- `ENTRYPOINT ["ffmpeg"]` so the container behaves like the `ffmpeg` command itself

## 1.3 Build the Container

```bash
docker build -t ffmpeg-lab -f dockerfiles/Dockerfile.ffmpeg .
```

<!-- TODO: Screenshot of successful build -->
<!-- ![Docker build](../screenshots/task1/docker-build.png) -->

## 1.4 Run FFmpeg Inside the Container

Verify FFmpeg works:

```bash
docker run --rm ffmpeg-lab -version
```

<!-- TODO: Screenshot of FFmpeg version output inside the container -->
<!-- ![FFmpeg version](../screenshots/task1/ffmpeg-version.png) -->

Run a sample command (e.g., get info about a video file):

```bash
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab -i /media/input.mp4
```

<!-- TODO: Screenshot of FFmpeg processing a file -->
<!-- ![FFmpeg run](../screenshots/task1/ffmpeg-run.png) -->
