# Echo-Mate 部署指南

本文档介绍如何将 Echo-Mate 部署到 RV1106 开发板。

## 目录

- [快速部署](#快速部署)
- [部署前准备](#部署前准备)
- [详细部署步骤](#详细部署步骤)
- [故障排除](#故障排除)
- [依赖库说明](#依赖库说明)

---

## 快速部署

如果你已经编译好了 AArch64 版本：

```bash
# 1. 拷贝到开发板（替换为你的开发板 IP）
scp -r output/aarch64/DeskBot_demo root@172.32.0.93:/root/

# 2. SSH 登录开发板
ssh root@172.32.0.93

# 3. 运行
cd /root/DeskBot_demo
./run.sh
```

---

## 部署前准备

### 开发板要求

- **芯片**: RV1106 (ARM Cortex-A7)
- **系统**: Linux (Buildroot 或 Debian/Ubuntu)
- **架构**: armhf (32位) 或 aarch64 (64位)
- **网络**: 已配置网络连接（用于 AI 功能）

### 检查开发板架构

```bash
# 在开发板上执行
uname -m

# 输出示例:
# aarch64  → 使用 output/aarch64/
# armv7l   → 需要重新编译 32 位版本
```

---

## 详细部署步骤

### 步骤 1：获取可执行文件

#### 方式 A：使用预编译版本（推荐）

项目 `output/aarch64/` 目录包含已编译好的版本：

```
output/aarch64/
├── DeskBot_demo/          # 桌面机器人主程序
├── AIChat_demo/           # AI 语音助手客户端
└── yolov5_demo/           # YOLOv5 物体检测
```

#### 方式 B：自行编译

详见 [DEVELOPMENT.md](./DEVELOPMENT.md)

---

### 步骤 2：复制到开发板

```bash
# 从宿主机复制 DeskBot_demo 到开发板
scp -r output/aarch64/DeskBot_demo root@开发板IP:/root/

# 或者复制所有 demo
scp -r output/aarch64/* root@开发板IP:/root/
```

---

### 步骤 3：安装系统依赖

SSH 登录到开发板：

```bash
ssh root@开发板IP
```

安装必要的系统库：

```bash
# 更新软件源
apt-get update

# 安装 libcurl（必须）
apt-get install -y libcurl4

# 安装音频支持（可选，如果需要音频功能）
apt-get install -y libasound2 alsa-utils
```

---

### 步骤 4：运行程序

```bash
cd /root/DeskBot_demo

# 方式 1：使用启动脚本（推荐）
./run.sh

# 方式 2：手动运行（需要设置库路径）
export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
./bin/main
```

---

## 目录结构说明

部署后的目录结构：

```
DeskBot_demo/
├── run.sh              # 智能启动脚本
└── bin/                # 程序目录
    ├── main            # 主程序可执行文件
    ├── lib/            # 依赖库
    │   ├── libjsoncpp.so.25
    │   ├── libopus.so.0
    │   ├── libportaudio.so.2
    │   ├── libopenblas.so.0
    │   ├── libasound.so.2
    │   ├── libjson-c.so.4
    │   ├── libcurl.so.4
    │   ├── librknnrt.so
    │   └── librga.so
    ├── model/          # YOLO 模型文件
    │   ├── yolov5.rknn
    │   ├── coco_80_labels_list.txt
    │   └── bus.jpg
    ├── third_party/    # 第三方资源
    │   ├── snowboy/    # 唤醒词
    │   └── audio/      # 音频资源
    ├── system_para.conf    # 系统配置
    ├── gaode_adcode.json   # 城市代码表
    └── cacert.pem          # SSL 证书
```

---

## 故障排除

### 问题 1：程序无法启动，提示找不到库

**症状：**
```
error while loading shared libraries: libxxx.so.x: cannot open shared object file
```

**解决：**
```bash
# 检查缺失的库
cd /root/DeskBot_demo
ldd ./bin/main | grep "not found"

# 安装缺失的系统库
apt-get install -y <库名>

# 或者手动复制库文件到 lib/ 目录
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

# 如果仍有问题，检查启动脚本
# run.sh 会自动处理 libcurl 冲突
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

### 问题 4：屏幕无显示

**症状：**
程序运行但屏幕黑屏

**排查：**
```bash
# 1. 检查帧缓冲设备
ls -la /dev/fb*

# 2. 检查屏幕是否被其他进程占用
ps | grep -E "lvgl|fb"

# 3. 检查配置是否正确
# conf/dev_conf.h 应该设置为硬件模式：
# #define LV_USE_SIMULATOR 0
```

---

### 问题 5：触摸无响应

**症状：**
显示正常但触摸无效

**排查：**
```bash
# 检查触摸设备
ls -la /dev/input/event*
cat /proc/bus/input/devices

# 测试触摸事件
cat /dev/input/event0  # 按触摸屏幕看是否有数据输出
```

---

## 依赖库说明

### 已包含的库（无需安装）

| 库名 | 用途 |
|------|------|
| libjsoncpp.so.25 | JSON 解析 |
| libopus.so.0 | 音频编解码 |
| libportaudio.so.2 | 音频采集/播放 |
| libopenblas.so.0 | 矩阵运算 |
| libasound.so.2 | ALSA 音频 |
| libjson-c.so.4 | JSON-C 解析 |
| librga.so | RGA 图像处理 |
| librknnrt.so | RKNN NPU 运行时 |
| libcurl.so.4 | HTTP 请求（备用） |

### 需要系统安装的库

| 库名 | 安装命令 |
|------|---------|
| libcurl4 | `apt-get install -y libcurl4` |

---

## 网络配置（用于 AI 功能）

DeskBot 的 AI 聊天功能需要网络连接：

```bash
# 配置 Wi-Fi
wpa_passphrase "你的WiFi名称" "密码" > /etc/wpa_supplicant.conf
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlan0
udhcpc -i wlan0

# 测试网络
ping www.baidu.com
```

---

## 系统配置

首次运行前，建议修改配置文件：

```bash
vi /root/DeskBot_demo/bin/system_para.conf
```

关键配置项：

```ini
# 位置信息（用于天气）
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

## 开机自启动

设置开机自动运行 DeskBot：

```bash
# 编辑启动脚本
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

---

## 相关文档

- [DEVELOPMENT.md](./DEVELOPMENT.md) - 开发指南
- [FAQ.md](./FAQ.md) - 常见问题
- [SDK/README.md](../SDK/README.md) - SDK 编译指南
