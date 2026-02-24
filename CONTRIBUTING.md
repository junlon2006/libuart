# Contributing to libUartCommProtocol

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/libUartCommProtocol.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`

## Development Setup

### Prerequisites
- GCC compiler with C99 support
- pthread library
- Make or CMake

### Building
```bash
# Using Make
make

# Using CMake
mkdir build && cd build
cmake ..
make
```

## Code Style

- Follow the existing code style in the project
- Use 2 spaces for indentation
- Keep lines under 80 characters when possible
- Add comments for complex logic
- Use descriptive variable and function names

## Testing

Before submitting a pull request:

1. Build the project without warnings
2. Run the benchmark examples:
   ```bash
   ./peera &
   ./peerb
   ```
3. Verify no memory leaks (use valgrind if available)

## Submitting Changes

1. Commit your changes with clear, descriptive messages
2. Push to your fork
3. Submit a pull request to the main repository
4. Describe your changes and the problem they solve

## Reporting Issues

When reporting issues, please include:
- Operating system and version
- Compiler version
- Steps to reproduce the issue
- Expected vs actual behavior
- Any relevant logs or error messages

## License

By contributing, you agree that your contributions will be licensed under the GPL-2.0 License.

## Contact

- Email: junlon2006@163.com
- GitHub Issues: https://github.com/junlon2006/libUartCommProtocol/issues
