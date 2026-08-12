#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/syscall.h>
#include <unistd.h>

int *get_all_pids(int *pids_count) {
  int *pids = NULL;
  DIR *dir = opendir("/proc");
  if (dir == NULL) {
    printf("Error opening dir: %s\n", strerror(errno));
    return NULL;
  }

  struct dirent *entries;
  int i = 0;
  while ((entries = readdir(dir)) != NULL) {
    int pid = atoi(entries->d_name);
    if (pid == 0)
      continue;

    int *tmp = realloc(pids, (i + 1) * sizeof(int));
    if (tmp == NULL) {
      free(pids);
      closedir(dir);
      return NULL;
    }
    pids = tmp;
    pids[i] = pid;
    i++;
  }

  closedir(dir);
  *pids_count = i;

  return pids;
}

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;

  int count;
  get_all_pids(&count);
  printf("количество процессов сейчас %d", count);

  // puts("Входждения в /proc");
  // walk_dir("/proc");

  return 0;
}