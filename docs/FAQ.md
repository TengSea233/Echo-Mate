# Echo-Mate 常见问题解答 (FAQ)

## 目录

- [编译问题](#编译问题)
- [部署问题](#部署问题)
- [运行问题](#运行问题)
- [显示问题](#显示问题)
- [网络问题](#网络问题)
- [AI 功能问题](#ai-功能问题)

---

## 编译问题

### Q1: 编译时提示找不到 SDL2

**错误信息：**
```
Could not find SDL2 (missing: SDL2_LIBRARIES SDL2_INCLUDE_DIRS)
```

**解决：**
```bash
sudo apt-get install libsdl2-dev libsdl2-image-dev
```

---

### Q2: 交叉编译时提示找不到工具链

**错误信息：**
```
CMAKE_C_COMPILER not set, after EnableLanguage
```

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

## 部署问题

### Q4: 可执行文件架构不匹配

**错误信息：**
```
-bash: ./main: cannot execute binary file: Exec format error
```

**原因：** 编译的是 x86 版本，但开发板是 ARM 架构。

**解决：**
```bash
# 检查文件架构
file bin/main

# 如果是 x86-64，需要重新交叉编译
cd Demo/DeskBot_demo
rm -rf build bin
mkdir build && cd build
cmake .. -DTARGET_AARCH64=ON
make
```

---

### Q5: 缺少依赖库

**错误信息：**
```
error while loading shared libraries: libxxx.so.x: cannot open shared object file
```

**解决：**
```bash
# 查看缺失的库
ldd ./bin/main | grep "not found"

# 安装缺失的库
sudo apt-get install -y <库名>

# 或者复制库文件
scp libxxx.so.x root@开发板IP:/root/DeskBot_demo/bin/lib/
```

---

## 运行问题

### Q6: 程序启动后立即退出

**排查步骤：**
```bash
# 1. 查看详细错误
./run.sh 2>&1

# 2. 检查配置文件是否存在
ls bin/system_para.conf

# 3. 检查资源文件
ls bin/third_party/snowboy/resources/
```

---

### Q7: 段错误 (Segmentation fault)

**可能原因：**
- 内存不足
- 资源文件缺失
- 配置错误

**排查：**
```bash
# 使用 GDB 调试
gdb ./bin/main
(gdb) run
(gdb) bt  # 查看调用栈
```

---

## 显示问题

### Q8: 屏幕黑屏无显示

**排查步骤：**

```bash
# 1. 检查帧缓冲设备
ls -la /dev/fb*

# 2. 检查设备树配置
cat /sys/class/graphics/fb0/name

# 3. 测试帧缓冲
cat /dev/urandom > /dev/fb0  # 应该显示雪花

# 4. 检查配置
grep LV_USE_SIMULATOR conf/dev_conf.h
# 应该为 #define LV_USE_SIMULATOR 0（硬件模式）
```

**常见原因：**
- 配置为模拟器模式（`LV_USE_SIMULATOR 1`）
- 帧缓冲设备权限不足
- 屏幕驱动未正确加载

---

### Q9: 显示花屏或颜色异常

**解决：**
```c
// lv_conf.h 中检查颜色格式
#define LV_COLOR_DEPTH 16  // 与屏幕匹配

// 检查屏幕颜色格式
cat /sys/class/graphics/fb0/bits_per_pixel
```

---

### Q10: 触摸无响应

**排查步骤：**
```bash
# 1. 检查触摸设备
ls -la /dev/input/event*

# 2. 查看输入设备信息
cat /proc/bus/input/devices

# 3. 测试触摸事件
cat /dev/input/event0 | xxd  # 触摸屏幕看是否有数据

# 4. 检查权限
chmod 666 /dev/input/event0
```

---

## 网络问题

### Q11: Wi-Fi 无法连接

**排查：**
```bash
# 检查无线接口
ifconfig -a | grep wlan

# 启用无线
ifconfig wlan0 up

# 配置 Wi-Fi
wpa_passphrase "SSID" "密码" > /etc/wpa_supplicant.conf
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlan0
udhcpc -i wlan0

# 测试网络
ping www.baidu.com
```

---

### Q12: AI 聊天无法连接服务器

**排查：**
```bash
# 1. 检查服务器 IP 配置
cat bin/system_para.conf | grep AIChat_server

# 2. 测试网络连通性
ping <服务器IP>
telnet <服务器IP> 8000

# 3. 检查防火墙
```

---

## AI 功能问题

### Q13: 语音唤醒不工作

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
```

---

### Q14: YOLO 物体检测无法启动

**排查：**
```bash
# 1. 检查模型文件
ls bin/model/yolov5.rknn

# 2. 检查 NPU 驱动
dmesg | grep -i rknpu

# 3. 检查库文件
ls bin/lib/librknnrt.so
```

---

## 性能问题

### Q15: 界面卡顿

**优化建议：**
```c
// 1. 降低刷新率
lv_display_set_refresh_rate(disp, 30);  // 30fps

// 2. 使用局部刷新
#define LV_LINUX_FBDEV_RENDER_MODE LV_DISPLAY_RENDER_MODE_PARTIAL

// 3. 减少动画效果
lv_obj_set_style_anim_time(obj, 0, 0);
```

---

### Q16: 内存不足

**优化：**
```bash
# 查看内存使用
free -h

# 减少 LVGL 内存池
// lv_conf.h
#define LV_MEM_SIZE (128 * 1024)  // 128KB

# 关闭不需要的功能
// 禁用不用的 demo 和示例
```

---

## 其他问题

### Q17: 如何恢复出厂设置

```bash
# 删除配置文件
rm /root/DeskBot_demo/bin/system_para.conf

# 重新复制默认配置
cp /path/to/default/system_para.conf /root/DeskBot_demo/bin/
```

---

### Q18: 如何查看版本信息

```bash
./bin/main --version  # 如果有实现
# 或查看源码
grep VERSION conf/version.h
```

---

### Q19: 如何提交 Bug 报告

请提供以下信息：
1. 开发板型号和固件版本
2. 完整的错误日志
3. 复现步骤
4. 已尝试的解决方法

提交到：https://github.com/No-Chicken/Echo-Mate/issues

---

## 相关文档

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
- [DEVELOPMENT.md](./DEVELOPMENT.md) - 开发指南
- [SDK/README.md](../SDK/README.md) - SDK 文档
