# Task 3: DRM with Bento4

[← Back to README](../README.md) | [Previous: Task 2](task2-video-packaging.md) | [Next: Task 4 →](task4-vod-investigation.md)

## Objective

Set up Bento4 inside a Docker container and apply DRM (Digital Rights Management) to the packaged video files from Task 2.

## 3.1 Bento4 Docker Container

### Dockerfile

<!-- TODO: Add your actual Bento4 Dockerfile -->

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget -O /tmp/bento4.zip https://www.bok.net/Bento4/binaries/Bento4-SDK-1-6-0-641.x86_64-unknown-linux.zip && \
    unzip /tmp/bento4.zip -d /opt/ && \
    ln -s /opt/Bento4-SDK-1-6-0-641.x86_64-unknown-linux /opt/bento4 && \
    rm /tmp/bento4.zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/bento4/bin:${PATH}"

WORKDIR /media
```

### Build

```bash
docker build -t bento4-lab -f dockerfiles/Dockerfile.bento4 .
```

<!-- TODO: Screenshot of successful build -->
<!-- ![Bento4 build](../screenshots/task3/bento4-build.png) -->

## 3.2 DRM Pipeline

The DRM encryption pipeline consists of three steps:

```
Source MP4 → mp4fragment → mp4encrypt → mp4dash/mp4hls
```

### Step 1: Fragment the MP4

MP4 files must be fragmented before encryption.

```bash
docker run --rm -v "$(pwd)/media:/media" bento4-lab \
  mp4fragment /media/hls/output_h264.mp4 /media/drm/fragmented.mp4
```

<!-- TODO: Screenshot of fragment output -->
<!-- ![Fragment](../screenshots/task3/fragment.png) -->

### Step 2: Encrypt with mp4encrypt

```bash
docker run --rm -v "$(pwd)/media:/media" bento4-lab \
  mp4encrypt \
  --method MPEG-CENC \
  --key 1:000102030405060708090a0b0c0d0e0f:random \
  --property 1:KID:00112233445566778899aabbccddeeff \
  /media/drm/fragmented.mp4 \
  /media/drm/encrypted.mp4
```

<!-- TODO: Replace the key and KID values with the ones you actually used -->
<!-- TODO: Screenshot of encrypt output -->
<!-- ![Encrypt](../screenshots/task3/encrypt.png) -->

### Step 3: Package for DASH with DRM

```bash
docker run --rm -v "$(pwd)/media:/media" bento4-lab \
  mp4dash \
  --widevine \
  --widevine-header provider:widevine_test \
  -o /media/drm/dash_output \
  /media/drm/encrypted.mp4
```

<!-- TODO: Screenshot of DASH DRM packaging output -->
<!-- ![DASH DRM](../screenshots/task3/dash-drm.png) -->

## 3.3 Verification

### mp4info Before Encryption

```bash
docker run --rm -v "$(pwd)/media:/media" bento4-lab \
  mp4info /media/drm/fragmented.mp4
```

<!-- TODO: Paste mp4info output here showing no encryption -->
<!-- ![mp4info before](../screenshots/task3/mp4info-before.png) -->

### mp4info After Encryption

```bash
docker run --rm -v "$(pwd)/media:/media" bento4-lab \
  mp4info /media/drm/encrypted.mp4
```

<!-- TODO: Paste mp4info output here showing encryption is applied (look for "scheme: cenc") -->
<!-- ![mp4info after](../screenshots/task3/mp4info-after.png) -->

## 3.4 Encoding Ladder with DRM

<!-- TODO: If you created an encoding ladder, apply DRM to each rendition -->

The encoding ladder from Task 2 can be combined with DRM by repeating the fragment → encrypt → package pipeline for each quality level:

| Rendition | Fragment | Encrypt | Package |
|-----------|----------|---------|---------|
| 1080p | `mp4fragment out_1080p.mp4 frag_1080p.mp4` | `mp4encrypt ... frag_1080p.mp4 enc_1080p.mp4` | Include in `mp4dash` |
| 720p | `mp4fragment out_720p.mp4 frag_720p.mp4` | `mp4encrypt ... frag_720p.mp4 enc_720p.mp4` | Include in `mp4dash` |
| 480p | `mp4fragment out_480p.mp4 frag_480p.mp4` | `mp4encrypt ... frag_480p.mp4 enc_480p.mp4` | Include in `mp4dash` |

```bash
# Package all renditions together
docker run --rm -v "$(pwd)/media:/media" bento4-lab \
  mp4dash \
  --widevine \
  --widevine-header provider:widevine_test \
  -o /media/drm/dash_ladder \
  /media/drm/enc_1080p.mp4 \
  /media/drm/enc_720p.mp4 \
  /media/drm/enc_480p.mp4
```

<!-- TODO: Screenshot of multi-rendition DRM output -->
<!-- ![Encoding ladder DRM](../screenshots/task3/encoding-ladder-drm.png) -->
