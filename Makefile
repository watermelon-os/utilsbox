CC = gcc
CFLAGS = -Wall -Wextra -g

SRC_DIR = src
BUILD_DIR = build

TOOLS   = $(patsubst $(SRC_DIR)/%/main.c,%,$(wildcard $(SRC_DIR)/*/main.c))
TARGETS = $(addprefix $(BUILD_DIR)/,$(TOOLS))

all: $(TARGETS)

# компиляция + линковка одной командой (для однофайловых утилит)
$(BUILD_DIR)/%: $(SRC_DIR)/%/main.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $<

# запуск конкретной утилиты: make run TOOL=watermelon
TOOL ?= $(firstword $(TOOLS))
run: $(BUILD_DIR)/$(TOOL)
	$(BUILD_DIR)/$(TOOL)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean