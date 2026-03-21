# Echo-Mate Project Guide for AI Agents

## Project Overview

Echo-Mate is a feature-rich desktop robot project based on the RV1106 chip. It is a compact Linux desktop assistant and development board with an LVGL-based menu system, supporting chat, translation, weather display, and AI camera capabilities.

**Hardware Specifications:**
- Chip: RV1106 (Rockchip)
- Processor: Single-core Cortex A7
- NPU: 1 TOPS, supports int4/int8/int16
- Memory: 256MB DDR3L
- Wi-Fi + Bluetooth: RTL8723bs
- Display: SPI + Touch IIC (P024C128-CTP)
- Storage: SD card or NAND FLASH

**Project Language:** Chinese (documentation and comments are primarily in Chinese)

---

## Repository Structure

```
Echo-Mate/
├── Demo/                       # Demo applications for Echo development board
│   ├── DeskBot_demo/           # Main AI desktop robot (fusion of all demos)
│   ├── AIChat_demo/            # AI voice assistant (Client/Server architecture)
│   ├── yolov5_demo/            # YOLOv5 object detection demo
│   └── rkmpi_demos/            # RKMPI multimedia demos (RTSP, camera, etc.)
├── SDK/                        # SDK folder
│   ├── rv1106-sdk/             # Modified Luckfox SDK for RV1106
│   └── README.md               # SDK usage and development board instructions
├── assets/                     # Project images and documentation assets
├── Dockerfile                  # Docker development environment
├── docker-compose.yml          # Docker Compose configuration
└── README.md                   # Main project documentation
```

---

## Technology Stack

### Hardware Platform
- **SoC:** Rockchip RV1106 (ARM Cortex-A7)
- **Cross-compilation:** arm-rockchip830-linux-uclibcgnueabihf-gcc/g++

### Main Software Stack

#### 1. DeskBot_demo (Main Application)
- **UI Framework:** LVGL v9.2.2 (Light and Versatile Graphics Library)
- **Language:** C (C99) / C++ (C17)
- **Build System:** CMake (minimum version 3.10)
- **Display Backends:** SDL2 (simulator), Linux FBDev (hardware), DRM
- **Input:** evdev (touchscreen), SDL mouse (simulator)

#### 2. AIChat_demo (AI Voice Assistant)
- **Client (Device-side):** C++ with WebSocket++, Opus, PortAudio
- **Server (PC-side):** Python 3.10+
  - WebSockets for communication
  - PyTorch for VAD/ASR models
  - FunASR (SenseVoice) for speech recognition
  - CosyVoice for TTS (via Aliyun API)
  - Dashscope for LLM (Tongyi Qianwen)

#### 3. YOLOv5_demo (AI Camera)
- **Language:** C++
- **Libraries:** OpenCV-mobile, RKNN, RGA (2D graphics acceleration)
- **Model:** YOLOv5s (RKNN format)

#### 4. SDK
- **Base:** Luckfox Pico SDK (Buildroot-based)
- **Kernel:** Linux (custom defconfig: `echo_rv1106_linux_defconfig`)
- **Bootloader:** U-Boot
- **Rootfs:** Buildroot

---

## Build Instructions

### Prerequisites

**Host System:** Ubuntu 22.04 LTS recommended

**Dependencies:**
```bash
sudo apt-get install repo git ssh make gcc gcc-multilib g++-multilib \
    module-assistant expect g++ gawk texinfo libssl-dev bison flex \
    fakeroot cmake unzip gperf autoconf device-tree-compiler \
    libncurses5-dev pkg-config
```

**For SDL Simulator:**
```bash
sudo apt-get install libsdl2-dev libsdl2-image-dev libdrm-dev
```

**For AIChat Client:**
```bash
sudo apt-get install libjsoncpp-dev libopus-dev libasound-dev \
    libportaudio2 libboost-dev libwebsocketpp-dev
```

### Clone Repository

```bash
git clone https://github.com/No-Chicken/Echo-Mate.git
cd Echo-Mate
git submodule update --init --recursive

# For LFS files
git lfs pull
git submodule foreach --recursive 'git lfs pull'
```

### SDK Build (Firmware)

```bash
cd SDK/rv1106-sdk

# Select board configuration (choose Echo Mate config)
./build.sh lunch

# Full build
./build.sh
```

**Output:** Firmware images in `SDK/rv1106-sdk/output/`

### DeskBot_demo Build

#### Option 1: SDL Simulator (for testing on PC)

1. Edit `Demo/DeskBot_demo/conf/dev_conf.h`:
   ```c
   #define LV_USE_SIMULATOR 1
   ```

2. Build:
   ```bash
   cd Demo/DeskBot_demo
   mkdir build && cd build
   cmake ..
   make
   ```

3. Run:
   ```bash
   cd ../bin
   ./main
   ```

#### Option 2: Cross-compile for ARM Board

1. Edit `Demo/DeskBot_demo/conf/dev_conf.h`:
   ```c
   #define LV_USE_SIMULATOR 0
   ```

2. Update `Demo/DeskBot_demo/toolchain.cmake` with your SDK path:
   ```cmake
   set(SDK_PATH "<your-sdk-path>/SDK/rv1106-sdk")
   ```

3. Build:
   ```bash
   cd Demo/DeskBot_demo/build
   cmake .. -DTARGET_ARM=ON
   make
   ```

4. Deploy:
   - Copy `bin/` folder to the development board
   - Run `./main` on the board

### AIChat Server Setup

```bash
cd Demo/AIChat_demo/Server

# Create virtual environment
conda create --prefix ./AIChatServerEnv python=3.10
conda activate ./AIChatServerEnv

# Install dependencies
pip install -r requirements.txt

# Run server
python ./main.py --access_token="123456" --aliyun_api_key="sk-your-api-key"
```

---

## Project Architecture

### DeskBot_demo Module Structure

```
DeskBot_demo/
├── main.c                      # Entry point
├── lv_conf.h                   # LVGL configuration
├── conf/
│   ├── dev_conf.h             # Device configuration (simulator vs hardware)
│   └── version.h              # Version info
├── lvgl/                      # LVGL library (submodule)
├── gui_app/                   # UI application layer
│   ├── ui.c/h                 # Main UI initialization
│   ├── pages/                 # UI pages (each page is like an "app")
│   │   ├── ui_HomePage/       # Home screen
│   │   ├── ui_ChatBotPage/    # AI chat interface
│   │   ├── ui_WeatherPage/    # Weather display
│   │   ├── ui_YOLOPage/       # AI camera interface
│   │   ├── ui_CalculatorPage/ # Calculator
│   │   ├── ui_CalendarPage/   # Calendar
│   │   ├── ui_DrawPage/       # Drawing app
│   │   ├── ui_Game2048Page/   # 2048 game
│   │   ├── ui_GameMemoryPage/ # Memory game
│   │   ├── ui_GameMuyuPage/   # Wooden fish game
│   │   ├── ui_SettingPage/    # Settings
│   │   └── ui_template/       # Template for new pages
│   ├── fonts/                 # Custom fonts
│   ├── images/                # UI images
│   └── common/                # UI utilities
├── common/                    # Hardware abstraction layer
│   ├── sys_manager/           # System management (WiFi, backlight, etc.)
│   ├── gpio_manager/          # GPIO control
│   └── event_manager/         # Event handling
└── utils/                     # Utilities
    ├── system_para.conf       # System parameters (API keys, settings)
    ├── gaode_adcode.json      # City code database for weather
    └── cacert.pem             # SSL certificates
```

### AIChat_demo Architecture

```
AIChat_demo/
├── Client/                    # Device-side (C++)
│   ├── Application/           # Application logic
│   │   ├── UserStates/        # State machine states
│   │   ├── IntentsRegistry.cc # Intent registration
│   │   └── StateConfig.cc     # State configuration
│   ├── WebSocket/             # WebSocket client
│   ├── Audio/                 # Audio capture/playback
│   ├── Events/                # Event system
│   ├── Utils/                 # Utilities
│   ├── Intent/                # Intent classification
│   ├── StateMachine/          # State machine implementation
│   ├── third_party/           # Third-party libraries
│   │   └── snowboy/           # Wake word detection
│   ├── c_interface/           # C interface for LVGL integration
│   └── main.cc                # Entry point
└── Server/                    # Server-side (Python)
    ├── main.py                # Entry point
    ├── ws_server.py           # WebSocket server
    ├── service_manager.py     # Service management
    ├── config/                # Configuration
    ├── handle/                # Request handlers
    ├── services/              # Business services
    ├── models/                # ML models (VAD, ASR)
    ├── threads/               # Thread management
    └── tools/                 # Utilities
```

---

## Communication Protocols

### AIChat WebSocket Protocol

**Connection:** Client connects to Server via WebSocket

**Authentication Headers:**
```
Authorization: Bearer <access_token>
Device-Id: <MAC address>
Protocol-Version: <version>
```

**JSON Message Types:**

Client → Server:
- `hello`: Initial handshake with audio params
- `state`: State changes (idle, listening, etc.)
- `reg_func`: Register available functions

Server → Client:
- `auth`: Authentication result
- `vad`: Voice activity detection state
- `asr`: Speech recognition result
- `tts`: TTS generation status
- `chat`: Dialogue status

**Binary Protocol for Audio:**
```c
struct BinProtocol {
    uint16_t version;       // Protocol version
    uint16_t type;          // 0 = audio data
    uint32_t payload_size;  // Audio data length
    uint8_t payload[];      // Opus audio data
} __attribute__((packed));
```

---

## Configuration Files

### System Parameters (`utils/system_para.conf`)

Key settings that MUST be customized before use:

```ini
# Time settings
year=2025
month=1
day=1
hour=0
minute=0

# Display/Audio
brightness=50
sound=50

# Network
wifi_connected=false

# Location (for weather)
city=东城区
adcode=110101
gaode_api_key=YOUR_GAODE_API_KEY_HERE  # REQUIRED: Get from https://lbs.amap.com/

# AI Chat Server
AIChat_server_url=172.32.0.100
AIChat_server_port=8000
AIChat_server_token=123456
AIChat_Client_ID=00:11:22:33:44:55
aliyun_api_key=YOUR_ALIYUN_API_KEY_HERE  # REQUIRED: Get from https://www.aliyun.com/
```

### Device Configuration (`conf/dev_conf.h`)

```c
#define LV_USE_SIMULATOR 0  // 1 = SDL simulator, 0 = hardware
```

When `LV_USE_SIMULATOR = 1`:
- Uses SDL2 for display and mouse input
- For testing on PC

When `LV_USE_SIMULATOR = 0`:
- Uses Linux FBDev for display
- Uses evdev for touchscreen
- For running on actual hardware

---

## Development Workflow

### Adding a New Page to DeskBot

1. Copy template:
   ```bash
   cp -r gui_app/pages/ui_template gui_app/pages/ui_MyNewPage
   ```

2. Rename files and update content

3. Add to `gui_app/CMakeLists.txt`

4. Implement page logic following existing patterns

### Docker Development Environment

```bash
# Build and run container
docker-compose up -d

# Enter container
docker exec -it echo-mate /bin/bash

# Inside container, build as usual
cd /project/Demo/DeskBot_demo
mkdir build && cd build
cmake ..
make
```

---

## Deployment

### Flashing Firmware

**SD Card Method:**
1. Format SD card with "SD Card Formatter"
2. Use Rockchip SocToolKit to flash images from `SDK/rv1106-sdk/output/`
3. Insert SD card into board

**NAND Flash Method:**
1. Hold BOOT button, connect USB to PC, release BOOT
2. Board enters Maskrom mode
3. Use SocToolKit to flash firmware

### Running DeskBot on Board

```bash
# Copy bin folder to board
scp -r ./bin root@172.32.0.93:/root

# On board
cd /root/bin
./main
```

### Network Setup on Board

```bash
# Enable WiFi
ifconfig wlan0 up

# Configure WiFi (edit /etc/wpa_supplicant.conf)
vi /etc/wpa_supplicant.conf

# Connect
mkdir -p /var/run/wpa_supplicant
wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlan0
udhcpc -i wlan0
```

---

## Testing

### Unit Testing
- No formal test framework is currently integrated
- Test individual demos independently before integration

### Integration Testing
1. Build and run Server on PC
2. Build and run Client on board (or PC for testing)
3. Verify WebSocket connection
4. Test voice interaction flow

### Simulator Testing
Use SDL simulator to test UI changes without hardware:
```bash
cd Demo/DeskBot_demo/build
cmake ..
make
../bin/main
```

---

## Security Considerations

1. **API Keys:** Never commit real API keys to git. Use placeholder values in config files.

2. **Access Tokens:** The AIChat Server uses access tokens for client authentication. Change default tokens in production.

3. **Network:** Default configuration assumes a local network. Secure your WiFi appropriately.

4. **SSL:** `cacert.pem` is included for HTTPS requests. Keep it updated.

---

## Troubleshooting

### Build Issues

**SDK build fails:**
- Check network connection (buildroot downloads packages)
- Try changing buildroot mirror or manually download packages to `dl/` folder

**CMake can't find libraries:**
- Ensure SDK is fully built before cross-compiling demos
- Verify `CMAKE_SYSROOT` path in `toolchain.cmake`

**LVGL display issues:**
- Check `dev_conf.h` for correct display backend
- Verify framebuffer device permissions (`/dev/fb0`)

### Runtime Issues

**AIChat connection fails:**
- Verify Server is running and accessible
- Check firewall settings
- Confirm IP address and port in `system_para.conf`

**No audio:**
- Check ALSA configuration
- Verify microphone and speaker connections

**Touch not working:**
- Check `/dev/input/event0` exists
- Verify evdev permissions

---

## Resources

- **Hardware Open Source:** https://oshwhub.com/no_chicken/ai-desktop-robot-echo
- **Documentation:** https://no-chicken.com/
- **Demo Video:** https://www.bilibili.com/video/BV161ZaYyEmF/
- **Luckfox Wiki:** https://wiki.luckfox.com/

---

## License

See LICENSE file in project root.
