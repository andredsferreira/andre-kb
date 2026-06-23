#include <assert.h>
#include <limits.h>

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
