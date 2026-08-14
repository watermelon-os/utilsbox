CC = gcc
CFLAGS = -Wall -Wextra -g

SRC_DIR = src
COMMON_DIR = $(SRC_DIR)/common
BUILD_DIR = .build

TOOLS = watermelon-ps
TARGETS = $(addprefix $(BUILD_DIR)/,$(TOOLS))

COMMON_OBJS = $(BUILD_DIR)/common/hello.o

all: $(TARGETS)

# общий код: common/*.c -> build/common/*.o
$(BUILD_DIR)/common/%.o: $(COMMON_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(COMMON_DIR) -c $< -o $@

# утилита: main.c + общие объектники
$(BUILD_DIR)/%: $(SRC_DIR)/%/main.c $(COMMON_OBJS)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(COMMON_DIR) -o $@ $< $(COMMON_OBJS)


NAME    := myapp
VERSION := $(subst  dirty,$(shell date +%Y%m%d%H%M),$(subst heads/,,$(shell git describe --all --dirty))) # коммит, а если dirty то комит и время сборки
TOPDIR  := $(CURDIR)/.rpmbuild   # свой топдир на проект
SPEC    := $(NAME).spec


$(DIST):
	mkdir -p $(TOPDIR)/{BUILD,BUILDROOT,SOURCES,SPECS,RPMS,SRPMS}
	git archive --format=tar --prefix=$(NAME)-$(VERSION)/ HEAD > $@
	cp $(SPEC) $(TOPDIR)/SPECS/


# SPEC    := $(NAME).spec
rpm: $(TARGETS)

	# компиляция
	# подготовка топдир
	# именованный перенос спеки, бинарного файла в сурс и других файлов для установки
	# запуск рпмбилд

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean

print:
	@echo $(CURDIR)
	@echo $(VERSION)