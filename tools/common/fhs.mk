
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

# DESTDIR — не объявляется здесь (это не наша переменная), а передаётся извне.
# Мотивация: стандартный механизм staging-установки — устанавливать не в корень ФС,
# а в $DESTDIR<путь>, чтобы потом упаковать в rpm/deb/т.п. без прав root.
# Работает из-за того, что в правилах install пути написаны как $(DESTDIR)$(bindir) и т.д.

# bindir — исполняемые файлы.
bindir      = $(DESTDIR)$(exec_prefix)/bin
# datarootdir — архитектурно-независимые данные.
datarootdir = $(DESTDIR)$(prefix)/share
# libdir — архитектурно-зависимые библиотеки.
libdir      = $(DESTDIR)$(exec_prefix)/lib

# docdir — документация именно этой утилиты.
docdir      = $(datarootdir)/doc/$(NAME)
# licensdir — лицензия (соглашение Fedora: /usr/share/licenses/<name>).
licensdir   = $(datarootdir)/licenses/$(NAME)
# node_modulesdir — системный каталог Node.js-пакетов.
node_modulesdir = $(libdir)/node_modules/$(NAME)


# mandir — man-страницы.
mandir      = $(datarootdir)/man
# man1dir — man-страницы раздела 1 (команды).
man1dir     = $(mandir)/man1
# man2dir — man-страницы раздела 2 (системные вызовы).
man2dir     = $(mandir)/man2
# man3dir — man-страницы раздела 3 (библиотечные функции).
man3dir     = $(mandir)/man3
# man4dir — man-страницы раздела 4 (специальные файлы устройств).
man4dir     = $(mandir)/man4
# man5dir — man-страницы раздела 5 (форматы файлов и конфигурация).
man5dir     = $(mandir)/man5
# man6dir — man-страницы раздела 6 (игры и развлечения).
man6dir     = $(mandir)/man6
# man7dir — man-страницы раздела 7 (разное).
man7dir     = $(mandir)/man7
# man8dir — man-страницы раздела 8 (системное администрирование).
man8dir     = $(mandir)/man8