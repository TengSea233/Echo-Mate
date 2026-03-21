<h1 align="center">🤖 Echo-Mate</h1>

<p align="center">
  <b>基于 RV1106 的 AI 桌面机器人</b><br>
  <sub>开源硬件 · 开源软件 · 你的智能桌面伙伴</sub>
</p>

<p align="center">
  <a href="https://oshwhub.com/no_chicken/ai-desktop-robot-echo">
    <img src="https://img.shields.io/badge/硬件开源-OSHWHUB-orange?style=flat-square&logo=opensourceinitiative" alt="硬件开源">
  </a>
  <a href="https://www.bilibili.com/video/BV161ZaYyEmF/">
    <img src="https://img.shields.io/badge/演示视频-Bilibili-00A1D6?style=flat-square&logo=bilibili" alt="演示视频">
  </a>
  <a href="https://no-chicken.com/">
    <img src="https://img.shields.io/badge/官方文档-no--chicken.com-blue?style=flat-square&logo=wordpress" alt="官方文档">
  </a>
  <img src="https://img.shields.io/badge/芯片-RV1106-green?style=flat-square" alt="RV1106">
  <img src="https://img.shields.io/badge/LVGL-v9.2.2-ff69b4?style=flat-square" alt="LVGL">
</p>

<p align="center">
  <img border="1px" width="70%" src="./assets/main_pic.jpeg" alt="Echo-Mate 实物图">
</p>

---

## 📋 项目简介

**Echo-Mate** 是一个功能丰富的桌面机器人项目，基于 **Rockchip RV1106** 芯片设计。它集成了 AI 语音助手、智能相机、天气显示、游戏娱乐等多种功能，采用 **LVGL v9.2.2** 构建交互界面，配备 1.28 寸圆形触摸屏，是一个兼具实用性和可玩性的 Linux 桌面助手。

### ✨ 核心功能

| 功能 | 说明 |
|------|------|
| 🤖 **AI 语音对话** | 基于通义千问大模型，支持自然语言交互 |
| 📷 **AI 智能相机** | YOLOv5 物体检测，实时识别画面中的物体 |
| 🌤️ **天气显示** | 实时获取当地天气信息，精美动画展示 |
| 🎮 **游戏中心** | 2048、记忆游戏、电子木鱼等多款小游戏 |
| 🌍 **多语言翻译** | 支持多种语言互译 |
| 🎨 **创意画板** | 支持手绘和保存作品 |
| 🧮 **科学计算器** | 支持复杂表达式计算 |
| 📅 **日历查看** | 农历公历双显示 |

---

## 🖥️ 硬件规格

| 参数 | 规格 |
|:------|:-----|
| **芯片** | RV1106 (Rockchip) |
| **处理器** | 单核 Cortex A7 @ 1.2GHz |
| **NPU** | 1 TOPS，支持 int4/int8/int16 |
| **内存** | 256MB DDR3L |
| **存储** | SD 卡 / NAND FLASH |
| **Wi-Fi + 蓝牙** | RTL8723bs |
| **屏幕** | 1.28 寸圆形 LCD (P024C128-CTP) |
| **分辨率** | 240 × 240 像素 |
| **屏幕接口** | SPI 显示 + I2C 触摸 |
| **音频** | 喇叭 + 麦克风 (MX1.25mm 接口) |
| **扩展接口** | 8 个 GPIO 引出排针 |
| **供电** | USB Type-C 5V |

### 📐 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      Echo-Mate 系统架构                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   AI 语音    │    │   AI 相机    │    │   天气/游戏  │     │
│  │   助手      │    │   YOLOv5    │    │   娱乐中心   │     │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘     │
│         │                  │                  │            │
│         └──────────────────┼──────────────────┘            │
│                            ▼                               │
│                   ┌─────────────────┐                      │
│                   │   LVGL v9.2.2   │                      │
│                   │   图形界面引擎   │                      │
│                   └────────┬────────┘                      │
│                            │                               │
│         ┌──────────────────┼──────────────────┐            │
│         ▼                  ▼                  ▼            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Linux 系统  │    │  显示驱动    │    │  输入驱动    │     │
│  │  Buildroot  │    │  FBDev/DRM  │    │  evdev/I2C  │     │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘     │
│         │                  │                  │            │
│         └──────────────────┼──────────────────┘            │
│                            ▼                               │
│                   ┌─────────────────┐                      │
│                   │    RV1106 SoC   │                      │
│                   │  Cortex-A7 + NPU │                      │
│                   └─────────────────┘                      │
│                            │                               │
│         ┌──────────────────┼──────────────────┐            │
│         ▼                  ▼                  ▼            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  1.28" 圆屏  │    │   触摸屏     │    │  WiFi/BT    │     │
│  │  240×240   │    │   I2C       │    │  RTL8723    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 快速开始

### 1️⃣ 克隆仓库

```bash
git clone https://github.com/No-Chicken/Echo-Mate.git
cd Echo-Mate

# 初始化子模块
git submodule update --init --recursive

# 拉取 LFS 大文件（模型、资源等）
git lfs pull
git submodule foreach --recursive 'git lfs pull'
```

### 2️⃣ 选择开发方式

#### 🖥️ 方式 A：PC 模拟器（推荐用于 UI 开发）

```bash
# 安装 SDL2 依赖
sudo apt-get install libsdl2-dev libsdl2-image-dev libdrm-dev

# 编译运行
cd Demo/DeskBot_demo
mkdir build && cd build
cmake ..
make -j$(nproc)
../bin/main
```

#### 🐳 方式 B：Docker 交叉编译（推荐用于部署）

```bash
# 启动 Docker 环境
docker-compose up -d
docker exec -it echo-mate /bin/bash

# 一键编译所有 demo
./build_aarch64_complete.sh
```

#### 🔧 方式 C：SDK 固件编译

详见 [SDK/README.md](./SDK/README.md)

### 3️⃣ 部署到开发板

```bash
# 拷贝编译好的程序到开发板
scp -r output/aarch64/DeskBot_demo root@172.32.0.93:/root/

# SSH 登录并运行
ssh root@172.32.0.93
cd /root/DeskBot_demo
./run.sh
```

---

## 📁 项目结构

```
Echo-Mate/
├── 📂 Demo/                    # Demo 应用程序
│   ├── 🎯 DeskBot_demo/        # 主程序：AI 桌面机器人（全功能）
│   ├── 💬 AIChat_demo/         # AI 语音助手（Client/Server）
│   ├── 📷 yolov5_demo/         # YOLOv5 物体检测
│   └── 🎬 rkmpi_demos/         # RKMPI 多媒体 demo
│
├── 📂 SDK/                     # SDK 文件夹
│   ├── 🔧 rv1106-sdk/          # 基于 Luckfox 修改的 SDK
│   └── 📖 README.md            # SDK 编译和烧录指南
│
├── 📂 docs/                    # 项目文档
│   ├── 📖 DEPLOYMENT.md        # 部署指南
│   ├── 🔨 DEVELOPMENT.md       # 开发指南
│   └── ❓ FAQ.md               # 常见问题
│
├── 📂 output/                  # 编译输出（可部署包）
│   └── aarch64/                # AArch64 架构输出
│       ├── DeskBot_demo/       # 桌面机器人可部署包
│       ├── AIChat_demo/        # AI 聊天客户端
│       └── yolov5_demo/        # YOLOv5 演示
│
├── 📂 assets/                  # 项目图片和文档资源
├── 🐳 Dockerfile               # Docker 开发环境
├── 🐳 docker-compose.yml       # Docker Compose 配置
├── 🤖 AGENTS.md                # AI Agent 开发指南
└── 📖 README.md                # 本文件
```

---

## 🛠️ 技术栈

### 硬件平台
- **SoC:** Rockchip RV1106 (ARM Cortex-A7 @ 1.2GHz)
- **NPU:** 1 TOPS 算力，支持 int4/int8/int16
- **交叉编译:** arm-rockchip830-linux-uclibcgnueabihf-gcc/g++

### 软件架构

| 层级 | 技术 | 说明 |
|:------|:-----|:-----|
| **应用层** | DeskBot / AIChat / YOLO | 业务功能实现 |
| **UI 层** | LVGL v9.2.2 | 图形界面引擎 |
| **中间件** | WebSocket++ / Opus / RKNN | 通信、音频、AI 推理 |
| **系统层** | Linux (Buildroot) | 嵌入式操作系统 |
| **驱动层** | FBDev / DRM / evdev | 显示和输入驱动 |
| **硬件层** | RV1106 SoC | 主控芯片 |

### 显示驱动支持

| 驱动类型 | 适用场景 | 状态 |
|:---------|:---------|:-----|
| SDL2 | PC 模拟器开发 | ✅ 支持 |
| Linux FBDev | SPI/RGB 屏幕 | ✅ 支持 |
| Linux DRM | MIPI DSI 屏幕 | ✅ 支持 |

---

## 📚 文档索引

| 文档 | 说明 | 目标读者 |
|:-----|:-----|:---------|
| [📖 README.md](./README.md) | 项目介绍和快速开始 | 所有用户 |
| [📖 docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) | 部署到开发板详细指南 | 部署用户 |
| [🔨 docs/DEVELOPMENT.md](./docs/DEVELOPMENT.md) | 开发指南和调试技巧 | 开发者 |
| [❓ docs/FAQ.md](./docs/FAQ.md) | 常见问题解答 | 所有用户 |
| [🤖 AGENTS.md](./AGENTS.md) | AI Agent 详细技术文档 | 开发者 |
| [🔧 SDK/README.md](./SDK/README.md) | SDK 编译和烧录指南 | 固件开发者 |

---

## 🖼️ 功能展示

### 界面预览

<p align="center">
  <img border="1px" width="100%" src="./assets/show.png" alt="功能展示">
</p>

### 功能地图

<p align="center">
  <img border="1px" width="75%" src="./assets/func_map.png" alt="功能地图">
</p>

### 开发板细节

<p align="center">
  <img border="1px" width="75%" src="./assets/board_detail.png" alt="开发板细节">
</p>

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

---

## 📄 许可证

本项目采用开源许可证，详见 [LICENSE](./LICENSE) 文件。

硬件设计开源地址：https://oshwhub.com/no_chicken/ai-desktop-robot-echo

---

## 🙏 致谢

- [Luckfox](https://wiki.luckfox.com/) - 提供 RV1106 SDK 基础
- [LVGL](https://lvgl.io/) - 优秀的嵌入式图形库
- [Rockchip](https://www.rock-chips.com/) - RV1106 芯片

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/No-Chicken">No-Chicken</a>
</p>

<p align="center">
  <sub>如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！</sub>
</p>
