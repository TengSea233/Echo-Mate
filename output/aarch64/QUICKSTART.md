# Echo-Mate AArch64 快速开始

## 部署步骤

### 1. 复制到目标设备

将 `DeskBot_demo` 目录复制到 LubanCat 或其他 ARM64 设备：

```bash
# 使用 scp
scp -r DeskBot_demo cat@lubancat:~/

# 或使用 rsync
rsync -avz DeskBot_demo/ cat@lubancat:~/DeskBot_demo/
```

### 2. 运行程序

在目标设备上：

```bash
cd ~/DeskBot_demo
./run.sh
```

或者手动设置库路径：

```bash
cd ~/DeskBot_demo
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
./main
```

## 目录结构

```
DeskBot_demo/
├── main              # 主程序
├── run.sh           # 启动脚本（推荐）
├── lib/             # 所有依赖库（已包含）
│   ├── libjsoncpp.so.25
│   ├── libopus.so.0
│   ├── libportaudio.so.2
│   ├── libopenblas.so.0
│   ├── libasound.so.2
│   ├── libjson-c.so.4
│   ├── libcurl.so.4
│   ├── librga.so
│   ├── librknnrt.so
│   └── ...
├── model/           # YOLO 模型文件
│   ├── yolov5.rknn
│   └── coco_80_labels_list.txt
├── third_party/     # 唤醒词资源
│   ├── snowboy/
│   └── audio/
├── system_para.conf      # 系统配置
├── gaode_adcode.json     # 城市代码
└── cacert.pem           # SSL 证书
```

## 常见问题

### Q: 运行时报错找不到库文件？
**A**: 确保使用 `./run.sh` 启动，它会自动设置 `LD_LIBRARY_PATH`。

### Q: 如何检查依赖是否完整？
**A**: 运行以下命令：
```bash
cd ~/DeskBot_demo
ldd ./main | grep "not found"
```
如果输出为空，说明所有依赖都已找到。

### Q: 库文件版本不匹配怎么办？
**A**: 可以尝试使用系统自带的库：
```bash
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
./main
```

## 其他项目

### AIChat_demo（独立语音助手）
```bash
cd ~/AIChat_demo
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
./bin/AIChatClient
```

### yolov5_demo（独立目标检测）
```bash
cd ~/yolov5_demo
./rknn_yolov5_demo
# 注意：需要目标设备安装 librknnrt.so
```
