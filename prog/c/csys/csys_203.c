#include <limits.h>
#include <stdio.h>

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

int main() {
  int res = uadd_ok(1, UINT_MAX);
  int res_t = tadd_ok(1, INT_MAX);
  int res_tb = tadd_ok_buggy_version(1, INT_MAX);

  printf("res = %d\n", res);
  printf("res_t = %d\n", res_t);
  printf("res_tb = %d\n", res_tb);
  return 0;
}