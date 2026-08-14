# Утилита watermelon-ps. Общие переменные и правила — в Makefile.common
TOOL := watermelon-ps

# Каталог, где лежит этот Makefile (не зависит от места запуска make).
MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
# Корень проекта: src/<tool>/../..
ROOT := $(abspath $(MK_DIR)/../..)

include $(ROOT)/Makefile.common
