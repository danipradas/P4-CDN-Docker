# Task 1 — Docker + FFmpeg Container

**P4: CDN & Docker for Encoding** | Universitat Pompeu Fabra · Equips i Sistemes de Vídeo

---

## Objective

> *"Download Docker for command line or for Desktop and install it. Create a container which contains the software FFmpeg and you are going to be able to run that container passing FFmpeg commands."*

> **Why isolate FFmpeg in Docker?** The host machine does not need FFmpeg installed at all. The container provides a reproducible, self-contained environment that works identically on any machine with Docker.


---

## 1.1 Docker Installation

Docker Desktop was installed on Windows. Verify the installation:

```bash
docker --version
# Docker version 27.x.x, build ...

docker info
```

Docker Desktop provides the Docker Engine, CLI, and Docker Compose in a single installation. We use that since we use Windows, for that we had to install WSL2 (Link: https://docs.docker.com/desktop/install/windows-install/) and enable the WSL2 backend in Docker Desktop settings.

For Linux and MacOS, Docker Engine and CLI can be installed directly without the need for WSL2.
---

## 1.2 Dockerfile

The Dockerfile is minimal by design — it installs FFmpeg from the Ubuntu package repository and sets it as the container entrypoint so the container behaves exactly like the `ffmpeg` command itself.

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["ffmpeg"]
```

**Design choices:**

| Choice | Reason |
|--------|--------|
| `ubuntu:24.04` | LTS base with good package availability and long-term support |
| `apt-get install ffmpeg` | Simplest and most reliable install path for a lab context |
| `apt-get clean && rm -rf /var/lib/apt/lists/*` | Removes the apt package index after install to reduce image size |
| `ENTRYPOINT ["ffmpeg"]` | Makes the container behave transparently as the `ffmpeg` binary — arguments passed to `docker run` are forwarded directly to FFmpeg |

---

## 1.3 Build the Image

Run from the `task1/` directory:

```bash
docker build -t ffmpeg-lab .
```

Expected output ends with:
```
Successfully built <image-id>
Successfully tagged ffmpeg-lab:latest
```

Verify the image exists:
```bash
docker images | grep ffmpeg-lab
```

---

## 1.4 Running FFmpeg Inside the Container

### Check the FFmpeg version

```bash
docker run --rm ffmpeg-lab -version
```

### Get info about a video file

```bash
docker run --rm -v "$(pwd):/media" ffmpeg-lab -i /media/input.mp4
```

The `-v "$(pwd):/media"` flag mounts the current host directory into the container at `/media`. This is how files are shared between the host and the container — the container has no access to the host filesystem otherwise.


---

