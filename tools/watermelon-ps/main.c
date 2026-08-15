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

#ifndef VERSION
#define VERSION "unknown"
#endif

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
} process_status;

process_status *get_process_status(int pid) {
  char filename_status[100];
  snprintf(filename_status, sizeof(filename_status), "/proc/%d/status", pid);

  FILE *file_status = fopen(filename_status, "r");
  if (file_status == NULL) {
    printf("Error opening file: %s\n", strerror(errno));
    return NULL;
  }

  process_status *status = calloc(1, sizeof(process_status));
  if (status == NULL) {
    fclose(file_status);
    return NULL;
  }

  char buffer[256];
  while (fgets(buffer, sizeof(buffer), file_status) != NULL) {
    buffer[strcspn(buffer, "\r\n")] = '\0';

    const char *value;
    if ((value = trim_prefix(buffer, "Name:")) != NULL)
      status->name = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "State:")) != NULL)
      status->state = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "Pid:")) != NULL)
      status->pid = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "PPid:")) != NULL)
      status->ppid = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "VmRSS:")) != NULL)
      status->VmRSS = strdup(ltrim(value));
    else if ((value = trim_prefix(buffer, "VmSize:")) != NULL)
      status->VmSize = strdup(ltrim(value));
  }

  fclose(file_status);
  return status;
}

void print_table_processes_status(process_status *arr, size_t n) {
  const char *headers[] = {"Name", "State", "PID", "PPID", "VmRSS", "VmSize"};
  const size_t ncols = sizeof(headers) / sizeof(headers[0]);
  size_t widths[ncols];
  for (size_t col = 0; col < ncols; col++)
    widths[col] = strlen(headers[col]);

  for (size_t j = 0; j < n; j++) {
    process_status *ps = &arr[j];
    const char *vals[] = {
        ps->name ? ps->name : "?", ps->state ? ps->state : "?",
        ps->pid ? ps->pid : "?", ps->ppid ? ps->ppid : "?",
        ps->VmRSS ? ps->VmRSS : "?", ps->VmSize ? ps->VmSize : "?"};
    for (size_t col = 0; col < ncols; col++) {
      size_t len = strlen(vals[col]);
      if (len > widths[col])
        widths[col] = len;
    }
  }

  for (size_t col = 0; col < ncols; col++)
    printf("%s%-*s", col ? " | " : "", (int)widths[col], headers[col]);
  printf("\n");

  size_t total = 0;
  for (size_t col = 0; col < ncols; col++)
    total += widths[col] + (col ? 3 : 0);
  for (size_t i = 0; i < total; i++)
    putchar('-');
  printf("\n");

  for (size_t j = 0; j < n; j++) {
    process_status *ps = &arr[j];
    const char *vals[] = {
        ps->name ? ps->name : "?", ps->state ? ps->state : "?",
        ps->pid ? ps->pid : "?", ps->ppid ? ps->ppid : "?",
        ps->VmRSS ? ps->VmRSS : "?", ps->VmSize ? ps->VmSize : "?"};
    for (size_t col = 0; col < ncols; col++)
      printf("%s%-*s", col ? " | " : "", (int)widths[col], vals[col]);
    printf("\n");
  }
}

process_status *get_all_process_statuses(int *statuses_count) {
  int count;
  int *pids = get_all_pids(&count);
  if (pids == NULL)
    return NULL;

  process_status *arr = calloc(count, sizeof(process_status));
  if (arr == NULL) {
    free(pids);
    return NULL;
  }

  int n = 0;
  for (int i = 0; i < count; i++) {
    process_status *ps = get_process_status(pids[i]);
    if (ps != NULL) {
      arr[n++] = *ps;
      free(ps);
    }
  }

  free(pids);
  *statuses_count = n;
  return arr;
}

// void free_process_statuses(process_status *arr, size_t n) {
//   for (size_t j = 0; j < n; j++) {
//     free(arr[j].name);
//     free(arr[j].state);
//     free(arr[j].pid);
//     free(arr[j].ppid);
//     free(arr[j].VmRSS);
//     free(arr[j].VmSize);
//   }
//   free(arr);
// }

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;

  int pids_count;
  get_all_pids(&pids_count);
  printf("%s %s\n", "watermelon-ps", VERSION);
  printf("количество процессов сейчас %d\n", pids_count);

  int n;
  process_status *arr = get_all_process_statuses(&n);
  if (arr != NULL) {
    print_table_processes_status(arr, n);
    // free_process_statuses(arr, n);
  }
  
  return 0;
}