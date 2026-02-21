# Task 2: Video Packaging

[← Back to README](../README.md) | [Previous: Task 1](task1-environment-setup.md) | [Next: Task 3 →](task3-drm-bento4.md)

## Objective

Download a video, cut it to 1 minute, and package it in two formats: HLS (Part A) and MPEG-DASH (Part B).

## 2.1 Source Video

<!-- TODO: Specify which video you downloaded (e.g., Big Buck Bunny) and where from -->

**Video chosen:** <!-- TODO: e.g., Big Buck Bunny from https://peach.blender.org/ -->

Cut the video to 1 minute:

```bash
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab \
  -i /media/input.mp4 -t 60 -c copy /media/input_cut.mp4
```

<!-- TODO: Screenshot showing the cut command output -->
<!-- ![Cut video](../screenshots/task2/cut-video.png) -->

---

## Part A: HLS Packaging

**Requirements:** Container: MP4 | Video Codec: H.264 AVC | Audio Codec: AAC

### Encode to H.264 + AAC

```bash
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab \
  -i /media/input_cut.mp4 \
  -c:v libx264 -c:a aac \
  /media/hls/output_h264.mp4
```

### Package as HLS

```bash
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab \
  -i /media/hls/output_h264.mp4 \
  -c copy -f hls \
  -hls_time 6 -hls_playlist_type vod \
  /media/hls/output.m3u8
```

<!-- TODO: Screenshot of HLS packaging output -->
<!-- ![HLS packaging](../screenshots/task2/hls-packaging.png) -->

### HLS Output Files

<!-- TODO: List the generated files -->

```
media/hls/
├── output.m3u8          ← HLS playlist
├── output0.ts           ← Segment 0
├── output1.ts           ← Segment 1
├── ...
```

<!-- TODO: Screenshot showing the output file tree -->
<!-- ![HLS files](../screenshots/task2/hls-files.png) -->

---

## Part B: MPEG-DASH Packaging

**Requirements:** Container: MKV | Video Codec: VP9 | Audio Codec: AAC

### Encode to VP9 + AAC (MKV container)

```bash
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab \
  -i /media/input_cut.mp4 \
  -c:v libvpx-vp9 -c:a aac \
  /media/dash/output_vp9.mkv
```

### Package as MPEG-DASH

```bash
docker run --rm -v "$(pwd)/media:/media" ffmpeg-lab \
  -i /media/dash/output_vp9.mkv \
  -c copy -f dash \
  /media/dash/output.mpd
```

<!-- TODO: Screenshot of DASH packaging output -->
<!-- ![DASH packaging](../screenshots/task2/dash-packaging.png) -->

### DASH Output Files

<!-- TODO: List the generated files -->

```
media/dash/
├── output.mpd            ← DASH manifest
├── chunk-stream0-00001.webm
├── chunk-stream1-00001.webm
├── ...
```

<!-- TODO: Screenshot showing the output file tree -->
<!-- ![DASH files](../screenshots/task2/dash-files.png) -->

---

## Encoding Ladder (Optional)

<!-- TODO: If you created multiple renditions, document them here -->

| Resolution | Bitrate | Codec | Command |
|-----------|---------|-------|---------|
| 1920×1080 | 5000k | H.264 | `ffmpeg -i input.mp4 -vf scale=1920:1080 -b:v 5000k -c:v libx264 -c:a aac out_1080p.mp4` |
| 1280×720 | 3000k | H.264 | `ffmpeg -i input.mp4 -vf scale=1280:720 -b:v 3000k -c:v libx264 -c:a aac out_720p.mp4` |
| 854×480 | 1500k | H.264 | `ffmpeg -i input.mp4 -vf scale=854:480 -b:v 1500k -c:v libx264 -c:a aac out_480p.mp4` |
