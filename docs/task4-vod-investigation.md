# Task 4: VOD Platform Investigation

[← Back to README](../README.md) | [Previous: Task 3](task3-drm-bento4.md) | [Next: Task 5 →](task5-cdn-implementation.md)

## Objective

Investigate a real-world VOD (Video On Demand) platform using browser developer tools. Identify the streaming protocol, codecs, and DRM system in use.

## 4.1 Platform Chosen

<!-- TODO: Name the platform you investigated -->

**Platform:** <!-- TODO: e.g., Netflix, Disney+, HBO Max, Amazon Prime Video, etc. -->
**URL:** <!-- TODO: platform URL -->

## 4.2 Browser DevTools Analysis

Open the VOD platform in your browser and press `F12` to open Developer Tools. Navigate to the **Network** tab and start playing a video.

### Network Tab Overview

<!-- TODO: Screenshot of the Network tab showing requests while a video is playing -->
<!-- ![Network tab](../screenshots/task4/network-tab.png) -->

### Manifest File

Filter by the manifest file type (`.m3u8` for HLS or `.mpd` for DASH).

<!-- TODO: Screenshot of the manifest file request in the Network tab -->
<!-- ![Manifest file](../screenshots/task4/manifest-file.png) -->

<!-- TODO: Paste relevant parts of the manifest content below -->

```
<!-- TODO: Paste manifest content here -->
```

## 4.3 Streaming Protocol

<!-- TODO: Identify whether the platform uses HLS or DASH -->

**Protocol identified:** <!-- TODO: HLS / DASH -->

**Evidence:**
<!-- TODO: Explain how you determined the protocol (e.g., .m3u8 playlist = HLS, .mpd manifest = DASH) -->

## 4.4 Codecs

<!-- TODO: Identify the video and audio codecs -->

**Video codec:** <!-- TODO: e.g., H.264/AVC, H.265/HEVC, VP9, AV1 -->
**Audio codec:** <!-- TODO: e.g., AAC, Dolby Digital (AC-3), Dolby Atmos (E-AC-3) -->

**Evidence:**
<!-- TODO: Show the codec information from the manifest file or media segment headers -->
<!-- TODO: Screenshot showing codec info -->
<!-- ![Codecs](../screenshots/task4/codecs.png) -->

## 4.5 DRM System

<!-- TODO: Identify the DRM system used -->

**DRM system:** <!-- TODO: Widevine / PlayReady / FairPlay / None -->

**Evidence:**
<!-- TODO: Explain how you identified the DRM (e.g., license request URLs, manifest DRM tags, EME API calls) -->
<!-- TODO: Screenshot showing DRM evidence -->
<!-- ![DRM evidence](../screenshots/task4/drm-evidence.png) -->

## 4.6 Analysis & Conclusions

<!-- TODO: Write a short analysis (3-5 paragraphs) covering: -->
<!-- - Why the platform chose this protocol/codec/DRM combination -->
<!-- - How ABR (Adaptive Bitrate) is implemented -->
<!-- - Any interesting observations from the DevTools analysis -->
<!-- - Comparison with what was learned in Tasks 2 and 3 -->
