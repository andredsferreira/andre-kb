#include <limits.h>
#include <stdio.h>
#include <sys/types.h>

int uadd_ok(unsigned x, unsigned y) {
  unsigned sum = x + y;
  if (sum < x || sum < y) {
    return 0;
  }
  return 1;
}

int tadd_ok(int x, int y) {
  int sum = x + y;
  if ((x > 0 && y > 0 && sum < 0) || (x < 0 && y < 0 && sum >= 0)) {
    return 0;
  }
  return 1;
}

int tadd_ok_buggy_version(int x, int y) {
  int sum = x + y;
  return (sum - x == y) && (sum - y == x);
}

int tsub_ok_buggy_version(int x, int y) { return tadd_ok(x, -y); }

int tmult_ok(int x, int y) {
  int p = x * y;
  return !x || p / x == y;
}

int tmult_ok_v2(int x, int y) {
  int64_t p = x * y;
  return p == (int)p;
}

void mult_overflow() {
  unsigned char ua = 255;
  unsigned char ub = 100;
  char a = 127;
  char b = 2;

  unsigned char up = ua * ub; // without overflow = 25500 (0x639C)
  char p = a * b; // without overflow = 254 (0xFE) 

  printf("ua * ub = %hhX\n", up);
  printf("a * b = %hhX\n", p);
}

int main() {
  // int res = uadd_ok(1, UINT_MAX);
  // int res_t = tadd_ok(1, INT_MAX);
  // int res_tb = tadd_ok_buggy_version(1, INT_MAX);

  // printf("res = %d\n", res);
  // printf("res_t = %d\n", res_t);
  // printf("res_tb = %d\n", res_tb);
  mult_overflow();
  return 0;
}