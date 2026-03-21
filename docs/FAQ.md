# ❓ Echo-Mate 常见问题解答 (FAQ)

本文档汇总了 Echo-Mate 使用过程中的常见问题及解决方案。

## 📋 目录

- [编译问题](#编译问题)
- [部署问题](#部署问题)
- [运行问题](#运行问题)
- [显示问题](#显示问题)
- [触摸问题](#触摸问题)
- [网络问题](#网络问题)
- [AI 功能问题](#ai-功能问题)
- [性能问题](#性能问题)

---

## 🔨 编译问题

### Q1: 编译时提示找不到 SDL2

**错误信息：**
```
Could not find SDL2 (missing: SDL2_LIBRARIES SDL2_INCLUDE_DIRS)
```

**原因：** 缺少 SDL2 开发库

**解决：**
```bash
sudo apt-get update
sudo apt-get install -y libsdl2-dev libsdl2-image-dev
```

---

### Q2: 交叉编译时提示找不到工具链

**错误信息：**
```
CMAKE_C_COMPILER not set, after EnableLanguage
```

**原因：** 交叉编译工具链未正确配置

**解决：**
```bash
# 检查工具链路径
cat Demo/DeskBot_demo/toolchain.cmake

# 确认 SDK 路径正确
set(SDK_PATH "你的SDK路径/SDK/rv1106-sdk")

# 或者使用系统交叉编译器
cmake .. -DTARGET_AARCH64=ON
```

---

### Q3: 编译时内存不足

**错误信息：**
```
c++: internal compiler error: Killed (program cc1plus)
```

**原因：** 并行编译任务过多，内存不足

**解决：**
```bash
# 减少并行编译任务数
make -j2  # 而不是 -j$(nproc)

# 或者增加交换空间
sudo fallocate -l 2G /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

### Q4: 找不到 websocketpp

**错误信息：**
```
Could not find a package configuration file provided by "WEBSOCKETPP"
```

**解决：**
```bash
sudo apt-get install -y libwebsocketpp-dev
```

---

## 📦 部署问题

### Q5: 可执行文件架构不匹配

**错误信息：**
```
-bash: ./main: cannot execute binary file: Exec format error
```

**原因：** 编译的是 x86 版本，但开发板是 ARM 架构

**诊断：**
```bash
# 检查文件架构
file bin/main

# 如果是 x86-64，输出类似：
# ELF 64-bit LSB executable, x86-64
```

**解决：**
```bash
# 重新交叉编译
cd Demo/DeskBot_demo
rm -rf build bin
mkdir build && cd build
cmake .. -DTARGET_AARCH64=ON
make
```

---

### Q6: 缺少依赖库

**错误信息：**
```
error while loading shared libraries: libxxx.so.x: cannot open shared object file
```

**诊断：**
```bash
# 查看缺失的库
ldd ./bin/main | grep "not found"
```

**解决：**
```bash
# 安装缺失的库
sudo apt-get install -y <库名>

# 或者复制库文件
scp libxxx.so.x root@开发板IP:/root/DeskBot_demo/bin/lib/
```

---

### Q7: libcurl 版本冲突

**错误信息：**
```
libcurl.so.4: version `CURL_OPENSSL_4' not found
```

**原因：** 自带的 libcurl 与系统版本不兼容

**解决：**
```bash
# 安装系统 libcurl
sudo apt-get update
sudo apt-get install -y libcurl4

# 使用 run.sh 启动（会自动处理冲突）
./run.sh
```

---

## ▶️ 运行问题

### Q8: 程序启动后立即退出

**排查步骤：**
```bash
# 1. 查看详细错误
./run.sh 2>&1

# 2. 检查配置文件是否存在
ls bin/system_para.conf

# 3. 检查资源文件
ls bin/third_party/snowboy/resources/

# 4. 检查权限
ls -la bin/main
```

**常见原因：**
- 配置文件缺失
- 资源文件缺失
- 权限不足
- 内存不足

---

### Q9: 段错误 (Segmentation fault)

**原因：** 内存访问错误

**排查：**
```bash
# 使用 GDB 调试
gdb ./bin/main
(gdb) run
(gdb) bt  # 查看调用栈

# 或者查看核心转储
dmesg | tail -20
```

**常见原因：**
- 空指针访问
- 数组越界
- 栈溢出

---

### Q10: 程序卡死无响应

**排查：**
```bash
# 查看 CPU 占用
top -p $(pidof main)

# 查看线程状态
cat /proc/$(pidof main)/status

# 发送 SIGSEGV 生成核心转储
kill -SEGV $(pidof main)
```

---

## 🖥️ 显示问题

### Q11: 屏幕黑屏无显示

**排查步骤：**

```bash
# 1. 检查帧缓冲设备
ls -la /dev/fb*

# 2. 检查设备树配置
cat /sys/class/graphics/fb0/name

# 3. 测试帧缓冲
cat /dev/urandom > /dev/fb0  # 应该显示雪花

# 4. 检查程序配置
grep LV_USE_SIMULATOR conf/dev_conf.h
# 应该为 #define LV_USE_SIMULATOR 0（硬件模式）

# 5. 检查日志
dmesg | grep -i "fb\|drm\|lcd"
```

**常见原因和解决：**

| 原因 | 症状 | 解决 |
|:-----|:-----|:-----|
| 模拟器模式 | 在开发板上运行但无显示 | 修改 `conf/dev_conf.h`: `#define LV_USE_SIMULATOR 0` |
| 权限不足 | 程序运行但屏幕黑屏 | `chmod 666 /dev/fb0` |
| 驱动未加载 | 无 /dev/fb0 设备 | 检查设备树和内核配置 |
| 其他进程占用 | 屏幕显示其他内容 | `killall` 其他图形程序 |

---

### Q12: 显示花屏或颜色异常

**原因：** 颜色格式不匹配

**解决：**
```bash
# 检查屏幕颜色格式
cat /sys/class/graphics/fb0/bits_per_pixel
# 通常是 16 或 32

# 修改 lv_conf.h
#define LV_COLOR_DEPTH 16  # 与屏幕匹配
```

---

### Q13: 画面撕裂或闪烁

**原因：** 没有使用双缓冲

**解决：**
```c
// lv_conf.h
#define LV_LINUX_FBDEV_BUFFER_COUNT  2
#define LV_LINUX_FBDEV_RENDER_MODE   LV_DISPLAY_RENDER_MODE_FULL
```

---

## 👆 触摸问题

### Q14: 触摸无响应

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

**常见原因：**
- 触摸设备节点错误
- 权限不足
- 驱动未加载

---

### Q15: 触摸位置偏移或不准

**原因：** 触摸屏校准问题

**解决：**
```bash
# 使用 tslib 校准
export TSLIB_FBDEVICE=/dev/fb0
export TSLIB_TSDEVICE=/dev/input/event0
ts_calibrate
```

---

### Q16: 触摸太灵敏或太迟钝

**解决：**
```c
// 在代码中调整触摸参数
lv_indev_set_read_timer(indev, 20);  // 读取间隔 20ms
```

---

## 🌐 网络问题

### Q17: Wi-Fi 无法连接

**排查：**
```bash
# 检查无线接口
ifconfig -a | grep wlan

# 启用无线
ifconfig wlan0 up

# 扫描网络
iwlist wlan0 scan | grep ESSID

# 配置 Wi-Fi
wpa_passphrase "SSID" "密码" > /etc/wpa_supplicant.conf
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlan0
udhcpc -i wlan0

# 测试网络
ping www.baidu.com
```

---

### Q18: AI 聊天无法连接服务器

**排查：**
```bash
# 1. 检查服务器 IP 配置
cat bin/system_para.conf | grep AIChat_server

# 2. 测试网络连通性
ping <服务器IP>
telnet <服务器IP> 8000

# 3. 检查防火墙
iptables -L | grep 8000
```

**常见原因：**
- 服务器未启动
- 网络不通
- 防火墙阻挡
- 配置错误

---

## 🤖 AI 功能问题

### Q19: 语音唤醒不工作

**排查：**
```bash
# 1. 检查音频设备
arecord -l
aplay -l

# 2. 检查唤醒词模型
ls bin/third_party/snowboy/resources/models/echo.pmdl

# 3. 测试录音
arecord -d 5 test.wav
aplay test.wav

# 4. 检查麦克风权限
chmod 666 /dev/snd/*
```

---

### Q20: 语音识别不准确

**优化：**
- 调整麦克风增益
- 降低环境噪音
- 调整 VAD 参数

---

### Q21: YOLO 物体检测无法启动

**排查：**
```bash
# 1. 检查模型文件
ls bin/model/yolov5.rknn

# 2. 检查 NPU 驱动
dmesg | grep -i rknpu

# 3. 检查库文件
ls bin/lib/librknnrt.so

# 4. 测试 NPU
rknn_benchmark  # 如果有这个工具
```

---

### Q22: 天气无法获取

**排查：**
```bash
# 1. 检查网络
curl http://www.baidu.com

# 2. 检查 API 密钥
cat bin/system_para.conf | grep gaode_api_key

# 3. 测试 API
curl "https://restapi.amap.com/v3/weather/weatherInfo?key=你的密钥&city=110000"
```

---

## ⚡ 性能问题

### Q23: 界面卡顿

**优化：**
```c
// 1. 降低刷新率
lv_display_set_refresh_rate(disp, 30);  // 30fps

// 2. 使用局部刷新
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_PARTIAL

// 3. 减少动画效果
lv_obj_set_style_anim_time(obj, 0, 0);

// 4. 禁用阴影和特效
#define LV_USE_SHADOW 0
```

---

### Q24: 内存不足

**诊断：**
```bash
# 查看内存使用
free -h
cat /proc/meminfo
```

**优化：**
```bash
# 减少 LVGL 内存池
// lv_conf.h
#define LV_MEM_SIZE (128 * 1024)  // 128KB

# 关闭不需要的功能
// 禁用不用的 demo 和示例
```

---

### Q25: CPU 占用过高

**诊断：**
```bash
# 查看 CPU 使用
top -p $(pidof main)

# 查看线程
ps -T -p $(pidof main)
```

**优化：**
- 降低刷新率
- 优化绘制逻辑
- 使用硬件加速（如果有）

---

## 🔧 其他问题

### Q26: 如何恢复出厂设置

```bash
# 删除配置文件
rm /root/DeskBot_demo/bin/system_para.conf

# 重新复制默认配置
cp /path/to/default/system_para.conf /root/DeskBot_demo/bin/

# 重启程序
killall main
./run.sh
```

---

### Q27: 如何查看版本信息

```bash
# 查看程序版本
strings ./bin/main | grep -i version

# 查看 SDK 版本
cat /etc/os-release

# 查看内核版本
uname -a
```

---

### Q28: 如何备份配置

```bash
# 备份配置文件
cp bin/system_para.conf system_para.conf.bak

# 备份整个目录
tar czvf deskbot_backup.tar.gz DeskBot_demo/
```

---

### Q29: 如何更新程序

```bash
# 1. 备份配置
cp bin/system_para.conf /tmp/

# 2. 删除旧版本
rm -rf DeskBot_demo/

# 3. 复制新版本
scp -r output/aarch64/DeskBot_demo /root/

# 4. 恢复配置
cp /tmp/system_para.conf DeskBot_demo/bin/

# 5. 运行
./run.sh
```

---

### Q30: 如何提交 Bug 报告

请提供以下信息：
1. **开发板型号**（如 Luckfox Pico Plus）
2. **固件版本**（`cat /etc/os-release`）
3. **完整的错误日志**
4. **复现步骤**
5. **已尝试的解决方法**

提交到：https://github.com/No-Chicken/Echo-Mate/issues

---

## 📚 相关文档

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
- [DEVELOPMENT.md](./DEVELOPMENT.md) - 开发指南
- [SDK/README.md](../SDK/README.md) - SDK 文档

---

## 💡 快速诊断命令

```bash
# 系统信息
uname -a
cat /etc/os-release
free -h

# 设备信息
ls /dev/fb*
ls /dev/input/event*
cat /proc/bus/input/devices

# 程序信息
file bin/main
ldd bin/main

# 运行日志
./run.sh 2>&1 | tee log.txt
```
