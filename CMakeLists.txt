cmake_minimum_required(VERSION 3.10)
project(libUartCommProtocol VERSION 1.0.0 LANGUAGES C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Compiler flags
add_compile_options(-Wall -Werror -O2)

# Include directories
include_directories(inc utils)

# Core library sources
set(CORE_SOURCES
    src/uni_communication.c
    utils/uni_crc16.c
    utils/uni_log.c
    utils/uni_interruptable.c
)

# Create static library
add_library(uartcomm STATIC ${CORE_SOURCES})
target_link_libraries(uartcomm pthread)

# Examples
option(BUILD_EXAMPLES "Build example programs" ON)

if(BUILD_EXAMPLES)
    add_executable(peera benchmark/peer_a.c)
    target_link_libraries(peera uartcomm pthread)

    add_executable(peerb benchmark/peer_b.c)
    target_link_libraries(peerb uartcomm pthread)
endif()

# Installation
install(TARGETS uartcomm
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(FILES inc/uni_communication.h
    DESTINATION include/uartcomm
)
