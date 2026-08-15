# Makefile утилиты. ВСЕГДА запускается из корня проекта (make -f tools/watermelon-ps/Makefile)
# или через корневой Makefile. Запуск из собственной поддиректории не поддерживается:
# все пути ниже — относительно корня проекта (cwd).

# CC/CFLAGS — стандартные имена make (часть соглашения GNU make, не проект-специфичные).
# Мотивация: одинаковые имена в любом проекте = одинаковые способы переопределения
# из командной строки:  make CC=clang CFLAGS="-O2". Компилятор по умолчанию уже задан
# самим make (cc), здесь лишь явно зафиксирован + заданы флаги предупреждений.
CC = gcc
CFLAGS = -Wall -Wextra -g

# VERSION — версия из git-тегов (единственный источник правды).
# git describe --tags: ближайший тег (v1.0.0), а если тегов нет — --always даёт хеш.
# --dirty добавляет суффикс при незакоммиченных изменениях.
# Мотивация: один источник версии — тег — рождает и имя tar (name-version),
# и Version в спеке, и -DVERSION при компиляции; они не разъезжаются.
# VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo 0.0.0-unknown)

VERSION = 20260815-0.1

# Версия попадает в бинарь на этапе компиляции через макрос VERSION.
CFLAGS += -DVERSION=\"$(VERSION)\"

# NAME — имя утилиты (бинарь, каталог сборки, man-файл, doc-каталог).
# Мотивация: единый источник истины — имя не дублируется текстом по всему Makefile,
# переименование/перенос утилиты = правка одной строки. Также даёт подсказку сборщику пакета.
NAME = watermelon-ps
# NAMEVER = $(NAME)-$(VERSION)

# TOOL_DIR — каталог исходников этой утилиты (относительно корня проекта).
TOOL_DIR = tools/$(NAME)

# BUILD_DIR — куда кладутся результаты сборки.
# Мотивация: (1) сборка вне каталога исходников — чисто и легко чистить (make clean);
# (2) главное — переменная переопределяется проектным Makefile через командную строку,
#     чтобы собирать в корневой .build/, а не в локальной подпапке.
BUILD_DIR = .build/$(NAME)

RPMBUILD_DIR = .rpmbuild

# COMMON_DIR — путь к общему коду (tools/common).
# Мотивация: одно место, где задан путь к переиспользуемому коду, вместо повторения
# его в каждом правиле; тоже можно переопределить извне при необходимости.
COMMON_DIR = tools/common

# HELLO_OBJ — объектник общего кода, который использует только эта утилита.
# Мотивация: удобство — один объект ссылается и в правиле сборки, и в списке зависимостей;
# если common/ расширится, здесь явно прописываются новые объектники по одному.
HELLO_OBJ = $(BUILD_DIR)/common/hello.o

# Блок GNU-переменных установки (стандарт autoconf/GNU make, они же — соглашения FHS).
# Мотивация: пользователь/сборщик пакета может переопределить любую из них стандартным
# способом (make install prefix=/usr), не читая Makefile. Иерархия производных друг от
# друга (exec_prefix<-prefix, bindir<-exec_prefix, ...) повторяет общепринятую схему.
# ВАЖНО: комментарии пишем только на отдельных строках — inline-комментарий после значения
# make вырезает, но оставляет пробелы перед ним, и пути ломаются («/usr/local   /bin»).
# prefix — корень установки по умолчанию.
prefix      = /usr/local
# exec_prefix — = prefix, если нет особой раскладки архитектурно-зависимых файлов.
exec_prefix = $(prefix)
# bindir — исполняемые файлы.
bindir      = $(exec_prefix)/bin
# datarootdir — архитектурно-независимые данные.
datarootdir = $(prefix)/share
# mandir — man-страницы.
mandir      = $(datarootdir)/man
# man1dir — man-страницы раздела 1 (команды).
man1dir     = $(mandir)/man1
# docdir — документация и лицензия именно этой утилиты.
docdir      = $(datarootdir)/doc/$(NAME)

# DESTDIR — не объявляется здесь (это не наша переменная), а передаётся извне.
# Мотивация: стандартный механизм staging-установки — устанавливать не в корень ФС,
# а в $DESTDIR<путь>, чтобы потом упаковать в rpm/deb/т.п. без прав root.
# Работает из-за того, что в правилах install пути написаны как $(DESTDIR)$(bindir) и т.д.

all: $(BUILD_DIR)/$(NAME)

$(BUILD_DIR)/common/hello.o: $(COMMON_DIR)/hello.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(COMMON_DIR) -c $< -o $@

$(BUILD_DIR)/$(NAME): $(TOOL_DIR)/main.c $(HELLO_OBJ)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(COMMON_DIR) -o $@ $< $(HELLO_OBJ)

install: all
	install -d $(DESTDIR)$(bindir) $(DESTDIR)$(man1dir) $(DESTDIR)$(docdir)
	install -m 755 $(BUILD_DIR)/$(NAME) $(DESTDIR)$(bindir)/$(NAME)
	install -m 644 $(TOOL_DIR)/$(NAME).1 $(DESTDIR)$(man1dir)/$(NAME).1
	install -m 644 $(TOOL_DIR)/LICENSE $(DESTDIR)$(docdir)/LICENSE

uninstall:
	rm -f $(DESTDIR)$(bindir)/$(NAME)
	rm -f $(DESTDIR)$(man1dir)/$(NAME).1
	rm -f $(DESTDIR)$(docdir)/LICENSE
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(docdir)

clean:
	rm -rf $(BUILD_DIR)

dist: $(BUILD_DIR)/$(NAME)
	mkdir -p $(RPMBUILD_DIR)/{SPECS,SOURCES}
	tar -czf $(RPMBUILD_DIR)/SOURCES/$(NAME)-$(VERSION).tar.gz \
		$(BUILD_DIR)/$(NAME) \
		$(TOOL_DIR)/LICENSE \
		$(TOOL_DIR)/$(NAME).1 \
		$(TOOL_DIR)/Makefile
	# git archive --format=tar.gz --prefix=$(NAME)-$(VERSION)/ HEAD > $(RPMBUILD_DIR)/SOURCES/$(NAME)-$(VERSION).tar.gz
	cp -u $(TOOL_DIR)/$(NAME).spec $(RPMBUILD_DIR)/SPECS/$(NAME).spec

rpm: dist
	rpmbuild -bb $(RPMBUILD_DIR)/SPECS/$(NAME).spec \
		--define "package_version $(VERSION)" \
		--defiene "_topdir $(RPMBUILD_DIR)"

.PHONY: all install uninstall clean dist rpm
