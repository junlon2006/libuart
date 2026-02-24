# Makefile for libUartCommProtocol

CC = gcc
CFLAGS = -std=gnu99 -Wall -Werror -O2 -Iinc -Iutils
LDFLAGS = -lpthread

# Source files
CORE_SRCS = src/uni_communication.c
UTIL_SRCS = utils/uni_crc16.c utils/uni_log.c utils/uni_interruptable.c
EXAMPLE_A_SRC = benchmark/peer_a.c
EXAMPLE_B_SRC = benchmark/peer_b.c

# Object files
CORE_OBJS = $(CORE_SRCS:.c=.o)
UTIL_OBJS = $(UTIL_SRCS:.c=.o)

# Targets
TARGETS = peera peerb

.PHONY: all clean examples format

all: $(TARGETS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

peera: $(CORE_OBJS) $(UTIL_OBJS) $(EXAMPLE_A_SRC)
	$(CC) $(CFLAGS) -o $@ $(CORE_SRCS) $(UTIL_SRCS) $(EXAMPLE_A_SRC) $(LDFLAGS)

peerb: $(CORE_OBJS) $(UTIL_OBJS) $(EXAMPLE_B_SRC)
	$(CC) $(CFLAGS) -o $@ $(CORE_SRCS) $(UTIL_SRCS) $(EXAMPLE_B_SRC) $(LDFLAGS)

examples: $(TARGETS)

format:
	clang-format -i src/*.c inc/*.h utils/*.c utils/*.h benchmark/*.c

clean:
	rm -f $(TARGETS) $(CORE_OBJS) $(UTIL_OBJS)
	rm -f /tmp/uart-mock-a /tmp/uart-mock-b

help:
	@echo "Available targets:"
	@echo "  all       - Build all examples (default)"
	@echo "  peera     - Build peer A example"
	@echo "  peerb     - Build peer B example"
	@echo "  examples  - Build all examples"
	@echo "  format    - Format code with clang-format"
	@echo "  clean     - Remove built files and FIFOs"
	@echo "  help      - Show this help message"
