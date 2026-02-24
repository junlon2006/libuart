# libUartCommProtocol

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20POSIX-lightgrey.svg)](https://en.wikipedia.org/wiki/POSIX)

[English](#english) | [中文](#中文)

---

## English

### Overview

A lightweight, reliable UART communication protocol library that provides TCP/UDP-like features for serial communication. Designed for embedded systems with minimal memory footprint (~1KB).

**Cross-platform version**: [libUartCommProtocolV2](https://github.com/junlon2006/libUartCommProtocolV2)

### Features

- ✅ **TCP-like reliable transmission** with ACK/NACK mechanism
- ✅ **UDP-like unreliable transmission** for high throughput
- ✅ **Low memory usage** (~1KB total, RWND=1)
- ✅ **Full-duplex** communication
- ✅ **Endian-agnostic** (supports both big-endian and little-endian)
- ✅ **CRC16 checksum** for data integrity
- ✅ **Automatic retransmission** on packet loss
- ✅ **TFTP-like protocol stack** design

### Performance

| Mode | Baud Rate | Payload Size | Throughput | Bandwidth Ratio | Memory Usage |
|------|-----------|--------------|------------|-----------------|---------------|
| TCP-like (reliable) | 921600 bps | 512 bytes | ~64 KB/s | ~71% | ~1 KB |
| UDP-like (unreliable) | 921600 bps | 512 bytes | ~94 KB/s | ~84.5% | ~1 KB |

**Note**: Performance tested on RT-Thread RTOS. Symbol error rate: 1 bit per 1,000,000 bits.

### Quick Start

#### Prerequisites

- GCC with C99 support
- pthread library
- Linux/POSIX compatible system

#### Building

```bash
# Using Make
make

# Or using CMake
mkdir build && cd build
cmake ..
make
```

#### Running Examples

```bash
# Terminal 1
./peera

# Terminal 2
./peerb
```

### API Usage

#### Initialization

```c
#include "uni_communication.h"

// Define write handler (e.g., UART write function)
int uart_write(char *buf, int len) {
    // Your UART write implementation
    return len;
}

// Define receive handler
void on_packet_received(CommPacket *packet) {
    printf("Received cmd=%d, len=%d\n", packet->cmd, packet->payload_len);
    // Process received data
}

// Initialize protocol
CommProtocolInit(uart_write, on_packet_received);
```

#### Sending Data

```c
// Reliable transmission (TCP-like)
CommAttribute attr = { .reliable = 1 };
char payload[512] = "Hello World";
CommProtocolPacketAssembleAndSend(1, payload, strlen(payload), &attr);

// Unreliable transmission (UDP-like)
CommAttribute attr_udp = { .reliable = 0 };
CommProtocolPacketAssembleAndSend(2, payload, strlen(payload), &attr_udp);
```

#### Receiving Data

```c
// Feed UART data to protocol stack
unsigned char uart_buffer[1024];
int len = uart_read(uart_buffer, sizeof(uart_buffer));
CommProtocolReceiveUartData(uart_buffer, len);
```

#### Cleanup

```c
CommProtocolFinal();
```

### Protocol Frame Format

```
+--------+-----+------+-----+-------+-----+--------+---------+
| Sync   | Seq | Ctrl | Cmd | CRC16 | Len | LenCRC | Payload |
| 6 bytes| 1B  | 1B   | 2B  | 2B    | 2B  | 2B     | N bytes |
+--------+-----+------+-----+-------+-----+--------+---------+
  "uArTcP"
```

**Control Bits**:
- Bit 0: ACK (needs acknowledgment)
- Bit 1: ACKED (is acknowledgment packet)
- Bit 2: NACK (negative acknowledgment)

### Configuration

- **Recommended payload size**: 512 bytes
- **Maximum payload size**: 8192 bytes
- **ACK timeout**: 200ms (configurable)
- **Retry attempts**: 5 times

### Performance Notes

- CRC16 checksum accounts for ~30% of processing overhead
- RWND=1 design prioritizes memory efficiency over throughput
- For higher performance, consider [TCP checksum algorithm](https://github.com/junlon2006/linux-c/issues/96)

### Project Structure

```
libuart/
├── inc/                    # Public headers
│   └── uni_communication.h
├── src/                    # Core implementation
│   └── uni_communication.c
├── utils/                  # Utility modules
│   ├── uni_crc16.c/h      # CRC16 checksum
│   ├── uni_log.c/h        # Logging system
│   └── uni_interruptable.c/h  # Interruptable sleep
├── benchmark/              # Example programs
│   ├── peer_a.c
│   └── peer_b.c
├── Makefile               # Build system
├── CMakeLists.txt         # CMake build
└── README.md              # This file
```

### Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### License

GPL-2.0 License. See [LICENSE](LICENSE) for details.

### Author

- **Junlon2006** - junlon2006@163.com

### Benchmark Results

![Benchmark](benchmark/images/logger.png)

---

## 中文

### 概述

轻量级、可靠的 UART 通信协议库，为串口通信提供类似 TCP/UDP 的特性。专为嵌入式系统设计，内存占用极小（约 1KB）。

**跨平台版本**: [libUartCommProtocolV2](https://github.com/junlon2006/libUartCommProtocolV2)

### 特性

- ✅ **类 TCP 可靠传输**，支持 ACK/NACK 机制
- ✅ **类 UDP 不可靠传输**，高吞吐量
- ✅ **低内存占用**（总共约 1KB，RWND=1）
- ✅ **全双工**通信
- ✅ **字节序无关**（支持大端和小端）
- ✅ **CRC16 校验和**保证数据完整性
- ✅ **自动重传**机制
- ✅ **类 TFTP 协议栈**设计

### 性能指标

| 模式 | 波特率 | 负载大小 | 吞吐量 | 带宽利用率 | 内存占用 |
|------|--------|----------|--------|-----------|----------|
| 类 TCP（可靠） | 921600 bps | 512 字节 | ~64 KB/s | ~71% | ~1 KB |
| 类 UDP（不可靠） | 921600 bps | 512 字节 | ~94 KB/s | ~84.5% | ~1 KB |

**说明**: 性能在 RT-Thread RTOS 上测试。符号错误率：每 100 万比特 1 比特错误。

### 快速开始

#### 环境要求

- 支持 C99 的 GCC 编译器
- pthread 库
- Linux/POSIX 兼容系统

#### 编译

```bash
# 使用 Make
make

# 或使用 CMake
mkdir build && cd build
cmake ..
make
```

#### 运行示例

```bash
# 终端 1
./peera

# 终端 2
./peerb
```

### API 使用

#### 初始化

```c
#include "uni_communication.h"

// 定义写入处理函数（如 UART 写函数）
int uart_write(char *buf, int len) {
    // 你的 UART 写实现
    return len;
}

// 定义接收处理函数
void on_packet_received(CommPacket *packet) {
    printf("收到 cmd=%d, len=%d\n", packet->cmd, packet->payload_len);
    // 处理接收到的数据
}

// 初始化协议
CommProtocolInit(uart_write, on_packet_received);
```

#### 发送数据

```c
// 可靠传输（类 TCP）
CommAttribute attr = { .reliable = 1 };
char payload[512] = "Hello World";
CommProtocolPacketAssembleAndSend(1, payload, strlen(payload), &attr);

// 不可靠传输（类 UDP）
CommAttribute attr_udp = { .reliable = 0 };
CommProtocolPacketAssembleAndSend(2, payload, strlen(payload), &attr_udp);
```

#### 接收数据

```c
// 将 UART 数据喂给协议栈
unsigned char uart_buffer[1024];
int len = uart_read(uart_buffer, sizeof(uart_buffer));
CommProtocolReceiveUartData(uart_buffer, len);
```

#### 清理

```c
CommProtocolFinal();
```

### 协议帧格式

```
+--------+-----+------+-----+-------+-----+--------+---------+
| 同步头 | 序号| 控制 | 命令| CRC16 | 长度| 长度CRC| 负载    |
| 6字节  | 1B  | 1B   | 2B  | 2B    | 2B  | 2B     | N字节   |
+--------+-----+------+-----+-------+-----+--------+---------+
  "uArTcP"
```

**控制位**：
- 位 0: ACK（需要确认）
- 位 1: ACKED（是确认包）
- 位 2: NACK（否定确认）

### 配置说明

- **推荐负载大小**: 512 字节
- **最大负载大小**: 8192 字节
- **ACK 超时**: 200ms（可配置）
- **重试次数**: 5 次

### 性能说明

- CRC16 校验和约占 30% 的处理开销
- RWND=1 设计优先考虑内存效率而非吞吐量
- 如需更高性能，可考虑使用 [TCP checksum 算法](https://github.com/junlon2006/linux-c/issues/96)

### 项目结构

```
libuart/
├── inc/                    # 公共头文件
│   └── uni_communication.h
├── src/                    # 核心实现
│   └── uni_communication.c
├── utils/                  # 工具模块
│   ├── uni_crc16.c/h      # CRC16 校验
│   ├── uni_log.c/h        # 日志系统
│   └── uni_interruptable.c/h  # 可中断睡眠
├── benchmark/              # 示例程序
│   ├── peer_a.c
│   └── peer_b.c
├── Makefile               # 构建系统
├── CMakeLists.txt         # CMake 构建
└── README.md              # 本文件
```

### 贡献

欢迎贡献！详情请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

### 许可证

GPL-2.0 许可证。详见 [LICENSE](LICENSE)。

### 作者

- **Junlon2006** - junlon2006@163.com

### 性能测试结果

![性能测试](benchmark/images/logger.png)
