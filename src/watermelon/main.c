#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/syscall.h>
#include <unistd.h>

#include "hello.h"

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

typedef struct {
  char *name, *state, *pid, *ppid, *VmRSS, *VmSize;
} process_info;

process_info *get_process_info(int pid) {
  char filename_status[100];
  snprintf(filename_status, sizeof(filename_status), "/proc/%d/status", pid);

  FILE *file_status = fopen(filename_status, "r");
  if (file_status == NULL) {
    printf("Error opening file: %s\n", strerror(errno));
    return NULL;
  }

  process_info *info = calloc(1, sizeof(process_info));
  if (info == NULL) {
    fclose(file_status);
    return NULL;
  }

  char buffer[256];
  while (fgets(buffer, sizeof(buffer), file_status) != NULL) {
    buffer[strcspn(buffer, "\r\n")] = '\0';

    const char *value;
    if ((value = trim_prefix(buffer, "Name:")) != NULL)
      info->name = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "State:")) != NULL)
      info->state = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "Pid:")) != NULL)
      info->pid = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "PPid:")) != NULL)
      info->ppid = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "VmRSS:")) != NULL)
      info->VmRSS = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "VmSize:")) != NULL)
      info->VmSize = strdup(ltrim(value));
  }

  fclose(file_status);
  return info;
}

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;

  int count;
  get_all_pids(&count);
  printf("количество процессов сейчас %d\n", count);

  process_info *info = get_process_info(getpid());
  if (info != NULL) {
    printf("name: %s\nstate: %s\npid: %s\nppid: %s\nVmRSS: %s\nVmSize: %s\n",
           info->name, info->state, info->pid, info->ppid, info->VmRSS,
           info->VmSize);
    free(info);
  }

  // puts("Входждения в /proc");
  // walk_dir("/proc");

  return 0;
}