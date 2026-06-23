#include <assert.h>

/*
 * 1 << (w - n) <-> 1 << (8 - 2) <-> 1 << 6:
 * mask = 1 << 6 = 01000000
 * mask - 1 = 00111111
 * not = 11000000
 */

unsigned rotate_left(unsigned x, int n) {
  unsigned word_size = sizeof(x) << 3;

  unsigned mask = ~((1U << (word_size - n)) - 1);
  unsigned temp = (x & mask) >> (word_size - n);

  x = x << n;

  return x | temp;
}

unsigned rotate_left_v2(unsigned x, int n) {
  unsigned w = sizeof(x) << 3;

  // Keeps n in the required range 0 <= n < w
  n %= w;

  return (x << n) | (x >> ((w - n) & (w - 1)));
}

void test_rotate_left() {
  assert(rotate_left(0x12345678, 20) == 0x67812345);
  assert(rotate_left(0x12345678, 32) == 0x12345678);
  assert(rotate_left(0x12345678, 0) == 0x12345678);
}
