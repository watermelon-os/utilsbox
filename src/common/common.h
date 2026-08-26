#include <string.h>
#include <stdio.h>

#ifndef HELLO_H
#define HELLO_H

const char* ltrim(const char *str);

const char* trim_prefix(const char *str, const char *prefix);

char* trim_suffix(char *dest, size_t dest_size, const char *str, const char *suffix);

#endif
