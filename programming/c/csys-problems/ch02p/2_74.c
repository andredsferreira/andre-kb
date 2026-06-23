int tsub_ok(int x, int y) {
  int diff = x - y;
  int neg_over = x < 0 && y >= 0 && diff >= 0;
  int pos_over = x >= 0 && y < 0 && diff < 0;
  return !neg_over && !pos_over;
}
