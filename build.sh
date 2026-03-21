#!/bin/bash
#
# Echo-Mate 一键构建脚本 (Ubuntu 24.04)
# 功能：
#   1. 在 Docker 容器中交叉编译 AArch64 版本
#   2. 自动复制所有依赖库到输出目录
#   3. 生成智能 run.sh 脚本，自动检查和安装依赖
#
# 用法：
#   ./build.sh                    # 使用默认容器 ubuntu2404-build
#   ./build.sh <容器名>            # 使用指定容器
#

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认容器名
CONTAINER_NAME="${1:-ubuntu2404-build}"
PROJECT_ROOT="/project"
OUTPUT_DIR="${PROJECT_ROOT}/output/aarch64"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Echo-Mate AArch64 一键构建脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查容器是否存在并运行
echo -e "${YELLOW}[1/8] 检查 Docker 容器...${NC}"
if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}启动容器 ${CONTAINER_NAME}...${NC}"
    docker start "${CONTAINER_NAME}" 2>/dev/null || {
        echo -e "${RED}错误: 容器 ${CONTAINER_NAME} 不存在${NC}"
        echo "请创建容器: docker run -d --name ubuntu2404-build -v \$(pwd):/project ubuntu:24.04 sleep infinity"
        exit 1
    }
    sleep 2
fi
echo -e "${GREEN}✓ 容器就绪${NC}"

# 在容器中执行构建
echo -e "${YELLOW}[2/8] 在容器中配置构建环境...${NC}"
docker exec "${CONTAINER_NAME}" bash -c '
    # 安装必要的构建依赖
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    
    # 基础构建工具
    apt-get install -y -qq --no-install-recommends \
        build-essential cmake git pkg-config \
        gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        2>/dev/null || true
    
    # 修复头文件路径
    mkdir -p /usr/aarch64-linux-gnu/include
    
    # 链接 DRM 头文件
    if [ -d /usr/aarch64-linux-gnu/include/drm ]; then
        for f in /usr/aarch64-linux-gnu/include/drm/*.h; do
            name=$(basename "$f")
            ln -sf "$f" "/usr/aarch64-linux-gnu/include/$name" 2>/dev/null || true
        done
    fi
'
echo -e "${GREEN}✓ 环境配置完成${NC}"

# 编译 DeskBot_demo
echo -e "${YELLOW}[3/8] 编译 DeskBot_demo...${NC}"
docker exec "${CONTAINER_NAME}" bash -c "
    cd ${PROJECT_ROOT}/Demo/DeskBot_demo
    rm -rf build bin
    mkdir build && cd build
    
    cmake .. -DTARGET_AARCH64=ON \
        -DCMAKE_C_COMPILER=/usr/bin/aarch64-linux-gnu-gcc \
        -DCMAKE_CXX_COMPILER=/usr/bin/aarch64-linux-gnu-g++ \
        2>&1 | tail -5
    
    make -j\$(nproc) 2>&1 | tail -10
"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ DeskBot_demo 编译失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ DeskBot_demo 编译完成${NC}"

# 编译 AIChat_demo
echo -e "${YELLOW}[4/8] 编译 AIChat_demo...${NC}"
docker exec "${CONTAINER_NAME}" bash -c "
    cd ${PROJECT_ROOT}/Demo/AIChat_demo/Client
    rm -rf build_aarch64
    mkdir build_aarch64 && cd build_aarch64
    
    cmake .. -DTARGET_AARCH64=ON \
        -DCMAKE_C_COMPILER=/usr/bin/aarch64-linux-gnu-gcc \
        -DCMAKE_CXX_COMPILER=/usr/bin/aarch64-linux-gnu-g++ \
        2>&1 | tail -5
    
    make -j\$(nproc) 2>&1 | tail -5
"

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠ AIChat_demo 编译失败（非关键）${NC}"
else
    echo -e "${GREEN}✓ AIChat_demo 编译完成${NC}"
fi

# 创建输出目录结构
echo -e "${YELLOW}[5/8] 创建输出目录...${NC}"
docker exec "${CONTAINER_NAME}" bash -c "
    mkdir -p ${OUTPUT_DIR}/DeskBot_demo/bin
    mkdir -p ${OUTPUT_DIR}/AIChat_demo/bin
    mkdir -p ${OUTPUT_DIR}/yolov5_demo
"

# 复制 DeskBot_demo
echo -e "${YELLOW}[6/8] 复制 DeskBot_demo 到输出目录...${NC}"
docker exec "${CONTAINER_NAME}" bash -c "
    cd ${PROJECT_ROOT}/Demo/DeskBot_demo
    
    # 复制主程序
    cp bin/main ${OUTPUT_DIR}/DeskBot_demo/bin/
    
    # 复制配置文件
    cp bin/system_para.conf ${OUTPUT_DIR}/DeskBot_demo/bin/
    cp bin/gaode_adcode.json ${OUTPUT_DIR}/DeskBot_demo/bin/
    cp bin/cacert.pem ${OUTPUT_DIR}/DeskBot_demo/bin/
    
    # 复制库文件
    mkdir -p ${OUTPUT_DIR}/DeskBot_demo/bin/lib
    cp -r bin/lib/* ${OUTPUT_DIR}/DeskBot_demo/bin/lib/ 2>/dev/null || true
    
    # 复制模型和资源
    mkdir -p ${OUTPUT_DIR}/DeskBot_demo/bin/model
    cp -r bin/model/* ${OUTPUT_DIR}/DeskBot_demo/bin/model/ 2>/dev/null || true
    
    mkdir -p ${OUTPUT_DIR}/DeskBot_demo/bin/third_party
    cp -r bin/third_party/* ${OUTPUT_DIR}/DeskBot_demo/bin/third_party/ 2>/dev/null || true
    
    # 复制所有必要的系统依赖库
    AARCH64_LIB_DIR=/usr/aarch64-linux-gnu/lib_local
    REQUIRED_LIBS="libdrm.so.2 libjsoncpp.so.25 libopus.so.0 libportaudio.so.2 libopenblas.so.0 libasound.so.2 libjson-c.so.4 libcurl.so.4"
    
    echo "  复制系统依赖库..."
    for lib in \$REQUIRED_LIBS; do
        if [ -f \$AARCH64_LIB_DIR/\$lib ]; then
            cp -L \$AARCH64_LIB_DIR/\$lib ${OUTPUT_DIR}/DeskBot_demo/bin/lib/
            echo "    ✓ \$lib"
        else
            echo "    ⚠ \$lib 未找到"
        fi
    done
    
    # 设置库文件权限
    chmod 644 ${OUTPUT_DIR}/DeskBot_demo/bin/lib/*.so* 2>/dev/null || true
"
echo -e "${GREEN}✓ DeskBot_demo 复制完成${NC}"

# 复制 AIChat_demo
echo -e "${YELLOW}[7/8] 复制 AIChat_demo 到输出目录...${NC}"
docker exec "${CONTAINER_NAME}" bash -c "
    cd ${PROJECT_ROOT}/Demo/AIChat_demo/Client
    
    if [ -f build_aarch64/AIChatClient ]; then
        cp build_aarch64/AIChatClient ${OUTPUT_DIR}/AIChat_demo/bin/
        
        # 复制资源
        mkdir -p ${OUTPUT_DIR}/AIChat_demo/resources/snowboy/resources/models
        mkdir -p ${OUTPUT_DIR}/AIChat_demo/resources/audio
        
        cp third_party/snowboy/resources/common.res ${OUTPUT_DIR}/AIChat_demo/resources/snowboy/resources/ 2>/dev/null || true
        cp third_party/snowboy/resources/models/echo.pmdl ${OUTPUT_DIR}/AIChat_demo/resources/snowboy/resources/models/ 2>/dev/null || true
        cp third_party/audio/waked.pcm ${OUTPUT_DIR}/AIChat_demo/resources/audio/ 2>/dev/null || true
        
        # 复制库
        mkdir -p ${OUTPUT_DIR}/AIChat_demo/lib
        AARCH64_LIB_DIR=/usr/aarch64-linux-gnu/lib_local
        for lib in libjsoncpp.so.25 libopus.so.0 libportaudio.so.2 libopenblas.so.0; do
            if [ -f \$AARCH64_LIB_DIR/\$lib ]; then
                cp \$AARCH64_LIB_DIR/\$lib ${OUTPUT_DIR}/AIChat_demo/lib/
            fi
        done
    fi
"
echo -e "${GREEN}✓ AIChat_demo 复制完成${NC}"

# 创建智能启动脚本
echo -e "${YELLOW}[8/8] 生成智能启动脚本...${NC}"
cat > /tmp/run_deskbot.sh << 'RUNSCRIPT'
#!/bin/bash
#
# Echo-Mate DeskBot 智能启动脚本
# 自动检查并安装系统依赖
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Echo-Mate DeskBot 启动器${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检测架构
ARCH=$(uname -m)
echo -e "${BLUE}系统架构: $ARCH${NC}"

# 检查是否为 ARM 架构
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" && "$ARCH" != armv* ]]; then
    echo -e "${RED}错误: 此程序需要在 ARM 架构上运行${NC}"
    echo -e "${RED}当前架构: $ARCH${NC}"
    exit 1
fi

# 检查并安装系统依赖
install_system_deps() {
    echo -e "${YELLOW}[1/4] 检查系统依赖...${NC}"
    
    local deps_needed=""
    local deps_to_install=""
    
    # 检查 libcurl4
    if ! ldconfig -p | grep -q "libcurl.so.4"; then
        deps_needed="$deps_needed libcurl4"
        deps_to_install="$deps_to_install libcurl4"
    fi
    
    # 检查 libdrm
    if ! ldconfig -p | grep -q "libdrm.so.2"; then
        deps_needed="$deps_needed libdrm2"
        deps_to_install="$deps_to_install libdrm2"
    fi
    
    # 检查 ALSA
    if ! ldconfig -p | grep -q "libasound.so.2"; then
        deps_needed="$deps_needed libasound2"
        deps_to_install="$deps_to_install libasound2"
    fi
    
    if [ -n "$deps_needed" ]; then
        echo -e "${YELLOW}需要安装以下依赖:$deps_needed${NC}"
        
        # 检查是否有网络
        if ! ping -c 1 -W 5 www.baidu.com >/dev/null 2>&1; then
            echo -e "${RED}错误: 无法连接到网络，无法自动安装依赖${NC}"
            echo -e "${YELLOW}请手动安装: sudo apt-get install -y$deps_to_install${NC}"
            exit 1
        fi
        
        # 检查是否有 sudo 权限
        if ! sudo -n true 2>/dev/null; then
            echo -e "${YELLOW}需要管理员权限安装依赖，请输入密码...${NC}"
        fi
        
        # 更新并安装
        sudo apt-get update -qq
        sudo apt-get install -y -qq $deps_to_install
        sudo ldconfig
        
        echo -e "${GREEN}✓ 系统依赖安装完成${NC}"
    else
        echo -e "${GREEN}✓ 系统依赖已满足${NC}"
    fi
}

# 设置设备权限
setup_permissions() {
    echo -e "${YELLOW}[2/4] 设置设备权限...${NC}"
    
    # DRM 设备
    if [ -e "/dev/dri/card0" ]; then
        sudo chmod 666 /dev/dri/card0 2>/dev/null || true
    fi
    
    # 输入设备
    for dev in /dev/input/event*; do
        if [ -e "$dev" ]; then
            sudo chmod 666 "$dev" 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}✓ 设备权限设置完成${NC}"
}

# 检查程序依赖
check_program_deps() {
    echo -e "${YELLOW}[3/4] 检查程序依赖...${NC}"
    
    export LD_LIBRARY_PATH="$SCRIPT_DIR/bin/lib:$LD_LIBRARY_PATH"
    
    local missing=$(ldd "$SCRIPT_DIR/bin/main" 2>/dev/null | grep "not found" | awk '{print $1}' || true)
    
    if [ -n "$missing" ]; then
        echo -e "${RED}✗ 以下依赖库缺失:${NC}"
        echo "$missing" | while read lib; do
            echo "  - $lib"
        done
        
        # 尝试从系统安装
        echo -e "${YELLOW}尝试从系统安装缺失的库...${NC}"
        for lib in $missing; do
            case "$lib" in
                libcurl*)
                    sudo apt-get install -y -qq libcurl4 2>/dev/null || true
                    ;;
                libdrm*)
                    sudo apt-get install -y -qq libdrm2 2>/dev/null || true
                    ;;
                libasound*)
                    sudo apt-get install -y -qq libasound2 2>/dev/null || true
                    ;;
            esac
        done
        
        # 再次检查
        missing=$(ldd "$SCRIPT_DIR/bin/main" 2>/dev/null | grep "not found" | awk '{print $1}' || true)
        if [ -n "$missing" ]; then
            echo -e "${RED}仍有缺失的库，请手动解决:${NC}"
            echo "$missing"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ 所有依赖已满足${NC}"
}

# 确保程序有执行权限
fix_permissions() {
    echo -e "${YELLOW}[4/4] 检查文件权限...${NC}"
    
    if [ ! -x "$SCRIPT_DIR/bin/main" ]; then
        chmod +x "$SCRIPT_DIR/bin/main"
    fi
    
    # 确保库文件可读
    if [ -d "$SCRIPT_DIR/bin/lib" ]; then
        chmod -R +r "$SCRIPT_DIR/bin/lib/"
    fi
    
    echo -e "${GREEN}✓ 权限检查完成${NC}"
}

# 主程序
install_system_deps
setup_permissions
check_program_deps
fix_permissions

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  所有检查通过，启动 DeskBot...${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 启动程序
cd "$SCRIPT_DIR/bin"
export LD_LIBRARY_PATH="$SCRIPT_DIR/bin/lib:$LD_LIBRARY_PATH"

# 捕获退出信号
trap 'echo -e "\n${YELLOW}DeskBot 已退出${NC}"; exit 0' INT TERM

# 运行主程序
./main "$@"
RUNSCRIPT

# 复制启动脚本到输出目录
docker cp /tmp/run_deskbot.sh "${CONTAINER_NAME}:${OUTPUT_DIR}/DeskBot_demo/run.sh"
docker exec "${CONTAINER_NAME}" chmod +x "${OUTPUT_DIR}/DeskBot_demo/run.sh"

# 创建 README
cat > /tmp/README.txt << 'README'
Echo-Mate AArch64 构建输出
==========================

目录结构:
├── DeskBot_demo/          # 桌面机器人主程序 ⭐
│   ├── run.sh            # 智能启动脚本（推荐）
│   └── bin/              # 程序目录
│       ├── main          # 主程序
│       ├── lib/          # 依赖库
│       ├── model/        # YOLO 模型
│       ├── third_party/  # 资源文件
│       └── *.conf        # 配置文件
│
├── AIChat_demo/           # AI 语音助手客户端
│   └── bin/
│       └── AIChatClient
│
└── yolov5_demo/           # YOLOv5 物体检测

运行方法:
=========

1. DeskBot_demo（推荐）:
   cd DeskBot_demo
   ./run.sh
   
   脚本会自动：
   - 检查并安装系统依赖（libcurl4、libdrm2 等）
   - 设置设备权限
   - 检查所有依赖是否满足
   - 启动程序

2. AIChat_demo:
   cd AIChat_demo
   export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
   ./bin/AIChatClient

3. yolov5_demo:
   cd yolov5_demo
   ./rknn_yolov5_demo

依赖说明:
=========
- 所有必要的依赖库已包含在 lib/ 目录中
- 系统依赖（如 libcurl4）会自动安装
- 需要网络连接以自动安装系统依赖

故障排除:
=========
1. 如果提示权限不足，请使用 sudo 运行
2. 如果依赖安装失败，请检查网络连接
3. 查看 run.sh 输出的日志信息

README

docker cp /tmp/README.txt "${CONTAINER_NAME}:${OUTPUT_DIR}/README.txt"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "输出目录: ${OUTPUT_DIR}"
echo ""
echo "文件列表:"
docker exec "${CONTAINER_NAME}" ls -lh "${OUTPUT_DIR}/DeskBot_demo/"
echo ""
echo "部署方法:"
echo "  1. 复制到目标设备:"
echo "     scp -r ${OUTPUT_DIR}/DeskBot_demo user@lubancat:~/"
echo ""
echo "  2. 在目标设备上运行:"
echo "     cd ~/DeskBot_demo"
echo "     ./run.sh"
echo ""
