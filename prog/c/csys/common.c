#include "common.h"

void print_bytes(unsigned char *start, size_t len) {
  printf("0x");
  for (int i = 0; i < len; i++) {
    printf("%02X", start[len - i - 1]);
  }
  printf("\n");
}

void printb_char(unsigned char num) {
  for (int i = sizeof(num) * 8 - 1; i >= 0; i--) {
    printf("%d", (num >> i) & 1);
  }
  printf("\n");
}
