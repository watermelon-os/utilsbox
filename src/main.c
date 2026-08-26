#include <stdio.h>
#include <string.h>

#include "ps.h"

#ifndef VERSION
#define VERSION "unknown"
#endif

// basename из libgen.h может модифицировать строку — своя безопасная версия.
static const char *prog_name(const char *path) {
  const char *slash = strrchr(path, '/');
  return slash ? slash + 1 : path;
}

int main(int argc, char **argv) {
  printf("%s\n", VERSION);

  const char *cmd = prog_name(argv[0]);
  char **cmd_argv = argv + 1;
  int cmd_argc = argc - 1;

  // Запуск как "utilsbox": первый аргумент — подкоманда,
  // без аргументов — подкоманда по умолчанию.
  if (strcmp(cmd, "utilsbox") == 0) {
    if (cmd_argc == 0) {
      cmd = "ps";
    } else {
      cmd = cmd_argv[0];
      cmd_argv++;
      cmd_argc--;
    }
  }

  // Иначе считаем, что бинарь вызван через симлинк с именем подкоманды.

  if (strcmp(cmd, "ps") == 0)
    return ps_main(cmd_argc, cmd_argv);

  fprintf(stderr, "usage: utilsbox [ps]\n");
  return 1;
}