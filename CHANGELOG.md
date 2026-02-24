# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2020-03-04

### Added
- Initial release of libUartCommProtocol
- TCP-like reliable transmission with ACK/NACK
- UDP-like unreliable transmission
- Full-duplex communication support
- CRC16 checksum for data integrity
- Automatic retransmission mechanism
- Low memory footprint (~1KB)
- Support for both big-endian and little-endian architectures
- Benchmark examples (peer_a and peer_b)
- POSIX/Linux platform support

### Performance
- TCP mode: 64 KB/s at 921600 bps (71% bandwidth utilization)
- UDP mode: 94 KB/s at 921600 bps (84.5% bandwidth utilization)
- Tested on RT-Thread RTOS

## [Unreleased]

### Planned
- Windows platform support
- Additional examples
- Unit tests
- Performance optimizations
