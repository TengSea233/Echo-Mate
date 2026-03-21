# 🔨 Echo-Mate 开发指南

本文档介绍如何开发和调试 Echo-Mate 项目。

## 📋 目录

- [开发环境搭建](#开发环境搭建)
- [编译方式](#编译方式)
- [代码结构](#代码结构)
- [调试技巧](#调试技巧)
- [添加新功能](#添加新功能)
- [性能优化](#性能优化)

---

## 🖥️ 开发环境搭建

### 方式一：本地开发（PC 模拟器）

适合 UI 开发和业务逻辑调试，无需硬件。

```bash
# 安装基础依赖
sudo apt-get update
sudo apt-get install -y \
    git cmake build-essential \
    pkg-config

# 安装 SDL2（用于 PC 模拟器）
sudo apt-get install -y \
    libsdl2-dev libsdl2-image-dev \
    libdrm-dev

# 安装 AIChat 依赖（可选）
sudo apt-get install -y \
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
# 1. 安装 VS Code 插件：Remote - Containers
# 2. 按 F1 → "Remote-Containers: Open Folder in Container"
# 3. 选择 Echo-Mate 目录
# 4. 在容器内直接开发调试
```

---

## 🔧 编译方式

### PC 模拟器编译（快速测试）

```bash
cd Demo/DeskBot_demo

# 确保配置为模拟器模式
cat conf/dev.conf.h | grep LV_USE_SIMULATOR
# 应该显示: #define LV_USE_SIMULATOR 1

# 创建构建目录
mkdir -p build && cd build

# 配置和编译
cmake ..
make -j$(nproc)

# 运行
../bin/main
```

**调整窗口大小：**
```bash
# 设置环境变量
export LV_SDL_VIDEO_WIDTH=640
export LV_SDL_VIDEO_HEIGHT=480
../bin/main
```

---

### 交叉编译（用于部署到开发板）

#### 32 位 ARM (armhf) - RV1106 标准配置

```bash
cd Demo/DeskBot_demo

# 清理之前的编译
rm -rf build bin

# 创建构建目录
mkdir build && cd build

# 配置交叉编译
cmake .. \
    -DTARGET_ARM=ON \
    -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake

# 编译
make -j$(nproc)

# 检查生成的文件
file ../bin/main
# 应该显示: ELF 32-bit LSB executable, ARM, EABI5
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

file ../bin/main
# 应该显示: ELF 64-bit LSB executable, ARM aarch64
```

---

### 一键编译脚本

```bash
# 编译所有 demo 并整理输出
./build_aarch64_complete.sh

# 输出目录：output/aarch64/
# 包含：DeskBot_demo, AIChat_demo, yolov5_demo
```

---

## 📁 代码结构

### DeskBot_demo 目录结构

```
DeskBot_demo/
├── main.c                  # 程序入口
├── lv_conf.h              # LVGL 配置
├── conf/
│   ├── dev_conf.h         # 设备配置（模拟器/硬件切换）
│   └── version.h          # 版本信息
├── lvgl/                  # LVGL 库（子模块）
├── gui_app/               # UI 应用层
│   ├── ui.c/h             # 主 UI 初始化
│   ├── pages/             # UI 页面（每个页面一个"app"）
│   │   ├── ui_HomePage/   # 首页
│   │   ├── ui_ChatBotPage/    # AI 聊天 ⭐
│   │   ├── ui_WeatherPage/    # 天气
│   │   ├── ui_YOLOPage/       # AI 相机 ⭐
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
│       ├── animation/     # 动画库
│       ├── page_manager/  # 页面管理器
│       └── stack/         # 栈实现
├── common/                # 硬件抽象层
│   ├── sys_manager/       # 系统管理（WiFi、背光等）
│   ├── gpio_manager/      # GPIO 控制
│   └── event_manager/     # 事件处理
└── utils/                 # 工具函数
```

### 关键配置文件

| 文件 | 说明 | 常用修改 |
|:-----|:-----|:---------|
| `conf/dev_conf.h` | 设备模式配置 | `LV_USE_SIMULATOR` 0/1 |
| `lv_conf.h` | LVGL 配置 | 内存大小、功能开关 |
| `utils/system_para.conf` | 运行时参数 | API 密钥、网络配置 |

---

## 🐛 调试技巧

### PC 端调试

```bash
# 使用 GDB 调试
gdb ./bin/main
(gdb) run
(gdb) bt          # 查看调用栈
(gdb) break main  # 设置断点

# 使用 Valgrind 检查内存泄漏
valgrind --leak-check=full ./bin/main

# 使用 AddressSanitizer 检测内存错误
cmake .. -DCMAKE_C_FLAGS="-fsanitize=address -g"
make
./bin/main
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
(gdb) continue
```

### 日志调试

```bash
# 程序日志输出到控制台
./run.sh 2>&1 | tee deskbot.log

# 查看系统日志
dmesg | tail -50

# 查看 LVGL 日志
# 在 lv_conf.h 中设置：
#define LV_USE_LOG 1
#define LV_LOG_LEVEL LV_LOG_LEVEL_INFO
```

### 性能分析

```bash
# 使用 perf 分析性能
perf record ./bin/main
perf report

# 查看 CPU 使用率
top -p $(pidof main)

# 查看内存使用
pmap $(pidof main)
```

---

## ➕ 添加新功能

### 添加新页面

```bash
# 1. 复制模板
cd gui_app/pages
cp -r ui_template ui_MyNewPage

# 2. 重命名文件
mv ui_MyNewPage/ui_templatePage.c ui_MyNewPage/ui_MyNewPage.c
mv ui_MyNewPage/ui_templatePage.h ui_MyNewPage/ui_MyNewPage.h

# 3. 修改文件内容
# 替换所有 ui_template 为 ui_MyNewPage
# 替换所有 UI_TEMPLATE 为 UI_MYNEWPAGE

# 4. 修改 gui_app/CMakeLists.txt
# 添加新的源文件

# 5. 在 ui.c 中添加页面初始化
#include "pages/ui_MyNewPage/ui_MyNewPage.h"
// 在 ui_init() 中调用 ui_MyNewPage_init()
```

### 页面代码模板

```c
// ui_MyNewPage.h
#ifndef UI_MYNEWPAGE_H
#define UI_MYNEWPAGE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "../../ui.h"

void ui_MyNewPage_init(void);
void ui_MyNewPage_deinit(void);

#ifdef __cplusplus
}
#endif

#endif
```

```c
// ui_MyNewPage.c
#include "ui_MyNewPage.h"

// 页面参数
static lv_obj_t * ui_MyNewPage;

// 事件处理函数
static void ui_event_MyNewPage(lv_event_t * e)
{
    lv_event_code_t event_code = lv_event_get_code(e);
    lv_obj_t * target = lv_event_get_target(e);
    
    if(event_code == LV_EVENT_CLICKED) {
        // 处理点击事件
        LV_LOG_USER("Button clicked!");
    }
}

void ui_MyNewPage_init(void)
{
    // 创建页面
    ui_MyNewPage = lv_obj_create(NULL);
    
    // 添加标题
    lv_obj_t * label = lv_label_create(ui_MyNewPage);
    lv_label_set_text(label, "My New Page");
    lv_obj_set_style_text_font(label, &lv_font_montserrat_24, 0);
    lv_obj_align(label, LV_ALIGN_TOP_MID, 0, 20);
    
    // 添加按钮
    lv_obj_t * btn = lv_btn_create(ui_MyNewPage);
    lv_obj_set_size(btn, 120, 50);
    lv_obj_center(btn);
    lv_obj_add_event_cb(btn, ui_event_MyNewPage, LV_EVENT_ALL, NULL);
    
    lv_obj_t * btn_label = lv_label_create(btn);
    lv_label_set_text(btn_label, "Click Me");
    lv_obj_center(btn_label);
    
    // 加载页面
    lv_scr_load(ui_MyNewPage);
}

void ui_MyNewPage_deinit(void)
{
    // 清理资源
}
```

---

## 🎨 显示驱动配置

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
|:-----|:---------|:-----|
| SDL2 | PC 模拟器 | `LV_USE_SDL = 1` |
| Linux FBDev | SPI/RGB 屏幕 | `LV_USE_LINUX_FBDEV = 1` |
| Linux DRM | MIPI DSI 屏幕 | `LV_USE_LINUX_DRM = 1` |

### 双缓冲配置

```c
// lv_conf.h

// FBDev 双缓冲（硬件模式）
#define LV_LINUX_FBDEV_BUFFER_COUNT  2
#define LV_LINUX_FBDEV_RENDER_MODE   LV_DISPLAY_RENDER_MODE_FULL

// SDL 双缓冲（模拟器模式）
#define LV_SDL_BUF_COUNT  2
```

---

## ⚡ 性能优化

### 内存优化

```c
// lv_conf.h

// 减少 LVGL 内存池
#define LV_MEM_SIZE (256 * 1024)  // 256KB

// 禁用不需要的功能
#define LV_USE_ANIMATION  0  // 禁用动画
#define LV_USE_SHADOW     0  // 禁用阴影
#define LV_USE_GPU        0  // 禁用 GPU（如果没有）
```

### 绘制优化

```c
// 局部刷新模式（内存受限时）
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_PARTIAL

// 完整刷新模式（性能更好，需要更多内存）
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_FULL
```

### 编译优化

```bash
# 使用 O2 优化
cmake .. -DCMAKE_BUILD_TYPE=Release

# 或使用 O3 优化（可能增加体积）
cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O3 -march=armv7-a"
```

---

## 📝 代码规范

### 命名规范

| 类型 | 规范 | 示例 |
|:-----|:-----|:-----|
| 函数 | 小写 + 下划线 | `ui_home_page_init()` |
| 变量 | 小写 + 下划线 | `screen_width` |
| 宏 | 大写 + 下划线 | `MAX_BUFFER_SIZE` |
| 类型 | 小写 + _t | `lv_obj_t` |

### 注释规范

```c
/**
 * @brief 初始化首页
 * @param param 参数说明
 * @return 返回值说明
 */
void ui_HomePage_init(int param);

// 单行注释
int count = 0;  // 计数器
```

---

## 📚 相关文档

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
- [FAQ.md](./FAQ.md) - 常见问题
- [LVGL 官方文档](https://docs.lvgl.io/)
- [SDK/README.md](../SDK/README.md) - SDK 文档
