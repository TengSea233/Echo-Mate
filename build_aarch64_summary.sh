#!/bin/bash
echo '========================================'
echo 'Echo-Mate AArch64 交叉编译结果'
echo '========================================'
echo ''
echo '1. yolov5_demo (AI相机):'
echo '   输出: Demo/yolov5_demo/cpp/build_aarch64/rknn_yolov5_demo'
file /project/Demo/yolov5_demo/cpp/build_aarch64/rknn_yolov5_demo | sed 's/^/   /'
ls -lh /project/Demo/yolov5_demo/cpp/build_aarch64/rknn_yolov5_demo | awk '{print 
