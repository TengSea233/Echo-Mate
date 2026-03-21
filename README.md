<h1 align="center">Echo-Mate</h1>

<p align="center">
  <img border="1px" width="75%" src="./assets/main_pic.jpeg">
</p>

<p align="center">
  <a href="https://oshwhub.com/no_chicken/ai-desktop-robot-echo">
    <img src="https://img.shields.io/badge/硬件开源-OSHWHUB-orange" alt="硬件开源">
  </a>
  <a href="https://www.bilibili.com/video/BV161ZaYyEmF/">
    <img src="https://img.shields.io/badge/演示视频-Bilibili-pink" alt="演示视频">
  </a>
  <a href="https://no-chicken.com/">
    <img src="https://img.shields.io/badge/官方文档-no--chicken.com-blue" alt="官方文档">
  </a>
</p>

## 项目简介

Echo-Mate 是一个基于 **RV1106** 芯片的桌面机器人项目，集成了 AI 语音助手、智能相机、天气显示、游戏娱乐等多种功能。采用 **LVGL** 图形库构建的交互界面，配备 1.28 寸圆形触摸屏，是一个功能丰富的 Linux 桌面助手和开发板。

**核心特性：**
- 🤖 AI 语音对话（基于通义千问大模型）
- 📷 AI 相机（YOLOv5 物体检测）
- 🌤️ 实时天气显示
- 🎮 内置多款小游戏
- 🌍 多语言翻译
- 🔧 开源硬件 + 开源软件

---

## 硬件规格

| 参数 | 规格 |
|------|------|
| 芯片 | RV1106 (Rockchip) |
| 处理器 | 单核 Cortex A7 @ 1.2GHz |
| NPU | 1 TOPS，支持 int4/int8/int16 |
| 内存 | 256MB DDR3L |
| 存储 | SD 卡 / NAND FLASH |
| Wi-Fi + 蓝牙 | RTL8723bs |
| 屏幕 | 1.28 寸圆形 LCD (P024C128-CTP)，240×240 分辨率 |
| 屏幕接口 | SPI 显示 + I2C 触摸 |
| 音频 | 喇叭 + 麦克风 (MX1.25mm 接口) |
| 扩展接口 | 8 个 GPIO 引出排针 |

**硬件开源地址：** https://oshwhub.com/no_chicken/ai-desktop-robot-echo

**演示视频：** https://www.bilibili.com/video/BV161ZaYyEmF/

**官方文档：** https://no-chicken.com/

---

## 功能展示

<p align="center">
  <img border="1px" width="100%" src="./assets/show.png">
</p>

<p align="center">
  <img border="1px" width="75%" src="./assets/func_map.png">
</p>

---

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/No-Chicken/Echo-Mate.git
cd Echo-Mate
git submodule update --init --recursive

# 拉取 LFS 大文件
git lfs pull
git submodule foreach --recursive 'git lfs pull'
```

### 2. 开发环境

**推荐系统：** Ubuntu 22.04 LTS

**基础依赖：**
```bash
sudo apt-get install repo git ssh make gcc gcc-multilib g++-multilib \
    module-assistant expect g++ gawk texinfo libssl-dev bison flex \
    fakeroot cmake unzip gperf autoconf device-tree-compiler \
    libncurses5-dev pkg-config
```

**PC 模拟器开发（可选）：**
```bash
sudo apt-get install libsdl2-dev libsdl2-image-dev libdrm-dev
```

**AIChat 客户端编译（可选）：**
```bash
sudo apt-get install libjsoncpp-dev libopus-dev libasound-dev \
    libportaudio2 libboost-dev libwebsocketpp-dev
```

### 3. 构建方式

#### 方式一：PC 模拟器（快速开发测试）

```bash
cd Demo/DeskBot_demo

# 修改配置为模拟器模式
# conf/dev_conf.h: #define LV_USE_SIMULATOR 1

mkdir build && cd build
cmake ..
make -j$(nproc)

# 运行
../bin/main
```

#### 方式二：Docker 交叉编译（推荐用于部署）

```bash
# 启动 Docker 环境
docker-compose up -d
docker exec -it echo-mate /bin/bash

# 在容器内编译
./build_aarch64_complete.sh
```

#### 方式三：SDK 固件编译

详见 [SDK/README.md](./SDK/README.md)

---

## 部署到开发板

### 快速部署

```bash
# 1. 拷贝到开发板（替换 IP 地址）
scp -r output/aarch64/DeskBot_demo root@172.32.0.93:/root/

# 2. SSH 登录开发板
ssh root@172.32.0.93

# 3. 运行
cd /root/DeskBot_demo
./run.sh
```

### 详细部署指南

详见 [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md)

---

## 项目结构

```
Echo-Mate/
├── Demo/                       # Demo 应用程序
│   ├── DeskBot_demo/           # 主程序：AI 桌面机器人（所有功能集合）
│   ├── AIChat_demo/            # AI 语音助手（客户端/服务端架构）
│   ├── yolov5_demo/            # YOLOv5 物体检测
│   └── rkmpi_demos/            # RKMPI 多媒体 demo（RTSP、相机等）
│
├── SDK/                        # SDK 文件夹
│   ├── rv1106-sdk/             # 基于 Luckfox 修改的 SDK
│   └── README.md               # SDK 使用和开发板说明
│
├── docs/                       # 文档
│   ├── DEPLOYMENT.md           # 部署指南
│   ├── DEVELOPMENT.md          # 开发指南
│   └── FAQ.md                  # 常见问题
│
├── output/                     # 编译输出（可部署包）
│   └── aarch64/                # AArch64 架构输出
│       ├── DeskBot_demo/       # 桌面机器人可部署包
│       ├── AIChat_demo/        # AI 聊天客户端
│       └── yolov5_demo/        # YOLOv5 演示
│
├── assets/                     # 项目图片和文档资源
├── Dockerfile                  # Docker 开发环境
├── docker-compose.yml          # Docker Compose 配置
└── README.md                   # 本文件
```

---

## 技术栈

### 硬件平台
- **SoC:** Rockchip RV1106 (ARM Cortex-A7)
- **交叉编译器:** arm-rockchip830-linux-uclibcgnueabihf-gcc/g++

### 软件架构

| 组件 | 技术 |
|------|------|
| UI 框架 | LVGL v9.2.2 |
| 语言 | C (C99) / C++ (C17) |
| 构建系统 | CMake (>= 3.10) |
| 显示后端 | SDL2 (模拟器) / Linux FBDev (硬件) / DRM |
| 输入 | evdev (触摸屏) / SDL 鼠标 (模拟器) |
| 音频 | PortAudio + Opus |
| 网络 | WebSocket++ |
| AI 推理 | RKNN Runtime |

---

## 文档索引

| 文档 | 说明 |
|------|------|
| [SDK/README.md](./SDK/README.md) | SDK 编译和烧录指南 |
| [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) | 部署到开发板详细指南 |
| [docs/DEVELOPMENT.md](./docs/DEVELOPMENT.md) | 开发指南和调试技巧 |
| [docs/FAQ.md](./docs/FAQ.md) | 常见问题解答 |
| [AGENTS.md](./AGENTS.md) | AI Agent 开发指南（详细技术文档） |

---

## 许可证

详见 [LICENSE](./LICENSE) 文件。

---

## 致谢

- [Luckfox](https://wiki.luckfox.com/) - 提供 RV1106 SDK 基础
- [LVGL](https://lvgl.io/) - 优秀的嵌入式图形库
- [Rockchip](https://www.rock-chips.com/) - RV1106 芯片

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/No-Chicken">No-Chicken</a>
</p>
