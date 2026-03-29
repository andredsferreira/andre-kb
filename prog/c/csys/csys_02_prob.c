#include <assert.h>
#include <limits.h>
#include <stdio.h>

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
// 2.60

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

/********************************************************************************/
// 2.61

void p_261() {
  int x = 0xFF00FF00;

  int cond_a = x != 0;
  int cond_b = x != ~0;
  int cond_c = (x & 0xFF) != 0;
  int cond_d = ((x >> 24) & 0xFF) != 0xFF;
}

/********************************************************************************/

// 2.66

// 0xFF -> 0x8000
// 1111 1111 -> 1000 0000 0000 0000

// 0x6600 -> 0x4000
// 0110 0110 0000 0000 -> 0100 0000 0000 0000

int leftmost_one(unsigned x) {

  x &= ~(x >> 1);
  x &= ~(x >> 2);
  x &= ~(x >> 4);
  x &= ~(x >> 8);
  x &= ~(x >> 16);

  return x;
}

/********************************************************************************/

// 2.68

// n =6 -> 0x3F (0011 1111)

int lower_one_mask(int n) {
  int word_size = sizeof(int) << 3;
  unsigned mask = ~0U >> (word_size - n);
  return mask;
}

/********************************************************************************/

// 2.69

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

int main() {
  test_rotate_left();
  return 0;
}

/********************************************************************************/

// 2.70

// 0000 1100
// 0001 0000
// 0000 1111

// 0100 1000
// 0001 0000
// 0000 1111

int fits_bits(int x, int n) {
  int shift = 32 - n;
  return (x << shift >> shift) == x;
}

/********************************************************************************/

// 2.73 (from solutions manual)

/*
 * Overflow can only happen if both x and y are the same sign
 * but the sum is not.
 */

int saturating_add(int x, int y) {
  int sum = x + y;

  int xneg_mask = (x >> 31);
  int yneg_mask = (y >> 31);
  int sneg_mask = (sum >> 31);

  int pos_over_mask = xneg_mask & yneg_mask & sneg_mask;
  int neg_over_mask = xneg_mask & yneg_mask & sneg_mask;
  int over_mask = pos_over_mask | neg_over_mask;

  int res =
      (over_mask & sum) | (pos_over_mask & INT_MAX) | (neg_over_mask & INT_MIN);

  return res;
}

/********************************************************************************/

// 2.74

int tsub_ok(int x, int y) {
  int diff = x - y;
  int neg_over = x < 0 && y >= 0 && diff >= 0;
  int pos_over = x >= 0 && y < 0 && diff < 0;
  return !neg_over && !pos_over;
}
/********************************************************************************/
