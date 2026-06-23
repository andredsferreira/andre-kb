#include <limits.h>

/*
 * Overflow can only happen if both x and y are the same sign
 * but the sum is not.
 */

// From solutions manual:

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
