# Echo-Mate 开发指南

本文档介绍如何开发和调试 Echo-Mate 项目。

## 目录

- [开发环境搭建](#开发环境搭建)
- [编译方式](#编译方式)
- [调试技巧](#调试技巧)
- [代码结构](#代码结构)
- [添加新功能](#添加新功能)

---

## 开发环境搭建

### 方式一：本地开发（PC 模拟器）

适合 UI 开发和逻辑调试，无需硬件。

```bash
# 安装依赖
sudo apt-get update
sudo apt-get install -y \
    git cmake build-essential \
    libsdl2-dev libsdl2-image-dev \
    libdrm-dev \
    libjsoncpp-dev libopus-dev \
    libasound-dev libportaudio2 \
    libboost-dev libwebsocketpp-dev

# 克隆仓库
git clone https://github.com/No-Chicken/Echo-Mate.git
cd Echo-Mate
git submodule update --init --recursive
```

### 方式二：Docker 开发（推荐用于交叉编译）

```bash
# 启动 Docker 环境
docker-compose up -d
docker exec -it echo-mate /bin/bash

# 在容器内开发
cd /project/Demo/DeskBot_demo
```

### 方式三：VS Code 远程开发

```bash
# 安装 VS Code 插件：Remote - Containers
# 按 F1 → "Remote-Containers: Open Folder in Container"
# 选择 Echo-Mate 目录
```

---

## 编译方式

### PC 模拟器编译（快速测试）

```bash
cd Demo/DeskBot_demo

# 确保配置为模拟器模式
# conf/dev_conf.h: #define LV_USE_SIMULATOR 1

mkdir -p build && cd build
cmake ..
make -j$(nproc)

# 运行
../bin/main
```

### 交叉编译（用于部署到开发板）

#### 32 位 ARM (armhf)

```bash
cd Demo/DeskBot_demo
rm -rf build bin
mkdir build && cd build

cmake .. \
    -DTARGET_ARM=ON \
    -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake

make -j$(nproc)
```

#### 64 位 ARM (AArch64)

```bash
cd Demo/DeskBot_demo
rm -rf build bin
mkdir build && cd build

cmake .. \
    -DTARGET_AARCH64=ON \
    -DCMAKE_TOOLCHAIN_FILE=../toolchain-aarch64.cmake

make -j$(nproc)
```

### 一键编译脚本

```bash
# 编译所有 demo 并整理输出
./build_aarch64_complete.sh

# 输出目录：output/aarch64/
```

---

## 调试技巧

### PC 端调试

```bash
# 使用 GDB 调试
gdb ./bin/main

# 使用 Valgrind 检查内存泄漏
valgrind --leak-check=full ./bin/main
```

### 开发板端调试

```bash
# 1. 复制调试版本到开发板
scp -r output/aarch64/DeskBot_demo root@开发板IP:/root/

# 2. SSH 登录
ssh root@开发板IP

# 3. 使用 GDBServer 远程调试
# 开发板上：
gdbserver :1234 ./bin/main

# PC 上：
aarch64-linux-gnu-gdb ./bin/main
(gdb) target remote 开发板IP:1234
```

### 查看日志

```bash
# 程序日志输出到控制台
# 可以在代码中使用 LV_LOG 宏

# 查看系统日志
dmesg | tail -50

# 查看应用程序输出
./run.sh 2>&1 | tee deskbot.log
```

---

## 代码结构

### DeskBot_demo 目录结构

```
DeskBot_demo/
├── main.c                  # 程序入口
├── lv_conf.h              # LVGL 配置
├── conf/
│   ├── dev_conf.h         # 设备配置（模拟器/硬件）
│   └── version.h          # 版本信息
├── lvgl/                  # LVGL 库（子模块）
├── gui_app/               # UI 应用层
│   ├── ui.c/h             # 主 UI 初始化
│   ├── pages/             # UI 页面（每个页面一个"app"）
│   │   ├── ui_HomePage/   # 首页
│   │   ├── ui_ChatBotPage/    # AI 聊天
│   │   ├── ui_WeatherPage/    # 天气
│   │   ├── ui_YOLOPage/       # AI 相机
│   │   ├── ui_CalculatorPage/ # 计算器
│   │   ├── ui_CalendarPage/   # 日历
│   │   ├── ui_DrawPage/       # 画板
│   │   ├── ui_Game2048Page/   # 2048 游戏
│   │   ├── ui_GameMemoryPage/ # 记忆游戏
│   │   ├── ui_GameMuyuPage/   # 木鱼游戏
│   │   ├── ui_SettingPage/    # 设置
│   │   └── ui_template/       # 页面模板
│   ├── fonts/             # 自定义字体
│   ├── images/            # UI 图片资源
│   └── common/            # UI 工具库
├── common/                # 硬件抽象层
│   ├── sys_manager/       # 系统管理（WiFi、背光等）
│   ├── gpio_manager/      # GPIO 控制
│   └── event_manager/     # 事件处理
└── utils/                 # 工具函数
```

### 关键配置文件

| 文件 | 说明 |
|------|------|
| `conf/dev_conf.h` | 设备模式配置（模拟器/硬件） |
| `lv_conf.h` | LVGL 图形库配置 |
| `utils/system_para.conf` | 运行时系统参数 |

---

## 添加新功能

### 添加新页面

```bash
# 1. 复制模板
cd gui_app/pages
cp -r ui_template ui_MyNewPage

# 2. 重命名文件
mv ui_MyNewPage/ui_templatePage.c ui_MyNewPage/ui_MyNewPage.c
mv ui_MyNewPage/ui_templatePage.h ui_MyNewPage/ui_MyNewPage.h

# 3. 修改 CMakeLists.txt
gui_app/CMakeLists.txt

# 4. 在 ui.c 中添加页面初始化
```

### 页面模板代码

```c
// ui_MyNewPage.c
#include "ui_MyNewPage.h"

static void ui_event_MyNewPage(lv_event_t * e)
{
    lv_event_code_t event_code = lv_event_get_code(e);
    if(event_code == LV_EVENT_CLICKED) {
        // 处理点击事件
    }
}

void ui_MyNewPage_init(void)
{
    // 创建页面
    lv_obj_t * page = lv_obj_create(NULL);
    
    // 添加 UI 元素
    lv_obj_t * label = lv_label_create(page);
    lv_label_set_text(label, "Hello, Echo-Mate!");
    lv_obj_center(label);
    
    // 加载页面
    lv_scr_load(page);
}
```

---

## 显示驱动配置

### 切换显示后端

编辑 `conf/dev_conf.h`：

```c
// 模拟器模式（PC 开发）
#define LV_USE_SIMULATOR 1
// 自动启用：LV_USE_SDL = 1

// 硬件模式（开发板）
#define LV_USE_SIMULATOR 0
// 自动启用：LV_USE_LINUX_FBDEV = 1, LV_USE_EVDEV = 1
```

### 支持的显示后端

| 后端 | 适用场景 | 配置 |
|------|---------|------|
| SDL2 | PC 模拟器 | `LV_USE_SDL = 1` |
| Linux FBDev | SPI/RGB 屏幕 | `LV_USE_LINUX_FBDEV = 1` |
| Linux DRM | MIPI DSI 屏幕 | `LV_USE_LINUX_DRM = 1` |

---

## 双缓冲配置

LVGL 支持双缓冲技术，可减少画面撕裂：

```c
// lv_conf.h

// FBDev 双缓冲（硬件模式）
#define LV_LINUX_FBDEV_BUFFER_COUNT  2
#define LV_LINUX_FBDEV_RENDER_MODE   LV_DISPLAY_RENDER_MODE_FULL

// SDL 双缓冲（模拟器模式）
#define LV_SDL_BUF_COUNT  2
```

---

## 性能优化

### 内存优化

```c
// lv_conf.h
#define LV_MEM_SIZE (256 * 1024)  // 256KB LVGL 内存池
```

### 绘制优化

```c
// 局部刷新模式（内存受限时）
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_PARTIAL

// 完整刷新模式（性能更好）
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_FULL
```

---

## 相关文档

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
- [FAQ.md](./FAQ.md) - 常见问题
- [LVGL 官方文档](https://docs.lvgl.io/)
