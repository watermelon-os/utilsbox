# Компилятор и флаги
CC = gcc
CFLAGS = -Wall -g

# Имя и путь итогового файла
TARGET_DIR = build
TARGET = $(TARGET_DIR)/my_program

# Исходные файлы в корне и объектные файлы в build
SRCS = main.c
OBJS = $(addprefix $(TARGET_DIR)/, $(SRCS:.c=.o))

# Главное правило
all: $(TARGET_DIR) $(TARGET)

# Ссылка объектных файлов в исполняемый
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Компиляция каждого .c файла в .o внутри папки build
$(TARGET_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Создание директории build, если её нет
$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

# Очистка папки сборки
clean:
	rm -rf $(TARGET_DIR)

.PHONY: all clean