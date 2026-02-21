# --- CONFIGURATION ---
INPUT_SOURCE="original_video.mp4"
IMAGE_NAME="ffmpeg-lab"
LOG_FILE="task2_output.log"

# get current working directory to mount into Docker container
WORK_DIR=$(pwd)

# Redirect all output (stdout + stderr) to log file and terminal
exec > >(tee "$LOG_FILE") 2>&1

echo "--- STARTING TASK 2 ---"

# Create output directories
mkdir -p part_a part_b

echo "[PREP] Cutting video to 60 seconds..."
docker run --rm -v "$WORK_DIR":/out $IMAGE_NAME \
    -i /out/$INPUT_SOURCE -t 60 -c copy /out/video_1min.mp4

echo "[PART A] Generating HLS (MP4 container, H.264, AAC)..."

docker run --rm -v "$WORK_DIR":/out $IMAGE_NAME \
    -i /out/video_1min.mp4 \
    -c:v libx264 -c:a aac -b:v 1M -b:a 128k \
    -f hls \
    -hls_time 10 \
    -hls_list_size 0 \
    -hls_segment_type fmp4 \
    -hls_segment_filename "/out/part_a/segment_%03d.m4s" \
    /out/part_a/playlist_hls.m3u8

echo "[PART B] Generating DASH (MKV container, VP9, AAC)..."

docker run --rm -v "$WORK_DIR":/out $IMAGE_NAME \
    -i /out/video_1min.mp4 \
    -c:v libvpx-vp9 -c:a aac -b:v 1M -b:a 128k \
    -f dash \
    -seg_duration 10 \
    -init_seg_name "init-stream\$RepresentationID\$.mkv" \
    -media_seg_name "chunk-stream\$RepresentationID\$-\$Number%05d\$.mkv" \
    /out/part_b/manifest_dash.mpd

echo "--- TASK 2 COMPLETE ---"
echo "Outputs created:"
echo "1. HLS: part_a/playlist_hls.m3u8 (with .m4s segments)"
echo "2. DASH: part_b/manifest_dash.mpd (with .webm/mkv segments)"