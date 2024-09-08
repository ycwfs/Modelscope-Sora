SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# input data
echo "[1/4] Downloading input datasets to input"
mkdir -p ${SCRIPT_DIR}/input && cd ${SCRIPT_DIR}/input
curl -o .input-data.tar.gz https://dail-wlcb.oss-cn-wulanchabu.aliyuncs.com/dj-competition/modelscope_sora/data/input-data.tar.gz
tar zxf .input-data.tar.gz

# pretrain models
echo "[2/4] Downloading pretrained model to pretrained models"
cd ${SCRIPT_DIR}/toolkit/training/pretrained_models/Motion_Module/
wget https://dail-wlcb.oss-cn-wulanchabu.aliyuncs.com/dj-competition/modelscope_sora/models/easyanimate_mm_16x256x256_pretrain.safetensors --no-check-certificate
wget https://dail-wlcb.oss-cn-wulanchabu.aliyuncs.com/dj-competition/modelscope_sora/models/easyanimate_mm_16x512x512_pretrain.safetensors --no-check-certificate
cd ${SCRIPT_DIR}/toolkit/training/pretrained_models/Diffusion_Transformer/
wget https://dail-wlcb.oss-cn-wulanchabu.aliyuncs.com/dj-competition/modelscope_sora/models/PixArt-XL-2-512x512.tar --no-check-certificate
tar xvf PixArt-XL-2-512x512.tar

# for models used by vbench
echo "[3/4] Downloading models used by vbench"
cd ${SCRIPT_DIR}/toolkit/evaluation
wget http://dail-wlcb.oss-cn-wulanchabu.aliyuncs.com/dj-competition/modelscope_sora/models/vbench_models.tar.gz --no-check-certificate
tar -zxvf vbench_models.tar.gz

# for data-juicer
echo "[4/4] Updating toolkit/data-juicer"
cd ${SCRIPT_DIR}/toolkit/data-juicer
git pull origin main || true

echo "Done"


# aesthetic videos first,  some videos don't have caption(video_captioning_from_summarizer_mapper(mm),video_captioning_from_frames_mapper,image_captioning_mapper,image_captioning_from_gpt4v_mapper(need api)) 
# caption augment(nlpaug_en_mapper)
# resize???? VideoResizeResolutionMapper