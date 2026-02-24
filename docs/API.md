# API Reference

## Table of Contents

- [Initialization](#initialization)
- [Data Transmission](#data-transmission)
- [Data Reception](#data-reception)
- [Cleanup](#cleanup)
- [Data Types](#data-types)
- [Error Codes](#error-codes)

---

## Initialization

### CommProtocolInit

Initialize the communication protocol.

```c
int CommProtocolInit(CommWriteHandler write_handler, 
                     CommRecvPacketHandler recv_handler);
```

**Parameters:**
- `write_handler`: Function pointer for writing data to UART
- `recv_handler`: Callback function for received packets

**Returns:**
- `0` on success
- `-1` on failure

**Example:**
```c
int uart_write(char *buf, int len) {
    return write(uart_fd, buf, len);
}

void on_packet_received(CommPacket *packet) {
    printf("Received: cmd=%d, len=%d\n", packet->cmd, packet->payload_len);
}

CommProtocolInit(uart_write, on_packet_received);
```

---

## Data Transmission

### CommProtocolPacketAssembleAndSend

Assemble and send a packet.

```c
int CommProtocolPacketAssembleAndSend(CommCmd cmd, 
                                      char *payload,
                                      CommPayloadLen payload_len,
                                      CommAttribute *attribute);
```

**Parameters:**
- `cmd`: Command type (user-defined)
- `payload`: Pointer to payload data (can be NULL)
- `payload_len`: Length of payload (0 if no payload)
- `attribute`: Transmission attributes (reliable/unreliable)

**Returns:**
- `0` on success
- `E_UNI_COMM_ALLOC_FAILED`: Memory allocation failed
- `E_UNI_COMM_PAYLOAD_TOO_LONG`: Payload exceeds maximum size
- `E_UNI_COMM_PAYLOAD_ACK_TIMEOUT`: ACK timeout (reliable mode)

**Example:**
```c
// Reliable transmission
CommAttribute attr = { .reliable = 1 };
char data[] = "Hello";
CommProtocolPacketAssembleAndSend(0x01, data, sizeof(data), &attr);

// Unreliable transmission
CommAttribute attr_udp = { .reliable = 0 };
CommProtocolPacketAssembleAndSend(0x02, data, sizeof(data), &attr_udp);

// No payload
CommProtocolPacketAssembleAndSend(0x03, NULL, 0, NULL);
```

---

## Data Reception

### CommProtocolReceiveUartData

Feed received UART data to the protocol stack.

```c
void CommProtocolReceiveUartData(unsigned char *buf, int len);
```

**Parameters:**
- `buf`: Buffer containing received UART data
- `len`: Length of received data

**Example:**
```c
unsigned char rx_buffer[1024];
int bytes_read = read(uart_fd, rx_buffer, sizeof(rx_buffer));
if (bytes_read > 0) {
    CommProtocolReceiveUartData(rx_buffer, bytes_read);
}
```

---

## Cleanup

### CommProtocolFinal

Finalize and cleanup the protocol.

```c
void CommProtocolFinal(void);
```

**Example:**
```c
CommProtocolFinal();
```

---

## Data Types

### CommPacket

Structure representing a received packet.

```c
typedef struct {
    CommCmd        cmd;         // Command type
    CommPayloadLen payload_len; // Payload length
    char*          payload;     // Pointer to payload data
} CommPacket;
```

### CommAttribute

Transmission attributes.

```c
typedef struct {
    uni_bool reliable;  // true = reliable (TCP-like), false = unreliable (UDP-like)
} CommAttribute;
```

### CommWriteHandler

Function pointer type for UART write operations.

```c
typedef int (*CommWriteHandler)(char *buf, int len);
```

**Returns:** Number of bytes written

### CommRecvPacketHandler

Function pointer type for packet reception callback.

```c
typedef void (*CommRecvPacketHandler)(CommPacket *packet);
```

---

## Error Codes

```c
typedef enum {
    E_UNI_COMM_ALLOC_FAILED = -10001,      // Memory allocation failed
    E_UNI_COMM_BUFFER_PTR_NULL,            // Buffer pointer is NULL
    E_UNI_COMM_PAYLOAD_TOO_LONG,           // Payload exceeds max size (8192 bytes)
    E_UNI_COMM_PAYLOAD_ACK_TIMEOUT,        // ACK timeout in reliable mode
} CommProtocolErrorCode;
```

---

## Configuration Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `WAIT_ACK_TIMEOUT_MSEC` | 200 | ACK timeout in milliseconds |
| `TRY_RESEND_TIMES` | 5 | Number of retransmission attempts |
| `PROTOCOL_BUF_SUPPORT_MAX_SIZE` | 8192 | Maximum payload size |

---

## Thread Safety

- `CommProtocolPacketAssembleAndSend()` is thread-safe (uses internal mutex)
- `CommProtocolReceiveUartData()` should be called from a single thread
- Multiple threads can send data concurrently

---

## Best Practices

1. **Payload Size**: Use 512 bytes for optimal performance
2. **Error Handling**: Always check return values
3. **Reliable Mode**: Use for critical data that must be delivered
4. **Unreliable Mode**: Use for time-sensitive data where occasional loss is acceptable
5. **Memory**: Protocol uses ~1KB of memory regardless of payload size
