#!/bin/bash
# Echo-Mate DeskBot 启动脚本
# 自动处理库依赖兼容性问题

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测架构
ARCH=$(uname -m)
case "$ARCH" in
    aarch64) LIB_PATH="/usr/lib/aarch64-linux-gnu" ;;
    armv7l|armhf) LIB_PATH="/usr/lib/arm-linux-gnueabihf" ;;
    x86_64) LIB_PATH="/usr/lib/x86_64-linux-gnu" ;;
    *) LIB_PATH="/usr/lib" ;;
esac

# 检查并安装系统依赖
install_system_deps() {
    echo -e "${YELLOW}[检查系统依赖]${NC}"
    
    local deps_needed=""
    
    # 检查 libcurl4
    if ! ldconfig -p | grep -q "libcurl.so.4"; then
        deps_needed="$deps_needed libcurl4"
    fi
    
    # 检查 ALSA
    if ! ldconfig -p | grep -q "libasound.so.2"; then
        deps_needed="$deps_needed libasound2"
    fi
    
    if [ -n "$deps_needed" ]; then
        echo -e "${YELLOW}需要安装以下系统依赖:$deps_needed${NC}"
        
        # 检查是否有 sudo 权限
        if ! sudo -n true 2>/dev/null; then
            echo -e "${YELLOW}需要管理员权限安装依赖，请输入密码...${NC}"
        fi
        
        sudo apt-get update -qq
        sudo apt-get install -y -qq $deps_needed
        echo -e "${GREEN}✓ 系统依赖安装完成${NC}"
    else
        echo -e "${GREEN}✓ 系统依赖已满足${NC}"
    fi
}

# 智能处理 libcurl 库
# 策略：优先使用系统 libcurl，如果系统没有则使用自带版本
setup_libcurl() {
    echo -e "${YELLOW}[配置 libcurl]${NC}"
    
    local system_curl="$LIB_PATH/libcurl.so.4"
    local bundled_curl="$SCRIPT_DIR/bin/lib/libcurl.so.4"
    
    if [ -f "$system_curl" ]; then
        # 系统有 libcurl，优先使用系统版本
        echo -e "${GREEN}✓ 使用系统 libcurl: $system_curl${NC}"
        # 临时移除自带的 libcurl，避免冲突
        if [ -f "$bundled_curl" ]; then
            mv "$bundled_curl" "$bundled_curl.bak" 2>/dev/null || true
        fi
        # 设置库路径：系统库优先
        export LD_LIBRARY_PATH="$LIB_PATH:$SCRIPT_DIR/bin/lib:$LD_LIBRARY_PATH"
    else
        # 系统没有 libcurl，使用自带版本
        echo -e "${YELLOW}! 系统未安装 libcurl，使用自带版本${NC}"
        # 恢复自带的 libcurl（如果之前被备份）
        if [ -f "$bundled_curl.bak" ]; then
            mv "$bundled_curl.bak" "$bundled_curl" 2>/dev/null || true
        fi
        # 设置库路径：自带库优先
        export LD_LIBRARY_PATH="$SCRIPT_DIR/bin/lib:$LIB_PATH:$LD_LIBRARY_PATH"
    fi
}

# 检查程序依赖
check_program_deps() {
    echo -e "${YELLOW}[检查程序依赖]${NC}"
    
    local missing=$(ldd ./bin/main 2>/dev/null | grep "not found" | awk '{print $1}' || true)
    
    if [ -n "$missing" ]; then
        echo -e "${RED}✗ 以下依赖库缺失:${NC}"
        echo "$missing" | while read lib; do
            echo "  - $lib"
        done
        
        # 特殊处理：如果是 OpenLDAP 版本不匹配，给出明确提示
        if echo "$missing" | grep -q "OPENLDAP"; then
            echo ""
            echo -e "${YELLOW}提示: 检测到 OpenLDAP 版本不兼容${NC}"
            echo -e "${YELLOW}建议: 确保系统已安装 libcurl4，脚本会自动优先使用系统版本${NC}"
        fi
        
        return 1
    fi
    
    echo -e "${GREEN}✓ 所有依赖已满足${NC}"
    return 0
}

# 确保程序有执行权限
fix_permissions() {
    if [ ! -x ./bin/main ]; then
        echo -e "${YELLOW}[修复权限]${NC} 添加执行权限..."
        chmod +x ./bin/main
    fi
}

# 主程序
echo "========================================"
echo "    Echo-Mate DeskBot 启动器"
echo "========================================"
echo ""
echo "架构: $ARCH"
echo ""

# 步骤 1: 修复权限
fix_permissions

# 步骤 2: 安装系统依赖
install_system_deps

# 步骤 3: 智能配置 libcurl
setup_libcurl

# 步骤 4: 检查程序依赖
if ! check_program_deps; then
    echo ""
    echo -e "${RED}依赖检查失败，请手动解决上述问题${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ 所有检查通过，启动 DeskBot...${NC}"
echo ""
cd bin && exec ./main "$@"
