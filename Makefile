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


PKG_VERSION := $(subst dirty,$(shell date +%Y%m%d%H%M),$(shell git describe --always --dirty)) # хеш коммита; если дерево грязное — хеш + время сборки
PKG_RPM_TOPDIR  := $(CURDIR)/.rpmbuild
PKG_RPM_BUILDDIR := $(PKG_RPM_TOPDIR)/BUILD
PKG_RPM_BUILDROOTDIR := $(PKG_RPM_TOPDIR)/BUILDROOT
PKG_RPM_SOURCESDIR := $(PKG_RPM_TOPDIR)/SOURCES
PKG_RPM_SPECSDIR := $(PKG_RPM_TOPDIR)/SPECS
PKG_RPM_RPMSDIR := $(PKG_RPM_TOPDIR)/RPMS
PKG_RPM_SRPMSDIR := $(PKG_RPM_TOPDIR)/SRPMS

PKG_RPM_SPECSSRC    := $(foreach t,$(TOOLS),$(CURDIR)/$(SRC_DIR)/$(t)/$(t).spec)


DISTS := $(foreach t,$(TOOLS),$(PKG_RPM_BUILDDIR)/$(t)-$(PKG_VERSION))


# SPEC    := $(NAME).spec
rpm: $(TARGETS)
	@mkdir -p $(PKG_RPM_BUILDDIR) \
		$(PKG_RPM_BUILDROOTDIR) \
		$(PKG_RPM_SOURCESDIR) \
		$(PKG_RPM_SPECSDIR) \
		$(PKG_RPM_RPMSDIR) \
		$(PKG_RPM_SRPMSDIR)
	@for t in $(TOOLS); do \
		cp $(BUILD_DIR)/$$t $(PKG_RPM_BUILDDIR)/$$t-$(PKG_VERSION); \
	done
	@for s in $(PKG_RPM_SPECSSRC); do \
		cp $$s $(PKG_RPM_SPECSDIR)/$$(basename $$s); \
	done
	@for spec in $(PKG_RPM_SPECSDIR)/*.spec; do \
		echo "$$spec"; \
	done
# 	rpmbuild --define '_topdir $(PKG_RPM_TOPDIR)' -bb $(SPEC)

	# именованный перенос спеки, бинарного файла в сурс и других файлов для установки
	# запуск рпмбилд

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean rpm print

print:
	@echo $(CURDIR)
	@echo $(DISTS)
	@echo $(PKG_RPM_SPECSSRC)
	@for s in $(PKG_RPM_SPECSSRC); do \
		echo $$s $(PKG_RPM_SPECSDIR)/$$(basename $$s); \
	done
	