# Protocol Specification

## Overview

The UART Communication Protocol provides reliable and unreliable data transmission over serial interfaces, similar to TCP and UDP over IP networks.

## Frame Format

### Complete Frame Structure

```
+--------+-----+------+-----+-------+-----+--------+---------+
| Sync   | Seq | Ctrl | Cmd | CRC16 | Len | LenCRC | Payload |
+--------+-----+------+-----+-------+-----+--------+---------+
| 6 bytes| 1B  | 1B   | 2B  | 2B    | 2B  | 2B     | N bytes |
+--------+-----+------+-----+-------+-----+--------+---------+
```

**Total Header Size**: 16 bytes

### Field Descriptions

#### 1. Sync (6 bytes)
- **Value**: `"uArTcP"` (0x75 0x41 0x72 0x54 0x63 0x50)
- **Purpose**: Frame synchronization and detection

#### 2. Sequence (1 byte)
- **Range**: 0-255
- **Purpose**: Packet ordering and duplicate detection
- **Behavior**: Increments for each new packet, wraps at 255

#### 3. Control (1 byte)
- **Bit 0 (ACK)**: Packet requires acknowledgment
- **Bit 1 (ACKED)**: This is an acknowledgment packet
- **Bit 2 (NACK)**: Negative acknowledgment (request retransmission)
- **Bits 3-7**: Reserved (must be 0)

```
+---+---+---+---+---+------+-------+-----+
| 7 | 6 | 5 | 4 | 3 |  2   |   1   |  0  |
+---+---+---+---+---+------+-------+-----+
|RES|RES|RES|RES|RES| NACK | ACKED | ACK |
+---+---+---+---+---+------+-------+-----+
```

#### 4. Command (2 bytes, big-endian)
- **Range**: 0-65535
- **Purpose**: Application-defined command type
- **Value**: 0 for ACK/NACK frames

#### 5. CRC16 (2 bytes, big-endian)
- **Algorithm**: CRC-16
- **Coverage**: Entire frame (header + payload)
- **Purpose**: Data integrity verification

#### 6. Length (2 bytes, big-endian)
- **Range**: 0-8192
- **Purpose**: Payload length in bytes
- **Value**: 0 for ACK/NACK frames

#### 7. Length CRC16 (2 bytes, big-endian)
- **Algorithm**: CRC-16
- **Coverage**: Length field only
- **Purpose**: Early detection of corrupted length field

#### 8. Payload (N bytes)
- **Maximum Size**: 8192 bytes
- **Recommended Size**: 512 bytes
- **Content**: Application data

---

## Frame Types

### 1. Data Frame (Unreliable)

```
Sync: "uArTcP"
Seq: <sequence_number>
Ctrl: 0x00 (no ACK required)
Cmd: <user_command>
CRC16: <calculated>
Len: <payload_length>
LenCRC: <calculated>
Payload: <user_data>
```

### 2. Data Frame (Reliable)

```
Sync: "uArTcP"
Seq: <sequence_number>
Ctrl: 0x01 (ACK bit set)
Cmd: <user_command>
CRC16: <calculated>
Len: <payload_length>
LenCRC: <calculated>
Payload: <user_data>
```

### 3. ACK Frame

```
Sync: "uArTcP"
Seq: <acknowledged_sequence>
Ctrl: 0x02 (ACKED bit set)
Cmd: 0x0000
CRC16: <calculated>
Len: 0x0000
LenCRC: <calculated>
Payload: (none)
```

### 4. NACK Frame

```
Sync: "uArTcP"
Seq: <failed_sequence>
Ctrl: 0x04 (NACK bit set)
Cmd: 0x0000
CRC16: <calculated>
Len: 0x0000
LenCRC: <calculated>
Payload: (none)
```

---

## Protocol Behavior

### Reliable Transmission (TCP-like)

1. **Send**: Transmit frame with ACK bit set
2. **Wait**: Wait for ACK (timeout: 200ms)
3. **Retry**: If timeout, retransmit (max 5 attempts)
4. **Success**: Receive ACK with matching sequence number
5. **Failure**: Return error after max retries

**Flow Diagram:**
```
Sender                          Receiver
  |                                |
  |------ Data (ACK=1, Seq=N) ---->|
  |                                | (Verify CRC)
  |<----- ACK (Seq=N) -------------|
  |                                |
  | (Next packet)                  |
```

### Unreliable Transmission (UDP-like)

1. **Send**: Transmit frame with ACK bit clear
2. **Continue**: No waiting, no retransmission

**Flow Diagram:**
```
Sender                          Receiver
  |                                |
  |------ Data (ACK=0, Seq=N) ---->|
  |                                | (Verify CRC)
  | (Next packet immediately)      |
```

### Error Handling

#### CRC Failure
```
Sender                          Receiver
  |                                |
  |------ Data (Seq=N) ----------->|
  |                                | (CRC Error)
  |<----- NACK (Seq=N) ------------|
  |                                |
  |------ Data (Seq=N) ----------->| (Retransmit)
  |                                |
```

#### Length CRC Failure
- Receiver sends NACK immediately
- Sender retransmits entire frame

#### Duplicate Detection
- Receiver tracks last received sequence number
- Duplicate frames are acknowledged but not delivered to application

---

## Timing Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| ACK Timeout | 200 ms | Time to wait for ACK |
| Retry Count | 5 | Maximum retransmission attempts |
| Baud Rate | 921600 | Recommended UART speed |

---

## Performance Characteristics

### Bandwidth Utilization

**Reliable Mode (ACK=1):**
- Overhead: 16 bytes header + ACK frame
- Efficiency: ~71% at 512-byte payload
- Throughput: ~64 KB/s at 921600 bps

**Unreliable Mode (ACK=0):**
- Overhead: 16 bytes header only
- Efficiency: ~84.5% at 512-byte payload
- Throughput: ~94 KB/s at 921600 bps

### Memory Usage

- **Static**: ~1 KB (protocol state)
- **Dynamic**: Grows with payload size (max 8 KB)
- **RWND**: 1 (single outstanding packet)

---

## Endianness

All multi-byte fields use **big-endian** byte order:
- Command (2 bytes)
- CRC16 (2 bytes)
- Length (2 bytes)
- Length CRC16 (2 bytes)

**Example:**
```c
uint16_t cmd = 0x1234;
// Wire format: [0x12, 0x34]
```

---

## State Machine

### Sender States
1. **IDLE**: Ready to send
2. **WAITING_ACK**: Packet sent, waiting for ACK
3. **RETRANSMIT**: Timeout, retransmitting

### Receiver States
1. **SYNC**: Searching for sync pattern
2. **HEADER**: Receiving header fields
3. **PAYLOAD**: Receiving payload data
4. **VALIDATE**: Verifying CRC

---

## Limitations

1. **Window Size**: RWND=1 (no pipelining)
2. **Max Payload**: 8192 bytes
3. **Sequence Space**: 256 (8-bit sequence number)
4. **Platform**: POSIX/Linux only (current version)

---

## Future Enhancements

- Sliding window protocol (RWND > 1)
- Selective acknowledgment (SACK)
- Congestion control
- Flow control
- Compression support
