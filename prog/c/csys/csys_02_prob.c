#include <assert.h>
#include <stdio.h>

int is_little_endian();
void test_is_little_endian();

int y_with_lsb_x(int x, int y);
void test_y_with_lsb_x();

unsigned replace_byte(unsigned x, int i, unsigned char b);
void test_replace_byte();

int main() {
  // test_is_little_endian();
  // test_y_with_lsb_x();
  test_replace_byte();
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
