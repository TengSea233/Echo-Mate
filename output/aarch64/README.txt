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

