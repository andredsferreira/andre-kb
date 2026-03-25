#include <assert.h>

int is_little_endian();
void test_is_little_endian();

int y_with_lsb_x(int x, int y);
void test_y_with_lsb_x();

int main() {
  test_is_little_endian();
  test_y_with_lsb_x();
  return 0;
}

/********************************************************************************/
// 2.58

int is_little_endian() {
  unsigned short a = 0x00FF;
  char *ptr = (char *)&a;
  return (*ptr & 0xFF) != 0;
}

void test_is_little_endian() { assert(is_little_endian() == 1); }

/********************************************************************************/
// 2.59

int y_with_lsb_x(int x, int y) {
  int lsb_x = x & 0xFF;
  int cleared_y = y & ~0xFF;
  return cleared_y | lsb_x;
}

void test_y_with_lsb_x() {
  int x = 0x89ABCDEF;
  int y = 0x76543210;
  assert(y_with_lsb_x(x, y) == 0x765432EF);
}

/********************************************************************************/

