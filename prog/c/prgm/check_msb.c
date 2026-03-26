/*
 * Checks if the most significant bit of a number is set or not.
 */

#include <assert.h>
#include <stdbool.h>

bool check_msb(int x) {
  // Same as INT_MAX = 0x80000000
  unsigned mask = 1 << (sizeof(x) * 8 - 1);

  if ((x & mask) == 0) {
    return false;
  }
  return true;
}

int main() {
  int x = -1;
  int y = 0;

  assert(check_msb(x) == true);
  assert(check_msb(y) == false);

  return 0;
}