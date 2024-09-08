# Modelscope_Sora挑战赛第三名的解决方案
# CUPES-IAIS scheme

## DATA ANALYSIS

### Check the videos' resolution and duration

 **Resolution statistics:**

- 1280x720: 14815 (29.63%)
- 640x360: 12954 (25.91%)
- 320x240: 6531 (13.06%)
- 720x1280: 4321 (8.64%)
- 360x640: 2922 (5.84%)
- 1366x720: 2751 (5.50%)
- 720x1366: 1183 (2.37%)

**Video Duration Statistics:**

- Total videos: 50000
- Shortest duration: 0.13 seconds
- Longest duration: 743.52 seconds
- Average duration: 23.14 seconds
- Median duration: 15.50 seconds
- Standard deviation: 21.57 seconds

## DATA PROCESS

### Use data-juice to filter the data first

#### filter aes

```yaml
  - video_aesthetics_filter:
      #hf_scorer_model: shunk031/aesthetics-predictor-v2-sac-logos-ava1-l14-linearMSE # Huggingface model name for the aesthetics predictor
      min_score: 0.4                                          # the min aesthetics score of filter range
      max_score: 1.0                                          # the max aesthetics score of filter range
      frame_sampling_method: all_keyframes                        # sampling method of extracting frame images from the videos. Should be one of ["all_keyframe", "uniform"]. The former one extracts all key frames and the latter one extract specified number of frames uniformly from the video. Default: "uniform" with frame_num=3, considering that the number of keyframes can be large while their difference is usually small in terms of their aesthetics.
      frame_num: 3                                            # the number of frames to be extracted uniformly from the video. Only works when frame_sampling_method is "uniform". If it's 1, only the middle frame will be extracted. If it's 2, only the first and the last frames will be extracted. If it's larger than 2, in addition to the first and the last frames, other frames will be extracted uniformly within the video duration.
      reduce_mode: avg                                        # reduce mode to the all frames extracted from videos, must be one of ['avg','max', 'min'].
      any_or_all: all                                         # keep this sample when any/all images meet the filter condition
      mem_required: '1500MB'                                  # This operation (Op) utilizes deep neural network models that consume a significant amount of memory for computation, hence the system's available memory might constrains the maximum number of processes that can be launched
```

#### filter wm

```yaml
  - video_watermark_filter:                                 # filter samples according to the predicted watermark probabilities of videos in them
      #hf_watermark_model: amrul-hzz/watermark_detector        # Huggingface model name for watermark classification
      prob_threshold: 0.6                              # the predicted watermark probability threshold for samples, range from 0 to 1
      frame_sampling_method: all_keyframes                    # sampling method of extracting frame images from the videos. Should be one of ["all_keyframes", "uniform"]. The former one extracts all key frames and the latter one extract specified number of frames uniformly from the video. Default: "all_keyframes".
      frame_num: 10                                            # the number of frames to be extracted uniformly from the video. Only works when frame_sampling_method is "uniform". If it's 1, only the middle frame will be extracted. If it's 2, only the first and the last frames will be extracted. If it's larger than 2, in addition to the first and the last frames, other frames will be extracted uniformly within the video duration.
      reduce_mode: avg                                        # reduce mode for multiple sampled video frames to compute final predicted watermark probabilities of videos, must be one of ['avg','max', 'min'].
      any_or_all: all                                         # keep this sample when any/all images meet the filter condition
      mem_required: '20GB'  
```

#### filter nsfw,static and motion

```yaml
  - video_nsfw_filter:                                      # filter samples according to the nsfw scores of videos in them
      #hf_nsfw_model: Falconsai/nsfw_image_detection           # Huggingface model name for nsfw classification
      score_threshold: 0.4                           # the nsfw score threshold for samples, range from 0 to 1
      frame_sampling_method: all_keyframes                    # sampling method of extracting frame images from the videos. Should be one of ["all_keyframes", "uniform"]. The former one extracts all key frames and the latter one extract specified number of frames uniformly from the video. Default: "all_keyframes".
      frame_num: 3                                        
      reduce_mode: avg                                        # reduce mode for multiple sampled video frames to compute nsfw scores of videos, must be one of ['avg','max', 'min'].
      any_or_all: all                                         # keep this sample when any/all images meet the filter condition
  - video_motion_score_filter:                              # Keep samples with video motion scores within a specific range.
      min_score: 0.25                                         # the minimum motion score to keep samples
      max_score: 10000                                      # the maximum motion score to keep samples
      sampling_fps: 2                                        # the samplig rate of frames_per_second to compute optical flow
      any_or_all: all                                         # keep this sample when any/all videos meet the filter condition
```

### The video split and video duration filter don't fit my require because of the 'any','all' stretagy, so we use another scripts from easyAnimate that include PySceneDetect detect sences to split videos.

try split to 3-10s, 1-3s. The 1-3s setting is better.
Datail code in split.sh, split.py.

### Use gpt4o-mini api to caption

include a fewer base64 encoded frames and prompt. 6000 videos cost 18$
Detail code in jupyter notebook.

### Improvement points

⭐⭐⭐ split video before filter

```yaml
  - video_split_by_scene_mapper:                            # split videos into scene clips
      detector: 'ContentDetector'                             # PySceneDetect scene detector. Should be one of ['ContentDetector', 'ThresholdDetector', 'AdaptiveDetector`]
      threshold: 27.0                                         # threshold passed to the detector
      min_scene_len: 10                                       # minimum length of any scene
      show_progress: false                                    # whether to show progress from scenedetect

  - video_validity_filter: # new created filter op
      any_or_all: all

  - video_duration_filter:                                  # Keep data samples whose videos' durations are within a specified range.
      min_duration: 1                                         # the min video duration of filter range (in seconds)
      max_duration: 3                                        # the max video duration of filter range (in seconds)
      any_or_all: all                                         # keep this sample when any/all videos meet the filter condition

  - video_resolution_filter:                                # filter samples according to the resolution of videos in them
      min_width: 256                                         # the min resolution of horizontal resolution filter range (unit p)
      max_width: 1800                                         # the max resolution of horizontal resolution filter range (unit p)
      min_height: 256                                         # the min resolution of vertical resolution filter range (unit p)
      max_height: 1800                                        # the max resolution of vertical resolution filter range (unit p)
      any_or_all: all                                         # keep this sample when any/all videos meet the filter condition
```

## final scheme

### split videos to 1-3s before filter at first

### filter videos as same as preliminary, get 100k videos.

### consider the crop strategy in training may loss many sence info when the resolution is high, so i resize the video to the training setting(512x512,256x256) use ffmpeg first.

### use miniCPM_v2.6 to caption videos, detail in cpm_caption.py.
[miniCPM_v2.6](https://modelscope.cn/models/OpenBMB/MiniCPM-V-2_6)
