#include <assert.h>
#include <limits.h>

void prob_2_61() {
  int x = 0xFF00FF00;

  int cond_a = x != 0;
  int cond_b = x != ~0;
  int cond_c = (x & 0xFF) != 0;
  int cond_d = ((x >> 24) & 0xFF) != 0xFF;
}
