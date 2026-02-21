# Task 3 — DRM with Bento4 + Encoding Ladder

**P4: CDN & Docker for Encoding** | Universitat Pompeu Fabra · Equips i Sistemes de Vídeo

---

## Objective

> *"Now that you know how to 'Docker', search for the Bento4 software. Put it inside a Docker, and try to apply a DRM for the previous packaged file.*
> - *If you're able to create an encoding ladder, that would be great!*
> - *Maybe you need to go to the mp4 file and package again before applying DRM (mp4encrypt)"*

---

## What is Bento4?

Bento4 is an open-source C++ SDK and toolset for MP4 and streaming video. It includes command-line tools for fragmentation, encryption, and packaging of adaptive streaming content:

| Tool | Purpose |
|------|---------|
| `mp4fragment` | Fragment a plain MP4 into a fragmented MP4 (required before encryption) |
| `mp4encrypt` | Apply MPEG-CENC encryption to a fragmented MP4 |
| `mp4info` | Inspect MP4 file tracks, codecs, and encryption status |
| `mp4dash` | Package fragmented MP4(s) into a DASH manifest, optionally with HLS and DRM |

---

## 3.1 Bento4 Dockerfile

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y wget unzip python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/bento4.zip https://www.bok.net/Bento4/binaries/Bento4-SDK-1-6-0-641.x86_64-unknown-linux.zip && \
    unzip /tmp/bento4.zip -d /opt/ && \
    ln -s /opt/Bento4-SDK-1-6-0-641.x86_64-unknown-linux /opt/bento4 && \
    rm /tmp/bento4.zip

ENV PATH="/opt/bento4/bin:/opt/bento4/utils:${PATH}"

WORKDIR /media
```

**Why these packages?**

| Package | When needed | Why |
|---------|------------|-----|
| `wget` | Build time | Downloads the Bento4 SDK `.zip` from `bok.net` |
| `unzip` | Build time | Extracts the downloaded archive |
| `python3` | Runtime | `mp4dash` and `mp4hls` are Python scripts — they cannot run without it |

> These packages cannot be reused from the `ffmpeg-lab` image. Docker images are fully isolated — each container has its own independent filesystem. The `ffmpeg-lab` image is invisible to `bento4-lab` at runtime.


### Build

```bash
docker build -t bento4-lab .
```

---

## 3.2 Pipeline Overview

The full pipeline combines FFmpeg (encoding) and Bento4 (DRM packaging):

```
video_1min.mp4
      │
      ├─ [FFmpeg] Encode 1080p (H.264, 4 Mbps)  ──► ladder/video_1080.mp4
      ├─ [FFmpeg] Encode 720p  (H.264, 2 Mbps)  ──► ladder/video_720.mp4
      └─ [FFmpeg] Encode 480p  (H.264, 1 Mbps)  ──► ladder/video_480.mp4
                                    │
                          [mp4fragment] × 3
                                    │
                          fragmented/video_*.mp4
                                    │
                    [mp4dash --encryption-key --hls]
                                    │
                    output_task3/packaged/
                       ├── stream.mpd        (DASH manifest)
                       └── master.m3u8       (HLS playlist)
```

---

## Running the Script

Everything below is fully automated in [`run_task3.sh`](run_task3.sh). Instead of running each Docker command manually, just execute:

```bash
chmod +x run_task3.sh
bash run_task3.sh
```

The script handles the entire workflow end-to-end: directory setup, encoding ladder, fragmentation, packaging, and logging. The sections below explain what each part of the script does and why.

---

## 3.3 Part 1 — Encoding Ladder (FFmpeg)

The source video is transcoded into three H.264/AAC renditions at different bitrates. This encoding ladder is the foundation for adaptive bitrate (ABR) streaming — the player selects the rendition that fits the current network conditions.

```bash
# 1080p — 4 Mbps (high quality, original resolution)
docker run --rm -v "$WORK_DIR/output_task3":/media ffmpeg-lab \
    -y -i /media/video_1min.mp4 \
    -c:v libx264 -b:v 4000k -preset fast \
    -c:a aac -b:a 128k \
    /media/ladder/video_1080.mp4

# 720p — 2 Mbps
docker run --rm -v "$WORK_DIR/output_task3":/media ffmpeg-lab \
    -y -i /media/video_1min.mp4 \
    -vf scale=-2:720 -c:v libx264 -b:v 2000k -preset fast \
    -c:a aac -b:a 128k \
    /media/ladder/video_720.mp4

# 480p — 1 Mbps (low quality, low bandwidth)
docker run --rm -v "$WORK_DIR/output_task3":/media ffmpeg-lab \
    -y -i /media/video_1min.mp4 \
    -vf scale=-2:480 -c:v libx264 -b:v 1000k -preset fast \
    -c:a aac -b:a 96k \
    /media/ladder/video_480.mp4
```

**Encoding ladder summary:**

| Rendition | Resolution | Video bitrate | Audio bitrate | Codec |
|-----------|-----------|--------------|--------------|-------|
| High | original (≤1080p) | 4 Mbps | 128 kbps | H.264 / AAC |
| Medium | 720p | 2 Mbps | 128 kbps | H.264 / AAC |
| Low | 480p | 1 Mbps | 96 kbps | H.264 / AAC |

> `-vf scale=-2:720` scales the width automatically to maintain aspect ratio, rounding to a multiple of 2 (required by H.264).

> All renditions use H.264/AAC because Bento4's `mp4dash` and `mp4hls` tools require MP4-compatible codecs for CENC encryption.

---

## 3.4 Part 2 — Fragmentation (Bento4)

Plain MP4 files cannot be encrypted with MPEG-CENC — they must be **fragmented** first. A fragmented MP4 is structured so that each sample is self-contained, which is required for adaptive streaming and encryption.

```bash
# Loop over all renditions in ladder/
for filename in video_1080.mp4 video_720.mp4 video_480.mp4; do
    docker run --rm -v "$WORK_DIR/output_task3":/media bento4-lab \
        mp4fragment /media/ladder/$filename /media/fragmented/$filename
done
```

> If you try to run `mp4encrypt` on a non-fragmented file, Bento4 will exit with: `"file is not fragmented"`. Fragmentation is mandatory.

---

## 3.5 Part 3 — Packaging with DRM (Bento4)

A single `mp4dash` command packages all three renditions into a multi-bitrate DASH manifest **and** an HLS master playlist simultaneously, with inline ClearKey encryption applied at packaging time.

```bash
docker run --rm -v "$WORK_DIR/output_task3":/media bento4-lab \
    mp4dash \
    --encryption-key=$KID:$KEY \
    --encryption-cenc-scheme=cbcs \
    --hls \
    --force \
    --output-dir=/media/packaged \
    /media/fragmented/video_1080.mp4 \
    /media/fragmented/video_720.mp4 \
    /media/fragmented/video_480.mp4
```

**Flag breakdown:**

| Flag | Value | Purpose |
|------|-------|---------|
| `--encryption-key` | `KID:KEY` | ClearKey encryption — Key ID and Content Key (32-char hex each) |
| `--encryption-cenc-scheme` | `cbcs` | CENC encryption scheme — **required** when `--hls` is used |
| `--hls` | — | Generate HLS output (`master.m3u8`) alongside DASH |
| `--force` | — | Overwrite `output-dir` if it already exists |
| `--output-dir` | `/media/packaged` | Output directory inside the container |

### Why `--encryption-cenc-scheme=cbcs`?

CENC (Common Encryption) defines two encryption schemes:

| Scheme | Algorithm | Used by |
|--------|-----------|---------|
| `cenc` | AES-CTR (default) | DASH / Widevine / PlayReady |
| `cbcs` | AES-CBC with pattern | **HLS (mandatory)** / FairPlay |

When `--hls` is requested, Bento4 enforces `cbcs` because Apple's HLS specification requires it. Without this flag, `mp4dash --hls` exits with:
```
ERROR: --hls requires --encryption-cenc-scheme=cbcs
```

---

## 3.6 DRM Keys

```bash
KID="10000000000000000000000000000001"  # Key ID  (32 hex chars = 16 bytes)
KEY="10000000000000000000000000000001"  # Content Key (32 hex chars = 16 bytes)
```

> **These are test keys only.** In a production system, keys are generated by a Key Management System (KMS) and distributed via a license server (Widevine, FairPlay, PlayReady). For this lab, ClearKey is used — the key is embedded in the manifest, which provides format-level packaging verification but not real content protection.

---

## 3.7 Output Structure

```
output_task3/
├── ladder/
│   ├── video_1080.mp4        ← H.264 1080p rendition
│   ├── video_720.mp4         ← H.264 720p rendition
│   └── video_480.mp4         ← H.264 480p rendition
├── fragmented/
│   ├── video_1080.mp4        ← Fragmented version of 1080p
│   ├── video_720.mp4         ← Fragmented version of 720p
│   └── video_480.mp4         ← Fragmented version of 480p
└── packaged/
    ├── stream.mpd             ← DASH manifest (all 3 renditions, encrypted)
    ├── master.m3u8            ← HLS master playlist (all 3 renditions, encrypted)
    └── ...                    ← Encrypted segments
```

---

## 3.8 Log File

When running the script, all the output from the terminal is captured to `task3_output.log` using:

```bash
exec > >(tee "$LOG_FILE") 2>&1
```

This mirrors output to both the terminal and the log file simultaneously — the same pattern used in Task 2.
