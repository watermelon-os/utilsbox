#include <dirent.h>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <string.h>

#include "ps.h"

#ifndef VERSION
#define VERSION "unknown"
#endif

int main(int argc, char **argv) {
  int s_argc = 0;
  char **s_argv = NULL;
  if (argc == 1 && strcmp(argv[0], "utilsbox") == 0) {
    return ps_main(argc, argv);
  } else if (argc > 1 && strcmp(argv[0], "utilsbox") != 0) {
    s_argc = argc-1;
    argv = &s_argv[1];
    for (int i = 2; i < argc; i++) {
      s_argv[i] = argv[i];
    }
  }
  
  if (strcmp(s_argv[0], "ps") == 0) {
    return ps_main(s_argc, s_argv);
  }
}