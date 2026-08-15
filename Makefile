# Проектный Makefile: делегирует сборку в Makefile каждого тула через -f,
# чтобы cwd оставался корнем проекта. Тулзовые Makefile всегда запускаются из корня.

TOOLS = watermelon-ps

BUILD_DIR = .build
SRC_DIR = tools

all: $(addprefix all-,$(TOOLS))

install: $(addprefix install-,$(TOOLS))

uninstall: $(addprefix uninstall-,$(TOOLS))

clean: $(addprefix clean-,$(TOOLS))

all-%:
	$(MAKE) -f $(SRC_DIR)/$*/Makefile BUILD_DIR=$(CURDIR)/$(BUILD_DIR)/$*

install-%:
	$(MAKE) -f $(SRC_DIR)/$*/Makefile install BUILD_DIR=$(CURDIR)/$(BUILD_DIR)/$*

uninstall-%:
	$(MAKE) -f $(SRC_DIR)/$*/Makefile uninstall BUILD_DIR=$(CURDIR)/$(BUILD_DIR)/$*

clean-%:
	$(MAKE) -f $(SRC_DIR)/$*/Makefile clean BUILD_DIR=$(CURDIR)/$(BUILD_DIR)/$*


.PHONY: all install uninstall clean \
	all-% install-% uninstall-% clean-%
