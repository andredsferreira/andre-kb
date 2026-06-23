#include <assert.h>
#include <limits.h>

int is_little_endian() {
  unsigned short a = 0x00FF;
  char *ptr = (char *)&a;
  return (*ptr & 0xFF) != 0;
}

void test_is_little_endian() { assert(is_little_endian() == 1); }
