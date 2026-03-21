# LubanCat4 触摸屏故障排查指南

## 问题现象
- 界面正常显示
- 触摸屏无响应

---

## 排查步骤

### 1. 检查触摸设备是否存在

```bash
# 查看输入设备
ls -la /dev/input/event*

# 查看设备详细信息
cat /proc/bus/input/devices
```

**预期输出：**
```
I: Bus=0018 Vendor=0000 Product=0000 Version=0000
N: Name="goodix-ts"          # 或 "ft5x06", "CST816S" 等
P: Phys=input0
S: Sysfs=/devices/platform/.../input/input0
U: Uniq=
H: Handlers=event0
...
```

**常见问题：**
- 没有触摸设备 → 驱动未加载或设备树配置错误
- 设备名不对 → 需要修改 LVGL 配置的触摸设备路径

---

### 2. 测试触摸事件

```bash
# 安装 evtest
sudo apt-get install evtest

# 测试触摸事件（选择对应的 event 设备）
sudo evtest /dev/input/event0

# 触摸屏幕，看是否有数据输出
```

**预期输出：**
```
Event: time 1234567890.123456, type 3 (EV_ABS), code 57 (ABS_MT_TRACKING_ID), value 0
Event: time 1234567890.123456, type 3 (EV_ABS), code 53 (ABS_MT_POSITION_X), value 120
Event: time 1234567890.123456, type 3 (EV_ABS), code 54 (ABS_MT_POSITION_Y), value 80
```

**如果没有输出：**
- 驱动问题
- 硬件连接问题
- 设备树配置错误

---

### 3. 检查设备权限

```bash
# 检查设备权限
ls -la /dev/input/event0

# 应该显示类似：
# crw-rw---- 1 root input 13, 64 Jan  1 00:00 /dev/input/event0
```

**修复权限：**
```bash
# 临时修复
sudo chmod 666 /dev/input/event0

# 永久修复（创建 udev 规则）
cat > /etc/udev/rules.d/99-touchscreen.rules << 'RULE'
KERNEL=="event*", ATTRS{name}=="goodix-ts", MODE="0666"
KERNEL=="event*", ATTRS{name}=="ft5x06*", MODE="0666"
KERNEL=="event*", ATTRS{name}=="CST816S*", MODE="0666"
RULE

# 重新加载规则
sudo udevadm control --reload-rules
sudo udevadm trigger
```

---

### 4. 检查 LVGL 触摸配置

编辑 `main.c`，确认触摸设备路径正确：

```c
#if LV_USE_EVDEV
static void lv_linux_indev_init(void)
{
    // LubanCat4 可能是 event0, event1, event2...
    // 需要根据实际情况修改
    lv_indev_t * touch;
    
    // 尝试不同的设备路径
    touch = lv_evdev_create(LV_INDEV_TYPE_POINTER, "/dev/input/event0");
    if(!touch) {
        touch = lv_evdev_create(LV_INDEV_TYPE_POINTER, "/dev/input/event1");
    }
    if(!touch) {
        touch = lv_evdev_create(LV_INDEV_TYPE_POINTER, "/dev/input/event2");
    }
}
#endif
```

---

### 5. 检查触摸坐标映射

LubanCat4 的触摸屏坐标可能需要校准：

```bash
# 安装 tslib
sudo apt-get install tslib libts-bin

# 设置环境变量
export TSLIB_FBDEVICE=/dev/fb0
export TSLIB_TSDEVICE=/dev/input/event0
export TSLIB_CALIBFILE=/etc/pointercal

# 校准触摸屏
sudo ts_calibrate

# 测试触摸
sudo ts_test
```

---

### 6. 检查屏幕旋转

如果屏幕旋转了，触摸坐标也需要对应旋转：

```c
// 在 lv_linux_disp_init 中设置旋转
lv_display_set_rotation(disp, LV_DISPLAY_ROTATION_90);  // 或 180, 270
```

---

### 7. LubanCat4 特定配置

LubanCat4 使用 MIPI DSI 屏幕，可能需要特殊配置：

```bash
# 检查设备树
cat /proc/device-tree/model

# 检查显示驱动
dmesg | grep -i "dsi\|drm\|panel"

# 检查触摸驱动
dmesg | grep -i "touch\|goodix\|ft5x06"
```

**如果触摸驱动未加载：**
```bash
# 手动加载驱动
sudo modprobe goodix_ts    # 或 ft5x06_ts

# 检查是否加载成功
lsmod | grep -i touch
```

---

### 8. 调试日志

启用 LVGL 日志查看触摸事件：

```c
// lv_conf.h
#define LV_USE_LOG 1
#define LV_LOG_LEVEL LV_LOG_LEVEL_INFO
```

运行程序查看日志：
```bash
./run.sh 2>&1 | grep -i "touch\|indev\|evdev"
```

---

## 常见原因总结

| 原因 | 检查方法 | 解决方案 |
|:-----|:---------|:---------|
| 触摸设备不存在 | `ls /dev/input/event*` | 检查设备树和驱动 |
| 设备路径错误 | `evtest` 测试 | 修改 `main.c` 中的设备路径 |
| 权限不足 | `ls -la /dev/input/event*` | 修改权限或 udev 规则 |
| 坐标映射错误 | `ts_test` | 校准触摸屏 |
| 屏幕旋转 | 观察显示方向 | 设置 `lv_display_set_rotation` |
| 驱动未加载 | `lsmod` | 手动加载驱动模块 |

---

## 快速修复脚本

```bash
#!/bin/bash
# LubanCat4 触摸修复脚本

echo "=== LubanCat4 触摸故障修复 ==="

# 1. 查找触摸设备
echo "[1/4] 查找触摸设备..."
for i in 0 1 2 3 4; do
    if [ -e "/dev/input/event$i" ]; then
        name=$(cat /sys/class/input/event$i/device/name 2>/dev/null)
        echo "  event$i: $name"
    fi
done

# 2. 设置权限
echo "[2/4] 设置触摸设备权限..."
sudo chmod 666 /dev/input/event*

# 3. 检查驱动
echo "[3/4] 检查触摸驱动..."
if ! lsmod | grep -q "goodix\|ft5x06"; then
    echo "  尝试加载触摸驱动..."
    sudo modprobe goodix_ts 2>/dev/null || true
    sudo modprobe ft5x06_ts 2>/dev/null || true
fi

# 4. 测试触摸
echo "[4/4] 测试触摸事件..."
echo "请触摸屏幕，看是否有输出（按 Ctrl+C 结束）..."
timeout 5 evtest /dev/input/event0 2>/dev/null || true

echo "=== 修复完成 ==="
echo "如果触摸仍无响应，请检查 main.c 中的触摸设备路径配置"
```

---

## 相关文档

- [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
- [DEVELOPMENT.md](./DEVELOPMENT.md) - 开发指南
- [FAQ.md](./FAQ.md) - 常见问题
