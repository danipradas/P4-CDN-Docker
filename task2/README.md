# Task 2 — Video Packaging (HLS & MPEG-DASH)

**P4: CDN & Docker for Encoding** | Universitat Pompeu Fabra · Equips i Sistemes de Vídeo

---

## Objective

> *"Now that you have your container ready, download any video you like from the internet (if lack of ideas, try BBB). Cut it to 1 minute and try to package it like this:*
> - *a) MP4 container with HLS — Video H.264 AVC, audio AAC*
> - *b) MKV container with MPEG-DASH — Video VP9, audio AAC"*

---

## Source Video

The iconic goal at the buzzer that let us enter into the 2009 Champions League Final, **[Gol de Andrés Iniesta en Stanford Bridge Narrado Por Fernando Palomo HD](https://www.youtube.com/watch?v=i-d24NX28Xo)** was used as the source. 

- Source file: `original_video.mp4`
- Duration cut to: **60 seconds** (`video_1min.mp4`)

---

## Script

All steps are automated in [`run_task2.sh`](run_task2.sh). It outputs a log file (`task2_output.log`) alongside all generated files.

```bash
chmod +x run_task2.sh
.\run_task2.sh
```
The rest of this README explains the commands in `run_task2.sh` and the rationale behind them. The script is designed to be run from the `task2/` directory.

## Preparation — Cut to 1 Minute

The full source is trimmed to 60 seconds using stream copy (`-c copy`) — no re-encoding, just cutting.

```bash
docker run --rm -v "$WORK_DIR":/out ffmpeg-lab \
    -i /out/original_video.mp4 -t 60 -c copy /out/video_1min.mp4
```

| Flag | Meaning |
|------|---------|
| `-t 60` | Stop after 60 seconds |
| `-c copy` | Copy streams as-is — no transcode, instant operation |

---

## Part A — HLS (HTTP Live Streaming)

**Spec:** MP4 container · H.264 AVC video · AAC audio

```bash
docker run --rm -v "$WORK_DIR":/out ffmpeg-lab \
    -i /out/video_1min.mp4 \
    -c:v libx264 -c:a aac -b:v 1M -b:a 128k \
    -f hls \
    -hls_time 10 \
    -hls_list_size 0 \
    -hls_segment_type fmp4 \
    -hls_segment_filename "/out/part_a/segment_%03d.m4s" \
    /out/part_a/playlist_hls.m3u8
```

**Key parameters explained:**

| Parameter | Value | Description |
|-----------|-------|-------------|
| `-c:v libx264` | H.264 AVC | Video codec required by the task spec |
| `-c:a aac` | AAC | Audio codec required by the task spec |
| `-b:v 1M` | 1 Mbps | Video bitrate |
| `-b:a 128k` | 128 kbps | Audio bitrate |
| `-f hls` | HLS muxer | FFmpeg output format |
| `-hls_time 10` | 10 s | Target segment duration |
| `-hls_list_size 0` | unlimited | Keep all segments in the playlist (VOD) |
| `-hls_segment_type fmp4` | fMP4 | Use fragmented MP4 segments instead of MPEG-TS |
| `-hls_segment_filename` | `segment_%03d.m4s` | Segment naming pattern |

**Output files (`part_a/`):**
```
part_a/
├── playlist_hls.m3u8    ← HLS master playlist
├── init.mp4             ← fMP4 initialization segment
├── segment_000.m4s      ← Segment 0  (0–10 s)
├── segment_001.m4s      ← Segment 1  (10–20 s)
├── segment_002.m4s      ← Segment 2  (20–30 s)
├── segment_003.m4s      ← Segment 3  (30–40 s)
├── segment_004.m4s      ← Segment 4  (40–50 s)
└── segment_005.m4s      ← Segment 5  (50–60 s)
```

> **Why fMP4 segments instead of TS?** Fragmented MP4 (`.m4s`) is the modern HLS segment format (since HLS v6). It is more efficient, supports CENC encryption natively, and is compatible with DASH — making it the right choice when DRM will be applied later.

---

## Part B — MPEG-DASH

**Spec:** MKV container · VP9 video · AAC audio

```bash
docker run --rm -v "$WORK_DIR":/out ffmpeg-lab \
    -i /out/video_1min.mp4 \
    -c:v libvpx-vp9 -c:a aac -b:v 1M -b:a 128k \
    -f dash \
    -seg_duration 10 \
    -init_seg_name "init-stream\$RepresentationID\$.mkv" \
    -media_seg_name "chunk-stream\$RepresentationID\$-\$Number%05d\$.mkv" \
    /out/part_b/manifest_dash.mpd
```

**Key parameters explained:**

| Parameter | Value | Description |
|-----------|-------|-------------|
| `-c:v libvpx-vp9` | VP9 | Open-source codec by Google — required by the task spec |
| `-c:a aac` | AAC | Audio codec |
| `-f dash` | DASH muxer | FFmpeg MPEG-DASH output format |
| `-seg_duration 10` | 10 s | Segment duration matching Part A |
| `-init_seg_name` | `init-stream$ID$.mkv` | Naming for initialization segments |
| `-media_seg_name` | `chunk-stream$ID$-$N$.mkv` | Naming pattern for media segments |

**Output files (`part_b/`):**
```
part_b/
├── manifest_dash.mpd         ← DASH manifest (XML)
├── init-stream0.mkv          ← Video initialization segment
├── init-stream1.mkv          ← Audio initialization segment
├── chunk-stream0-00001.mkv   ← Video segment 1
├── chunk-stream1-00001.mkv   ← Audio segment 1
├── chunk-stream0-00002.mkv
├── ...
└── chunk-stream1-00006.mkv
```

> **Why VP9 for DASH?** The task explicitly required it. VP9 is ~30–50% more efficient than H.264 at equivalent quality. It is widely used by platforms like YouTube. The MKV container is the natural home for VP9 in a DASH context.

---

## HLS vs MPEG-DASH — Summary

| Property | Part A (HLS) | Part B (DASH) |
|----------|-------------|---------------|
| Container | MP4 (fMP4) | MKV |
| Video codec | H.264 AVC | VP9 |
| Audio codec | AAC | AAC |
| Manifest | `.m3u8` | `.mpd` (XML) |
| Segment extension | `.m4s` | `.mkv` |
| Segment duration | 10 s | 10 s |
| Origin | Apple | MPEG consortium |
| DRM support | AES-128 / SAMPLE-AES / cbcs | CENC (cenc / cbcs) |
