#!/bin/bash
# Debian 11 容器中交叉编译 Echo-Mate 项目的脚本

set -e

echo "=========================================="
echo "Echo-Mate AArch64 交叉编译脚本"
echo "Debian 11 容器环境"
echo "=========================================="

# 检查是否在容器中
if [ ! -f /.dockerenv ]; then
    echo "警告: 此脚本应在 Debian 11 容器中运行"
    echo "请使用: docker exec -it debian11-build bash"
    echo "然后运行: /project/build_aarch64_in_debian11.sh"
    exit 1
fi

# 检查工具链
if ! command -v aarch64-linux-gnu-gcc &> /dev/null; then
    echo "错误: 未找到 aarch64-linux-gnu-gcc"
    echo "请安装交叉编译工具链:"
    echo "  apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu"
    exit 1
fi

echo ""
echo "工具链版本:"
aarch64-linux-gnu-gcc --version | head -1

# 安装必要的依赖
echo ""
echo "=========================================="
echo "安装编译依赖..."
echo "=========================================="

apt-get update

# 基础编译工具
apt-get install -y cmake build-essential pkg-config

# 图形和显示库
apt-get install -y libjson-c-dev libdrm-dev

# SDL2 (用于模拟器)
apt-get install -y libsdl2-dev libsdl2-image-dev

# OpenCV
apt-get install -y libopencv-dev

# 音频库
apt-get install -y portaudio19-dev libopus-dev

# JSON 和 Boost
apt-get install -y libjsoncpp-dev libboost-all-dev

# 数学库 (用于 snowboy)
apt-get install -y libatlas-base-dev libopenblas-dev liblapack-dev

# SSL
apt-get install -y libssl-dev

echo ""
echo "=========================================="
echo "编译 DeskBot_demo (AArch64)..."
echo "=========================================="

cd /project/Demo/DeskBot_demo
rm -rf build_aarch64
mkdir -p build_aarch64
cd build_aarch64

cmake .. -DTARGET_AARCH64=ON -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)

echo ""
echo "=========================================="
echo "编译完成!"
echo "=========================================="
echo ""
echo "输出文件:"
ls -la /project/Demo/DeskBot_demo/bin/
echo ""
echo "文件类型检查:"
file /project/Demo/DeskBot_demo/bin/main
