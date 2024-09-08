export VIDEO_FOLDER="/data1/wangqiurui/code/sora/dj_sora_challenge/input/videos/"
export OUTPUT_FOLDER="/data1/wangqiurui/code/sora/dj_sora_challenge/input/all_cut_13/"

# Cut raw videos
python split.py \
    $VIDEO_FOLDER \
    --threshold 10 20 30 \
    --frame_skip 0 1 2 \
    --min_seconds 1 \
    --max_seconds 3 \
    --save_dir $OUTPUT_FOLDER