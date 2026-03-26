/*
 * Checks if the least significant bit of a number is set or not.
 */

#include <assert.h>
#include <stdbool.h>

bool check_lsb(int x) {
  if ((x & 1) == 0) {
    return false;
  }
  return true;
}

int main() {
  int x = 1;
  int y = 0;

  assert(check_lsb(x) == true);
  assert(check_lsb(y) == false);

  return 0;
}