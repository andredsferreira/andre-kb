#include <assert.h>
#include <limits.h>
#include <stdbool.h>

/**********************************************************************/

// SOME CONCEPTS
// Resource for more on bitwise operations:
// https://graphics.stanford.edu/~seander/bithacks.html

/*
 * Subtracting 1 from a number and applying AND from the original
 * number with the subtracted number IS THE SAME as setting the least
 * significant 1 of the original number to 0. For x the general
 * expression is: x = x & (x - 1). Example:
 *
 * x   = 0110 0100
 * res = 0110 0000
 *
 * This has some interesting applications such as counting the number
 * of 1s in a number (see the count_ones() in this document).
 *
 */

/**********************************************************************/

// Checks if the least significant bit of a number is set or not.

bool check_lsb(int x) {
  if ((x & 1) == 0) {
    return false;
  }
  return true;
}

void test_check_lsb() {
  int x = 1;
  int y = 0;

  assert(check_lsb(x) == true);
  assert(check_lsb(y) == false);
}

/**********************************************************************/

// Checks if the most significant bit of a number is set or not.

bool check_msb(int x) {
  // Same as INT_MAX = 0x80000000
  unsigned mask = 1 << (sizeof(x) * 8 - 1);

  if ((x & mask) == 0) {
    return false;
  }
  return true;
}

void test_check_msb() {
  int x = -1;
  int y = 0;

  assert(check_msb(x) == true);
  assert(check_msb(y) == false);
}

/**********************************************************************/

// Set a specific n bit of a number.

int set_bit(int x, int n) {
  int res = x | (1 << n);
  return res;
}

/**********************************************************************/

// Clear a specific n bit of a number.

int clear_bit(int x, int n) {
  int res = x & ~(1 << n);
  return res;
}

/**********************************************************************/

// Toggle a specific n bit of a number.

int toggle_bit(int x, int n) {
  int res = x ^ (1 << n);
  return res;
}

/**********************************************************************/

// Convert trailing 0s to 1s.
// x     =  01101000
// x - 1 =  01100111
// OR    =  01101111

int convert_trailing_zeros(int x) {
  int res = x | (x - 1);
  return res;
}

/**********************************************************************/

// Extract the least significant 1 from a number.
// NOTE: -x = ~x + 1.
//  x =  01101000
// -x =  10011000
// AND = 00001000

int get_lsb(int x) {
  int res = x & (~x + 1);
  return res;
}

/**********************************************************************/

// Extracts the bit at n position.

unsigned char get_nth_bit(int x, int n) {
  unsigned char res = (x >> (n - 1)) & 1;
  return res;
}

/**********************************************************************/

// Copy bits from src to dest where mask is 1.

int copy_with_mask(int src, int dest, int mask) {
  int res = (src & mask) | (dest & ~mask);
  return res;
}

/**********************************************************************/

// Swap bits in indices i and j.

int swap_bits(int x, int i, int j) {
  int res;
  // Results in 1 if bits at indices are different:
  int bits_are_different = (x >> i) & (x >> j) & 1;
  if (bits_are_different == 1) {
    res = x ^ (1 << i);
    res = x ^ (1 << j);
  } else {
    res = x;
  }
  return res;
}

/**********************************************************************/

// Count number of bits set to 1.
// 1010 0111 x
// 1010 0110 x - 1
// 1010 0110 x & x - 1

unsigned count_ones(int x) {
  unsigned count;
  for (count = 0; x != 0; count++) {
    x = x & (x - 1);
  }
  return count;
}

/**********************************************************************/

// Bit scan forwards (BSF): find the index of the lowest set bit.

// 0110 1111 0101 0000
// 1001 0000 1011 0000 -x (complement x and add 1)
// 0000 0000 0001 0000 x & -x

unsigned bsf(int x) {
  int i = 0;

  // Only the lowest set bit of x will left.
  x = x & -x;

  // 1111 1111 1111 1111 0000 0000 0000 0000
  if ((x & 0xFFFF0000) != 0) {
    i += 16;
  }

  // 1111 1111 0000 0000 1111 1111 0000 0000
  if ((x & 0xFF00FF00) != 0) {
    i += 8;
  }

  // 1100 1100 1100 1100 1100 1100 1100 1100
  if ((x & 0xCCCCCCCC) != 0) {
    i += 4;
  }

  // 1010 1010 1010 1010 1010 1010 1010 1010
  if ((x & 0xAAAAAAAA) != 0) {
    i += 1;
  }

  return i;
}

unsigned bsf_v2(int x) {
  unsigned i = 0;

  x &= -x;

  i += ((x & 0xFFFF0000) != 0) << 4; // +16
  i += ((x & 0xFF00FF00) != 0) << 3; // +8
  i += ((x & 0xCCCCCCCC) != 0) << 2; // +4
  i += ((x & 0xAAAAAAAA) != 0);      // +1

  return i;
}

/**********************************************************************/

