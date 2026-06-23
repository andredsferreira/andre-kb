#include "csys_utils.h"
#include <stdio.h>
#include <string.h>

void signed_to_unsigned() {
  char a = -128; // 1000 0000 - 0x80
  char b = -127; // 1000 0001 - 0x81
  char c = -64;  // 1100 0000 - 0xC0
  char d = -1;   // 1111 1111 - 0xFF

  printf("| Signed | Unsigned | Hexadecimal |\n");
  printf("| %-6hhd | %-6hhu   | 0x%-6hhX    |\n", a, a, a);
  printf("| %-6hhd | %-6hhu   | 0x%-6hhX    |\n", b, b, b);
  printf("| %-6hhd | %-6hhu   | 0x%-6hhX    |\n", c, c, c);
  printf("| %-6hhd | %-6hhu   | 0x%-6hhX    |\n", d, d, d);
}

void unsigned_to_signed() {
  unsigned char a = 255;
  unsigned char b = 127;
  unsigned char c = 128;
  unsigned char d = 1;

  printf(" | Unsigned | Signed | Hexadecimal |\n");
  printf(" | %-6hhu   | %-6hhd | 0x%-6hhX    |\n", a, a, a);
  printf(" | %-6hhu   | %-6hhd | 0x%-6hhX    |\n", b, b, b);
  printf(" | %-6hhu   | %-6hhd | 0x%-6hhX    |\n", c, c, c);
  printf(" | %-6hhu   | %-6hhd | 0x%-6hhX    |\n", d, d, d);
}

/* Demonstrates some quirks when declaring and defining variables. For
 * example, declaring and unsigned char but defining it as "-1"
 */

void variable_quirks() {
  unsigned char a = -1; // Allowed (255 unsigned - 0xFF)
  unsigned char b = -128;

  char *str = "hi";
  char str_2[] = "hi";

  print_bytes((unsigned char *)&a, sizeof(a));
  printf("a = %hhd\n", a);
  printf("a = %hhX\n", a);
}

/*
 * When performing logical operations if any one of the operands is
 * unsigned, C will implicitly convert all the operands to unsigned
 * aswell. This can give rise to weird results. For more info see
 * (cnotes.md).
 */

void unsigned_casts_in_expressions() {
  unsigned exp_a = 214748364U > -2147483647 - 1;
  unsigned exp_b = 2147483647 > -2147483647 - 1;
  unsigned exp_c = 2147483647 > (int)2147483648U;

  printf("214748364U > -2147483647 - 1   = %d\n", exp_a);
  printf("2147483647 > -2147483647-1     = %d\n", exp_b);
  printf("2147483647 > (int) 2147483648U = %d\n", exp_c);
}

/*
 * When converting from one size to another zero and sign extensions
 * preserve the sign of a number. Again, notice that we are only
 * converting size, not sign and size at the same time.
 */

void converting_size() {
  short s = -12345; // unsigned = 53191 = 2¹⁶ + (-12345)
  unsigned short us = 64000;

  int x = s;
  unsigned ux = us;

  printf("Original numbers: \n");
  print_bytes((unsigned char *)&s, sizeof(s));
  print_bytes((unsigned char *)&us, sizeof(us));

  printf("Sign extended: \n");
  print_bytes((unsigned char *)&x, sizeof(x));
  printf("Zero extended: \n");
  print_bytes((unsigned char *)&ux, sizeof(ux));
}

/* The C standard establishes that when converting size and sign at
the same time first the type is changed and then the sign.*/

void converting_size_and_sign() {
  short s = -12345;
  unsigned u = s;

  printf("uy = %u : \t", u);
  print_bytes((unsigned char *)&u, sizeof(u));
}

int fun1(unsigned word) { return (int)((word << 24) >> 24); }

int fun2(unsigned word) { return ((int)word << 24) >> 24; }

int strlonger(char *s, char *t) { return strlen(s) > strlen(t); }

int main() {

  signed_to_unsigned();
  unsigned_to_signed();
  // variable_quirks();
  // unsigned_casts_in_expressions();
  // converting_size();
  // converting_size_and_sign();

  return 0;
}