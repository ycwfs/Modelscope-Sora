# ModelScope-Sora 竞赛开发套件

## 1. 安装依赖并下载数据 【任选一种方式】

- 使用 Conda 环境
```bash
conda create -n sora python=3.10
conda activate sora

bash install.sh
```
> 若安装过程中出现 `ERROR: CMake must be installed to build dlib`，推荐使用 apt、yum 等包管理器安装 `cmake`；避免使用 PyPI 版本 `pip uninstall cmake`。

- 使用 Docker 镜像
```bash
# 拉取镜像
docker pull pai-platform-registry.cn-beijing.cr.aliyuncs.com/pai/easyanimate:1.1.4-pytorch2.2.0-gpu-py310-cu118-ubuntu22.04

# 启动
docker run --privileged --shm-size 256g --network host --gpus all -v $(pwd):$(pwd) -w $(pwd) -it pai-platform-registry.cn-beijing.cr.aliyuncs.com/pai/easyanimate:1.1.4-pytorch2.2.0-gpu-py310-cu118-ubuntu22.04
```


## 2. 实现数据处理

```bash
# 下载数据和模型
bash download.sh
```

- 赛事候选数据集存放在 `input` 文件夹中。
- 请使用 [data-juicer](https://github.com/modelscope/data-juicer) 从候选数据集中产出训练数据。
- 数据处理代码请存放于 `solution` 文件夹中， 并在 `solution/requirements.txt` 中添加对应的依赖。
- 最后请在 `solution/readme` 中详细介绍所使用的数据处理方案。

```
📦 input/
│   ├── 📂 videos/
│   │   ├── 📄 dj_video_00000.mp4
│   │   ├── 📄 dj_video_00001.mp4
│   │   └── 📄 .....
│   └── 📄 data.jsonl
│ ...
```

处理后数据集，需要按照以下的方式存放

```
📦 output/
├── 📂 processed_data/
│       └── 📄 processed_data.jsonl
│ ...
```

`processed_data.jsonl` 需要构造为标准的 `JSONL` 文件，格式如下：
```json
{"videos":["/abs_path/input/videos/dj_video_00000.mp4"],"text":"<__dj__video> a car is shown <|__dj__eoc|>"}
{"videos":["/abs_path/input/videos/dj_video_00001.mp4"],"text":"<__dj__video> in a kitchen a woman adds different ingredients into the pot and stirs it <|__dj__eoc|>"}
...
```
注意： processed_data.jsonl 中的 `videos` 需要设置为<span style="color:red">**绝对路径**</span>。


## 3. 执行模型训练、样本生成、评测流程
- 模型训练:
```bash
cd toolkit/training

# 请根据自身需求修改训练脚本内的参数
# 如果以256分辨率训练，请修改train_lora_256.sh中的参数
# 如果以512分辨率训练，请修改train_lora_512.sh中的参数
#          #################
# 您只能修改                   内的参数
#          #################

# 修改完毕后执行训练脚本
bash train_lora_256.sh
# 或者
bash train_lora_512.sh
```

- 样本生成：
```bash
cd toolkit/training

# 请根据自身需求修改推理脚本内的参数
# 如果生成256分辨率的样本，请修改infer_lora_256.sh中的参数
# 如果生成512分辨率的样本，请修改infer_lora_512.sh中的参数
#          #################
# 您只能修改                   内的参数
#          #################

# 修改完毕后执行推理脚本
bash infer_lora_256.sh
# 或者
bash infer_lora_512.sh
```

- 评测
```bash
cd toolkit/evaluation

# 请根据自身需求修改评测脚本内的参数
#          #################
# 您只能修改                   内的参数
#          #################

# 修改完毕后执行评测脚本
bash evaluate.sh
```

## 4. 向天池提交

- 请将数据处理方案、训练及推理脚本、训练数据、lora 模型、生成的视频、测评结果等打包成一个 zip 文件，上传至天池平台进行评测。

```bash
zip -r submit.zip solution output
```

- 为保证提交的规范性，务必遵循以下文件打包结构并提交以下所需的文件，请勿添加额外的顶级目录。

```
submit.zip
├── solution
│   ├── readme                                  ########## 介绍您的算法设计和执行流程 ########## 
│   ├── requirements.txt                        ########## 第三方 pip 依赖库 ########## 
|   ├── ...
└── output
    ├── train_lora.sh                           ########## 训练脚本 ########## 
    ├── infer_lora.sh                           ########## 视频生成脚本 ##########
    ├── processed_data
    |   └── processed_data.jsonl                ########## 用于训练的数据文件 ##########
    ├── lora_model								  
    |   └── checkpoints-xxx.safetensors         ########## 用于采样视频的 lora 模型 ########## 
    ├── train.log                               ########## 训练日志 ##########  
    ├── generated_videos                        ########## 模型生成的视频 ########## 
    |   ├── {prompt0}-0.mp4
    |   ├── {prompt0}-1.mp4
    |   ├── {prompt0}-2.mp4
    |   ├── {prompt1}-0.mp4
    |   ├── ...
    └── eval_results                            ########## 测评结果 ########## 
```
