.PHONY: all install uninstall clean dist rpm

# CC/CFLAGS — стандартные имена make (часть соглашения GNU make, не проект-специфичные).
# Мотивация: одинаковые имена в любом проекте = одинаковые способы переопределения
# из командной строки:  make CC=clang CFLAGS="-O2". Компилятор по умолчанию уже задан
# самим make (cc), здесь лишь явно зафиксирован + заданы флаги предупреждений.
CC = gcc
# -MMD — рядом с каждым объектником пишется .d со списком его заголовков
# (включается внизу файла через -include), поэтому правка .h перезапускает пересборку.
CFLAGS = -Wall -Wextra -g -MMD

# VERSION — версия из git-тегов (единственный источник правды).
# git describe --tags: ближайший тег (v1.0.0), а если тегов нет — --always даёт хеш.
# --dirty добавляет суффикс при незакоммиченных изменениях.
# Мотивация: один источник версии — тег — рождает и имя tar (name-version),
# и Version в спеке, и -DVERSION при компиляции; они не разъезжаются.
# VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo 0.0.0-unknown)

# ВАЖНО: в RPM Version запрещён '-' (0x2d) — он служит разделителем Version/Release.
# Дату сборки в Version не вносим; за ней (при желании) следит Release.
VERSION = 0.1

# Версия попадает в бинарь на этапе компиляции через макрос VERSION.
CFLAGS += -DVERSION=\"$(VERSION)\"

# NAME — имя утилиты (бинарь, каталог сборки, man-файл, doc-каталог).
# Мотивация: единый источник истины — имя не дублируется текстом по всему Makefile,
# переименование/перенос утилиты = правка одной строки. Также даёт подсказку сборщику пакета.
NAME = utilsbox
NAMEVER = $(NAME)-$(VERSION)

# BUILD_DIR — куда кладутся результаты сборки.
# Мотивация: (1) сборка вне каталога исходников — чисто и легко чистить (make clean);
# (2) главное — переменная переопределяется проектным Makefile через командную строку,
#     чтобы собирать в корневой .build/, а не в локальной подпапке.
BUILD_DIR = .build

RPMBUILD_DIR = .rpmbuild

COMMON_DIR = src/common
PS_DIR = src/ps
CFLAGS += -I$(COMMON_DIR) -I$(PS_DIR)

# vpath позволяет правилу $(BUILD_DIR)/%.o находить исходники по подкаталогам src/:
# объектник лежит плоско (.build/common.o), а его .c — в своём подкаталоге.
vpath %.c $(COMMON_DIR) $(PS_DIR)

# COMMON_OBJ — объектник общего кода, который использует только эта утилита.
# Мотивация: удобство — один объект ссылается и в правиле сборки, и в списке зависимостей;
# если common/ расширится, здесь явно прописываются новые объектники по одному.
COMMON_OBJ = $(BUILD_DIR)/common.o
PS_OBJ = $(BUILD_DIR)/ps.o


include fhs.mk

all: $(BUILD_DIR)/$(NAME)

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(NAME): src/main.c $(COMMON_OBJ) $(PS_OBJ)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $< $(COMMON_OBJ) $(PS_OBJ)

# Release-сборка для пакета: -O2, затем strip убирает debug-инфу.
RELEASE_CFLAGS = $(CFLAGS) -O2
RELEASE_BIN = $(BUILD_DIR)/$(NAME)-release

$(RELEASE_BIN): src/main.c $(COMMON_OBJ) $(PS_OBJ)
	mkdir -p $(@D)
	$(CC) $(RELEASE_CFLAGS) -o $@ $< $(COMMON_OBJ) $(PS_OBJ)
	strip $@

# Внутри распакованного tar (rpmbuild) файлы лежат плоско в cwd, в дереве исходников —
# в BUILD_DIR. $(or $(wildcard ...)) берёт то, что реально есть на месте.
BIN := $(or $(wildcard $(NAME)),$(BUILD_DIR)/$(NAME))
MAN := $(or $(wildcard $(NAME).1),$(NAME).1)
LIC := $(or $(wildcard LICENSE),LICENSE)

# install не зависит от all: при сборке rpm бинарь уже в tar и пересборка не нужна.
# DESTDIR в переменные fhs.mk не входит — префиксуем правила сами (autoconf-схема).
install:
	install -d $(DESTDIR)$(bindir) $(DESTDIR)$(man1dir) $(DESTDIR)$(licensdir)
	install -m 755 $(BIN) $(DESTDIR)$(bindir)/$(NAME)
	install -m 644 $(MAN) $(DESTDIR)$(man1dir)/$(NAME).1
	install -m 644 $(LIC) $(DESTDIR)$(licensdir)/LICENSE

uninstall:
	rm -f $(DESTDIR)$(bindir)/$(NAME) \
		$(DESTDIR)$(man1dir)/$(NAME).1 \
		$(DESTDIR)$(licensdir)/LICENSE
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(licensdir) $(DESTDIR)$(docdir)

MKTEMP_TEMP := /tmp/edutoolsdist.XXX
clean:
	rm -rf $(BUILD_DIR) $(RPMBUILD_DIR)
	rm -rf $(subst XXX,*,$(MKTEMP_TEMP))

DIST_TAR_TMP_DIR = $(shell mktemp -d)
dist: $(RELEASE_BIN)
	$(eval TEMP_DIR := $(shell mktemp -d $(MKTEMP_TEMP)))
	$(eval TAR_TEMP_DIR := $(TEMP_DIR)/$(NAMEVER))
	mkdir -p $(RPMBUILD_DIR)/{SPECS,SOURCES} \
		$(TAR_TEMP_DIR)
	# поместить в плоскую структуру файлы для архива
	cp -f $(RELEASE_BIN) $(TAR_TEMP_DIR)/$(NAME)
	cp -f LICENSE $(TAR_TEMP_DIR)/
	cp -f $(NAME).1 $(TAR_TEMP_DIR)/
	cp -f Makefile $(TAR_TEMP_DIR)/

	# создать архив из временной плоской структуры
	tar -czf $(RPMBUILD_DIR)/SOURCES/$(NAMEVER).tar.gz \
		-C $(TEMP_DIR) $(NAMEVER)
	rm -rf $(TAR_TEMP_DIR)

	cp -u $(NAME).spec $(RPMBUILD_DIR)/SPECS/$(NAME).spec

rpm: dist
	rpmbuild -bb $(RPMBUILD_DIR)/SPECS/$(NAME).spec \
		--define "package_version $(VERSION)" \
		--define "_topdir $(CURDIR)/$(RPMBUILD_DIR)"
	rpm --addsign $(RPMBUILD_DIR)/RPMS/*/$(NAMEVER)*.rpm

print:
	@echo $(DIST_TAR_TMP_DIR)
	@echo $(subst XXX,*,$(MKTEMP_TEMP))
	echo $(RPMBUILD_DIR)/RPMS/*/$(NAMEVER)*.rpm
	@echo $(DESTDIR)$(licensdir)
	echo $(NAME)
	echo $(wildcard $(NAME))
	@echo $(@D)

# Подтягиваем сгенерированные -MMD списки заголовков: после первой сборки
# правка любого .h корректно пересобирает только зависимые объектники.
-include $(wildcard $(BUILD_DIR)/*.d)