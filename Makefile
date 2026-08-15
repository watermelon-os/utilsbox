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


PKG_VERSION := $(subst dirty,$(shell date +%Y%m%d%H%M),$(shell git describe --always --dirty))
PKG_RPM_TOPDIR  := $(CURDIR)/.rpmbuild
PKG_RPM_BUILDDIR := $(PKG_RPM_TOPDIR)/BUILD
PKG_RPM_BUILDROOTDIR := $(PKG_RPM_TOPDIR)/BUILDROOT
PKG_RPM_SOURCESDIR := $(PKG_RPM_TOPDIR)/SOURCES
PKG_RPM_SPECSDIR := $(PKG_RPM_TOPDIR)/SPECS
PKG_RPM_RPMSDIR := $(PKG_RPM_TOPDIR)/RPMS
PKG_RPM_SRPMSDIR := $(PKG_RPM_TOPDIR)/SRPMS

PKG_RPM_SPECSSRC := $(foreach t,$(TOOLS),$(CURDIR)/$(SRC_DIR)/$(t)/$(t).spec)

rpm: all
	@mkdir -p $(PKG_RPM_BUILDDIR) \
		$(PKG_RPM_BUILDROOTDIR) \
		$(PKG_RPM_SOURCESDIR) \
		$(PKG_RPM_SPECSDIR) \
		$(PKG_RPM_RPMSDIR) \
		$(PKG_RPM_SRPMSDIR)
	@for t in $(TOOLS); do \
		cp $(CURDIR)/$(BUILD_DIR)/$$t $(PKG_RPM_BUILDDIR)/$$t-$(PKG_VERSION); \
	done
	@for s in $(PKG_RPM_SPECSSRC); do \
		cp $$s $(PKG_RPM_SPECSDIR)/$$(basename $$s); \
	done
# 	rpmbuild --define '_topdir $(PKG_RPM_TOPDIR)' -bb $(SPEC)

.PHONY: all install uninstall clean rpm \
	all-% install-% uninstall-% clean-%
