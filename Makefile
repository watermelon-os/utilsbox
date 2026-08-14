CC = gcc
CFLAGS = -Wall -Wextra -g

SRC_DIR = src
COMMON_DIR = $(SRC_DIR)/common
BUILD_DIR = build

TOOLS   = $(patsubst $(SRC_DIR)/%/main.c,%,$(wildcard $(SRC_DIR)/*/main.c))
TARGETS = $(addprefix $(BUILD_DIR)/,$(TOOLS))

COMMON_OBJS = $(patsubst $(COMMON_DIR)/%.c,$(BUILD_DIR)/common/%.o,$(wildcard $(COMMON_DIR)/*.c))

all: $(TARGETS)

# общий код: common/*.c -> build/common/*.o
$(BUILD_DIR)/common/%.o: $(COMMON_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(COMMON_DIR) -c $< -o $@

# утилита: main.c + общие объектники
$(BUILD_DIR)/%: $(SRC_DIR)/%/main.c $(COMMON_OBJS)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(COMMON_DIR) -o $@ $< $(COMMON_OBJS)

# запуск конкретной утилиты: make run TOOL=watermelon-ps
TOOL ?= $(firstword $(TOOLS))
run: $(BUILD_DIR)/$(TOOL)
	$(BUILD_DIR)/$(TOOL)


TOPDIR  := $(CURDIR)/.rpmbuild   # свой топдир на проект
SPEC    := $(NAME).spec

rpm: $(TARGETS)
	# компиляция
	# подготовка топдир
	# именованный перенос спеки, бинарного файла в сурс и других файлов для установки
	# запуск рпмбилд

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean fff/cc/ww.a fff/cc/ww.b

%.fo: %.a %.b
	@echo $^ 
	@echo $@
	@echo $<
	@echo $*

print:
	@echo $(TOOLS)
	@echo $(TARGETS)