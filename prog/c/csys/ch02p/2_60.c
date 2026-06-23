#include <assert.h>
#include <limits.h>
#include <stdio.h>

/*
 * 0x12345678
 * 0xFF00FFFF AND
 * 0x12005678
 */

unsigned replace_byte(unsigned x, int i, unsigned char b) {
  unsigned mask = ~(0xFF << (i * 8));
  unsigned x_cleared = x & mask;
  return x_cleared | (b << (i * 8));
}

void test_replace_byte() {
  unsigned x = 0x12345678;
  int i = 2;
  unsigned char b = 0xAB;

  unsigned res = replace_byte(x, i, b);
  printf("%08X", res);
}
