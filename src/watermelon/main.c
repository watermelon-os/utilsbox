#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/syscall.h>
#include <unistd.h>

int *get_all_pids(int *pids_count) {
  int *pids;
  DIR *dir = opendir("/proc");
  if (dir == NULL) {
    printf("Error opening dir: %s\n", strerror(errno));
    return NULL;
  }

  struct dirent *ents = NULL;
  while ((ents = readdir(dir)) != NULL) {
    static int i = 0;

    char s_pid[256];
    strcpy(s_pid, ents->d_name);

    int pid = atoi(s_pid);
    if (pid == 0)
      continue;

    pids = realloc(pids, i * sizeof(char *));
    pids[i - 1] = pid;
  }

  if (pids != NULL)
    *pids_count = sizeof(pids);

  return pids;
}

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;

  // char *cwd;
  // if ((cwd = getcwd(NULL, 0)) == NULL) {
  //   perror("Error getting current working directory");
  //   return EXIT_FAILURE;
  // }
  // printf("current work dir: %s\n", cwd);

  int count;
  get_all_pids(&count);
  printf("количество процессов сейчас %d", count);

  // puts("Входждения в /proc");
  // walk_dir("/proc");

  return 0;
}