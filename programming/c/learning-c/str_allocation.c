/**
 * @brief Demonstrates dynamic string allocation.
 *
 * @note When allocating a string dynamically we must remember to provide enough
 * space for the null terminator. This means adding 1 to the size of the string.
 *
 * @note strcpy does not check if the destination buffer is large enough to
 * hold the source string. This can lead to buffer overflows. A good practice
 * is to use strncpy instead, which has a parameter for the maximum number of
 * characters that it will store.However, if the source is LARGER than the
 * destination, we must add the null terminator manually at the end.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STATIC_SIZE 64
#define DYNAMIC_SIZE 64

int main() {
  char static_str[STATIC_SIZE];
  char* dynamic_str = NULL;

  // +1 for null terminator
  dynamic_str = malloc(sizeof(char) * (DYNAMIC_SIZE + 1));

  if (dynamic_str == NULL) {
    fprintf(stderr, "Memory allocation failed.\n");
    exit(EXIT_FAILURE);
  }

  strcpy(static_str, "This is a static string.");
  printf("Static string: %s\n", static_str);
  printf("Static string length: %lu\n", strlen(static_str));

  strcpy(dynamic_str, "This is a dynamic string.");
  printf("Dynamic string: %s\n", dynamic_str);
  printf("Dynamic string length: %lu\n", strlen(dynamic_str));

  free(dynamic_str);
  dynamic_str = NULL;

  return 0;
}