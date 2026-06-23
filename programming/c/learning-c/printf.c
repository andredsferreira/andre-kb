/*
 * Simple program to showcase the use of the printf standard function.
 * Specially the formatting options.
 */

#include <stdio.h>

void signed_formats() {
  char a = -64;
  short b = -32;
  int c = -45;
  long d = -82000000;
  float e = 2.324f;
  double f = -3.14;

  printf("char a = %hhd\n", a);
  printf("short b = %hd\n", b);
  printf("int c = %d\n", c);
  printf("long d = %ld\n", d);
  printf("float e = %f\n", e);
  printf("double f = %lf\n", f);

  printf("\n%lu\n", sizeof(long));
  printf("\n%lu\n", sizeof(long long));
}

void edge() {
  int a = -2147483648;

  printf("%X\n", (unsigned int)a);
}

void unsigned_formats() {}

int main() {
  signed_formats();
  // edge();
  return 0;
}
