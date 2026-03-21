#!/bin/bash
# 复制所有必要的依赖库到部署目录

DEPLOY_DIR=${1:-"./bin"}
LIB_DIR=${DEPLOY_DIR}/lib

echo "复制依赖库到 ${LIB_DIR}"
mkdir -p ${LIB_DIR}

# 从交叉编译环境复制库
AARCH64_LIB_DIR=/usr/aarch64-linux-gnu/lib_local

LIBS=(
    libjsoncpp.so.25
    libopus.so.0
    libportaudio.so.2
    libopenblas.so.0
    libasound.so.2
    libjson-c.so.4
    libcurl.so.4
)

for lib in ${LIBS[@]}; do
    if [ -f ${AARCH64_LIB_DIR}/${lib} ]; then
        cp -v ${AARCH64_LIB_DIR}/${lib} ${LIB_DIR}/
    else
        echo "警告: ${lib} 未找到"
    fi
done

echo "完成!"
echo "请确保在目标设备上设置 LD_LIBRARY_PATH:"
echo "  export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH"
