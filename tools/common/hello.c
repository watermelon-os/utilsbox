#include "hello.h"
#include <string.h>
#include <stdio.h>


const char* ltrim(const char *str) {
    while (*str == ' ' || *str == '\t')
        str++;
    return str;
}


const char* trim_prefix(const char *str, const char *prefix) {
    size_t len = strlen(prefix);
    if (strncmp(str, prefix, len) != 0)
        return NULL;
    return str + len;
}


char* trim_suffix(char *dest, size_t dest_size, const char *str, const char *suffix) {
    size_t str_len = strlen(str);
    size_t suf_len = strlen(suffix);
    
    if (str_len >= suf_len && strcmp(str + str_len - suf_len, suffix) == 0) {
        size_t new_len = str_len - suf_len;
        if (new_len >= dest_size) new_len = dest_size - 1;
        strncpy(dest, str, new_len);
        dest[new_len] = '\0';
    } else {
        strncpy(dest, str, dest_size);
        dest[dest_size - 1] = '\0';
    }
    return dest;
}

