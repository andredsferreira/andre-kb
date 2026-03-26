/*
 * Returns the nth bit of a number.
 */

#include <assert.h>

unsigned char get_nthb(int x, int n) {
  if (n > sizeof(x) * 8 || n <= 0) {
    return 0;
  }

  unsigned mask = 1 << (n - 1);
  if ((x & mask) == 0) {
    return 0;
  }
  return 1;
}

unsigned char get_nthb_v2(int x, int n) {
  // Cleaner version
  return (x >> (n - 1)) & 1;
}

int main() {
  int x = 0x00800000;

  assert(get_nthb(x, 24) == 1);
  assert(get_nthb(x, 1) == 0);
  assert(get_nthb(x, 0) == 0);

  return 0;
}