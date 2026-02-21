# --- CONFIGURATION ---
INPUT_FILE="video_1min.mp4"
FFMPEG_IMAGE="ffmpeg-lab"  
BENTO4_IMAGE="bento4-lab"

OUTPUT_DIR="output_task3"
LOG_FILE="task3_output.log"

# DRM Keys (Test/ClearKey)
KID="10000000000000000000000000000001"
KEY="10000000000000000000000000000001"

WORK_DIR=$(pwd)

# --- LOGGING SETUP ---
exec > >(tee "$LOG_FILE") 2>&1

echo "---------------------------------------------"
echo "      TASK 3: DRM & ENCODING LADDER"
echo "---------------------------------------------"
echo "Start: $(date)"

# --- SETUP ---
# Create directories
mkdir -p "$OUTPUT_DIR"/{ladder,fragmented,packaged}

# Check for input video
if [ ! -f "$INPUT_FILE" ]; then
    echo "  Copying video from Task 2..."
    cp ../task2/video_1min.mp4 . 2>/dev/null
fi
# Copy to output so Docker mapping is clean
cp "$INPUT_FILE" "$OUTPUT_DIR/"


#  PART 1: ENCODING LADDER (FFmpeg)
#  Creates 3 versions: High (1080p), Medium (720p), Low (480p)

echo "---------------------------------------------"
echo "      PART 1: ENCODING LADDER                "
echo "---------------------------------------------"

# 1. High Quality (1080p)
echo "Encoding 1080p..."
docker run --rm -v "$WORK_DIR/$OUTPUT_DIR":/media $FFMPEG_IMAGE \
    -y -i /media/video_1min.mp4 \
    -c:v libx264 -b:v 4000k -preset fast \
    -c:a aac -b:a 128k \
    /media/ladder/video_1080.mp4

# 2. Medium Quality (720p)
echo "[LADDER] Encoding 720p..."
docker run --rm -v "$WORK_DIR/$OUTPUT_DIR":/media $FFMPEG_IMAGE \
    -y -i /media/video_1min.mp4 \
    -vf scale=-2:720 -c:v libx264 -b:v 2000k -preset fast \
    -c:a aac -b:a 128k \
    /media/ladder/video_720.mp4

# 3. Low Quality (480p)
echo "[LADDER] Encoding 480p..."
docker run --rm -v "$WORK_DIR/$OUTPUT_DIR":/media $FFMPEG_IMAGE \
    -y -i /media/video_1min.mp4 \
    -vf scale=-2:480 -c:v libx264 -b:v 1000k -preset fast \
    -c:a aac -b:a 96k \
    /media/ladder/video_480.mp4



#  PART 2: FRAGMENTATION (Bento4)
echo "----------------------------------------------"
echo "     PART 2: FRAGMENTATION                    "
echo "----------------------------------------------"

for file in "$OUTPUT_DIR"/ladder/*.mp4; do
    filename=$(basename "$file")
    echo "[FRAGMENT] Processing $filename..."
    
    docker run --rm -v "$WORK_DIR/$OUTPUT_DIR":/media $BENTO4_IMAGE \
        mp4fragment /media/ladder/"$filename" /media/fragmented/"$filename"
done


#  PART 3: ENCRYPTION & PACKAGING (Bento4)
echo ""
echo "----------------------------------------------"
echo "     PART 3: PACKAGING (DASH + HLS)           "
echo "----------------------------------------------"


docker run --rm -v "$WORK_DIR/$OUTPUT_DIR":/media $BENTO4_IMAGE \
    mp4dash \
    --encryption-key=$KID:$KEY \
    --encryption-cenc-scheme=cbcs \
    --hls \
    --force \
    --output-dir=/media/packaged \
    /media/fragmented/video_1080.mp4 \
    /media/fragmented/video_720.mp4 \
    /media/fragmented/video_480.mp4

echo ""
echo "---------------------------------------------"
echo "      TASK 3 COMPLETE"
echo "---------------------------------------------"
echo "Outputs in $OUTPUT_DIR/packaged/:"
echo " 1. DASH: stream.mpd"
echo " 2. HLS:  master.m3u8 (fMP4 segments)"
echo ""
