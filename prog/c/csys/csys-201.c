#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include "common.h"

void test_print_bytes() {
  int a = 327594219;
  short b = 19835;
  int c = 0x11223344;
  const char str_a[] = "Hello, my man!";
  const char *str_b = "mnoqpr";

  print_bytes((unsigned char *)&a, sizeof(a));
  print_bytes((unsigned char *)&b, sizeof(b));
  print_bytes((unsigned char *)&c, sizeof(c));

  print_bytes((unsigned char *)&str_a, sizeof(str_a));
  print_bytes((unsigned char *)&str_b, strlen(str_b));
}

void char_range() {
  char a = 67;
  unsigned char b = 230;
  char c = -22;

  printf("%c\n", a);

  // Will be bugged, ASCII range is [0,127]
  printf("%c\n", b);
  printf("%c\n", c);

  // Prints ok
  printf("%u\n", b);
  printf("%d\n", c);
}

void inplace_swap(int *x, int *y) {
  *y = *x ^ *y;
  *x = *x ^ *y;
  *y = *x ^ *y;
}

void reverse_array(int a[], int len) {
  int first, last;
  for (first = 0, last = len - 1; first < last; first++, last--) {
    inplace_swap(&a[first], &a[last]);
  }
}

int sum_array(int *arr, int len) {
  int sum;
  for (int i = 0; i < len; i++) {
    sum += *arr++;
  }
  return sum;
}

void least_significant_byte(unsigned int x) {
  unsigned int lsb = x & 0xFF;
  printf("Least significant byte: 0x%X\n", lsb);
}

void complement_all_but_lsb(unsigned int x) {
  // ~0xFF = 0xFFFFFF00 (in case of 32 bits)
  unsigned int res = x ^ (~0xFF);
  printf("Complement except LSB: 0x%X\n", res);
}

void lsb_set_to_ones(unsigned int x) {
  unsigned int res = x | 0xFF;
  printf("All set to ones except LSB: 0x%X\n", res);
}

void bshifts() {
  unsigned char a = 0b11010100; // 0xD4
  unsigned char b = 0b01100100; // 0x64
  unsigned char c = 0b01110010; // 0x72
  unsigned char d = 0b01000100; // 0x44

  printf("Logical left shifts:\n");
  printb_char(a << 2);
  printb_char(b << 2);
  printb_char(c << 2);
  printb_char(d << 2);

  printf("Logical right shifts:\n");
  printb_char(a >> 3);
  printb_char(b >> 3);
  printb_char(c >> 3);
  printb_char(d >> 3);

  printf("Arithmetic right shifts:\n");
  printb_char((signed char)a >> 3);
  printb_char((signed char)b >> 3);
  printb_char((signed char)c >> 3);
  printb_char((signed char)d >> 3);
}

int main() { return 0; }
