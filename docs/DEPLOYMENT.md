# 📦 Echo-Mate 部署指南

本文档详细介绍如何将 Echo-Mate 部署到 RV1106 开发板。

## 📋 目录

- [快速部署](#快速部署)
- [部署前准备](#部署前准备)
- [详细部署步骤](#详细部署步骤)
- [不同场景部署](#不同场景部署)
- [故障排除](#故障排除)
- [性能优化](#性能优化)

---

## 🚀 快速部署

如果你已经编译好了 AArch64 版本，只需 3 步：

```bash
# 1. 拷贝到开发板（替换为你的开发板 IP）
scp -r output/aarch64/DeskBot_demo root@172.32.0.93:/root/

# 2. SSH 登录开发板
ssh root@172.32.0.93

# 3. 运行程序
cd /root/DeskBot_demo
./run.sh
```

---

## 📋 部署前准备

### 开发板要求

| 项目 | 要求 |
|:-----|:-----|
| **芯片** | RV1106 (ARM Cortex-A7) |
| **系统** | Linux (Buildroot / Debian / Ubuntu) |
| **架构** | armhf (32位) 或 aarch64 (64位) |
| **存储** | 至少 100MB 可用空间 |
| **网络** | 已配置网络连接（用于 AI 功能） |

### 检查开发板架构

在开发板上执行：

```bash
uname -m

# 输出说明:
# aarch64  → 64位 ARM，使用 output/aarch64/
# armv7l   → 32位 ARM，需要重新编译
```

### 检查系统环境

```bash
# 检查 Linux 版本
cat /etc/os-release

# 检查是否有图形界面（建议关闭以节省资源）
ps aux | grep -E "Xorg|wayland"

# 检查网络
ping -c 3 www.baidu.com
```

---

## 📖 详细部署步骤

### 步骤 1：获取可执行文件

#### 方式 A：使用预编译版本（推荐）

项目 `output/aarch64/` 目录包含已编译好的版本：

```
output/aarch64/
├── DeskBot_demo/          # 桌面机器人主程序 ⭐ 推荐
├── AIChat_demo/           # AI 语音助手客户端
└── yolov5_demo/           # YOLOv5 物体检测
```

#### 方式 B：自行编译

详见 [DEVELOPMENT.md](./DEVELOPMENT.md)

---

### 步骤 2：复制到开发板

#### 使用 SCP 复制

```bash
# 复制 DeskBot_demo 到开发板
scp -r output/aarch64/DeskBot_demo root@开发板IP:/root/

# 或者复制所有 demo
scp -r output/aarch64/* root@开发板IP:/root/
```

#### 使用 USB 存储设备

```bash
# 1. 将 output/aarch64/DeskBot_demo 复制到 U 盘
# 2. 将 U 盘插入开发板
# 3. 在开发板上挂载并复制
mkdir -p /mnt/usb
mount /dev/sda1 /mnt/usb
cp -r /mnt/usb/DeskBot_demo /root/
umount /mnt/usb
```

---

### 步骤 3：安装系统依赖

SSH 登录到开发板：

```bash
ssh root@开发板IP
```

#### 必需依赖

```bash
# 更新软件源
apt-get update

# 安装 libcurl（必须，用于网络请求）
apt-get install -y libcurl4
```

#### 可选依赖（根据功能需要）

```bash
# 音频支持（如果需要 AI 语音功能）
apt-get install -y libasound2 alsa-utils

# 其他常用工具
apt-get install -y vim htop
```

---

### 步骤 4：配置系统

#### 配置 Wi-Fi（可选，AI 功能需要网络）

```bash
# 创建 Wi-Fi 配置
wpa_passphrase "你的WiFi名称" "WiFi密码" > /etc/wpa_supplicant.conf

# 连接 Wi-Fi
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlan0
udhcpc -i wlan0

# 测试网络
ping www.baidu.com
```

#### 修改应用配置

```bash
vi /root/DeskBot_demo/bin/system_para.conf
```

关键配置项：

```ini
# 位置信息（用于天气功能）
city=北京市
adcode=110000
gaode_api_key=你的高德地图API密钥

# AI 聊天服务器配置
AIChat_server_url=你的服务器IP
AIChat_server_port=8000
AIChat_server_token=123456

# 阿里云 API 密钥（用于语音合成）
aliyun_api_key=你的阿里云API密钥
```

---

### 步骤 5：运行程序

```bash
cd /root/DeskBot_demo

# 方式 1：使用启动脚本（推荐）
./run.sh

# 方式 2：手动运行（需要设置库路径）
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
./bin/main
```

---

## 🎯 不同场景部署

### 场景 1：最小化部署（仅运行 DeskBot）

```bash
# 只复制必要文件
scp -r output/aarch64/DeskBot_demo/bin root@开发板IP:/root/DeskBot_demo/
scp output/aarch64/DeskBot_demo/run.sh root@开发板IP:/root/DeskBot_demo/

# 在开发板上安装最小依赖
apt-get update
apt-get install -y libcurl4

# 运行
cd /root/DeskBot_demo && ./run.sh
```

### 场景 2：完整部署（包含所有功能）

```bash
# 复制完整目录
scp -r output/aarch64/DeskBot_demo root@开发板IP:/root/

# 安装完整依赖
apt-get update
apt-get install -y libcurl4 libasound2 alsa-utils

# 配置音频
amixer set Speaker 100%  # 设置音量

# 运行
cd /root/DeskBot_demo && ./run.sh
```

### 场景 3：多 demo 部署

```bash
# 复制所有 demo
scp -r output/aarch64/* root@开发板IP:/root/

# 目录结构
/root/
├── DeskBot_demo/      # 主程序
├── AIChat_demo/       # AI 语音助手
└── yolov5_demo/       # YOLO 物体检测
```

---

## 🔧 故障排除

### 问题 1：程序无法启动，提示找不到库

**症状：**
```
error while loading shared libraries: libxxx.so.x: cannot open shared object file
```

**诊断：**
```bash
cd /root/DeskBot_demo
ldd ./bin/main | grep "not found"
```

**解决：**
```bash
# 安装缺失的系统库
apt-get install -y <库名>

# 或者从其他设备复制库文件
cp /usr/lib/aarch64-linux-gnu/libxxx.so.x ./lib/
```

---

### 问题 2：libcurl 相关错误

**症状：**
```
libcurl.so.4: version `CURL_OPENSSL_4' not found
```

**解决：**
```bash
# 安装 libcurl4
apt-get update
apt-get install -y libcurl4

# 如果仍有问题，run.sh 会自动处理 libcurl 冲突
./run.sh
```

---

### 问题 3：权限不足

**症状：**
```
Permission denied
```

**解决：**
```bash
chmod +x /root/DeskBot_demo/bin/main
chmod +x /root/DeskBot_demo/run.sh
```

---

### 问题 4：屏幕无显示（黑屏）

**排查步骤：**

```bash
# 1. 检查帧缓冲设备
ls -la /dev/fb*

# 2. 检查设备树配置
cat /sys/class/graphics/fb0/name

# 3. 测试帧缓冲
cat /dev/urandom > /dev/fb0  # 应该显示雪花

# 4. 检查程序配置
grep LV_USE_SIMULATOR /root/DeskBot_demo/conf/dev_conf.h
# 应该为 #define LV_USE_SIMULATOR 0（硬件模式）

# 5. 检查日志
dmesg | grep -i "fb\|drm\|lcd"
```

**常见原因和解决：**

| 原因 | 解决 |
|:-----|:-----|
| 配置为模拟器模式 | 修改 `conf/dev_conf.h`: `#define LV_USE_SIMULATOR 0` |
| 帧缓冲设备权限不足 | `chmod 666 /dev/fb0` |
| 屏幕驱动未加载 | 检查设备树配置 |
| 其他进程占用屏幕 | `killall` 其他图形程序 |

---

### 问题 5：触摸无响应

**排查步骤：**
```bash
# 1. 检查触摸设备
ls -la /dev/input/event*

# 2. 查看输入设备信息
cat /proc/bus/input/devices

# 3. 测试触摸事件
cat /dev/input/event0 | xxd  # 触摸屏幕看是否有数据输出

# 4. 检查权限
chmod 666 /dev/input/event0
```

---

### 问题 6：程序启动后立即退出

**排查：**
```bash
# 查看详细错误
./run.sh 2>&1 | tee error.log

# 检查配置文件
ls -la bin/system_para.conf

# 检查资源文件
ls -la bin/third_party/snowboy/resources/
```

---

## ⚡ 性能优化

### 启动速度优化

```bash
# 禁用不必要的服务
systemctl disable <服务名>

# 使用精简的 rootfs
# 参考 SDK 的 minimal 配置
```

### 内存优化

```bash
# 查看内存使用
free -h

# 关闭不需要的功能模块
# 编辑 system_para.conf 禁用某些功能
```

### 显示优化

```bash
# 降低刷新率（如果画面撕裂）
# 在代码中设置:
lv_display_set_refresh_rate(disp, 30);  // 30fps

# 使用局部刷新模式（如果内存紧张）
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_PARTIAL
```

---

## 🔄 开机自启动

### 方法一：使用 init.d

```bash
# 创建启动脚本
cat > /etc/init.d/S99deskbot << 'EOF'
#!/bin/sh
case "$1" in
  start)
    echo "Starting DeskBot..."
    cd /root/DeskBot_demo && ./run.sh &
    ;;
  stop)
    echo "Stopping DeskBot..."
    killall main
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
exit 0
EOF

chmod +x /etc/init.d/S99deskbot
```

### 方法二：使用 systemd（如果系统支持）

```bash
cat > /etc/systemd/system/deskbot.service << 'EOF'
[Unit]
Description=Echo-Mate DeskBot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/DeskBot_demo
ExecStart=/root/DeskBot_demo/run.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl enable deskbot
systemctl start deskbot
```

---

## 📁 目录结构说明

部署后的完整目录结构：

```
DeskBot_demo/
├── run.sh              # 智能启动脚本 ⭐ 推荐运行方式
└── bin/                # 程序目录
    ├── main            # 主程序可执行文件 (ARM AArch64)
    ├── lib/            # 依赖库
    │   ├── libjsoncpp.so.25    # JSON 解析
    │   ├── libopus.so.0        # 音频编解码
    │   ├── libportaudio.so.2   # 音频采集/播放
    │   ├── libopenblas.so.0    # 矩阵运算
    │   ├── libasound.so.2      # ALSA 音频
    │   ├── libjson-c.so.4      # JSON-C 解析
    │   ├── libcurl.so.4        # HTTP 请求
    │   ├── librknnrt.so        # RKNN NPU 运行时
    │   └── librga.so           # RGA 图像处理
    ├── model/          # YOLO 模型文件
    │   ├── yolov5.rknn
    │   ├── coco_80_labels_list.txt
    │   └── bus.jpg
    ├── third_party/    # 第三方资源
    │   ├── snowboy/    # 唤醒词
    │   │   ├── resources/
    │   │   │   ├── common.res
    │   │   │   └── models/
    │   │   │       └── echo.pmdl
    │   └── audio/      # 音频资源
    │       └── waked.pcm
    ├── system_para.conf    # 系统配置 ⚠️ 需要修改
    ├── gaode_adcode.json   # 城市代码表
    └── cacert.pem          # SSL 证书
```

---

## 📞 获取帮助

如果遇到问题：

1. 查看 [FAQ.md](./FAQ.md) 常见问题解答
2. 查看 [DEVELOPMENT.md](./DEVELOPMENT.md) 开发调试指南
3. 提交 Issue：https://github.com/No-Chicken/Echo-Mate/issues

---

## 📚 相关文档

- [DEVELOPMENT.md](./DEVELOPMENT.md) - 开发指南
- [FAQ.md](./FAQ.md) - 常见问题
- [SDK/README.md](../SDK/README.md) - SDK 编译指南
