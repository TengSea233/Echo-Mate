Echo-Mate AArch64 构建输出
==========================

目录结构:
├── yolov5_demo/
│   ├── rknn_yolov5_demo    # YOLOv5 可执行文件
│   └── yolov5.rknn         # 模型文件（如果有）
│
├── AIChat_demo/
│   ├── bin/
│   │   └── AIChatClient    # AIChat 客户端可执行文件
│   ├── lib/                # 依赖库
│   └── resources/          # 资源文件
│       ├── snowboy/
│       │   ├── common.res
│       │   └── models/echo.pmdl
│       └── audio/waked.pcm
│
└── DeskBot_demo/
    ├── run.sh              # 启动脚本（推荐）
    └── bin/                # 程序和资源目录
        ├── main            # 主程序
        ├── lib/            # 所有依赖库
        ├── model/          # YOLO 模型
        ├── third_party/    # 唤醒词资源
        ├── system_para.conf # 系统配置
        ├── gaode_adcode.json # 城市代码
        └── cacert.pem      # SSL 证书

运行方法:
1. DeskBot_demo（推荐）:
   cd DeskBot_demo
   ./run.sh
   
   脚本会自动：
   - 检查并安装系统依赖（libcurl4、libasound2 等）
   - 自动修复库冲突
   - 检查所有依赖是否满足
   
   或手动运行（不推荐）:
   export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:./bin/lib:$LD_LIBRARY_PATH
   ./bin/main

2. AIChat_demo:
   cd AIChat_demo
   export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH
   ./bin/AIChatClient

3. yolov5_demo:
   cd yolov5_demo
   ./rknn_yolov5_demo
   （需要目标设备安装 librknnrt.so）

依赖说明:
- 所有必要的依赖库已包含在 lib/ 目录中
- 如果目标设备上已安装相同版本的库，可以不使用自带的 lib/
- RKNN 运行时 (librknnrt.so) 需要目标设备支持 Rockchip NPU
