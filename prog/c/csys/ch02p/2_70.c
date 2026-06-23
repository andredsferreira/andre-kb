// 0000 1100
// 0001 0000
// 0000 1111

// 0100 1000
// 0001 0000
// 0000 1111

int fits_bits(int x, int n) {
  int shift = 32 - n;
  return (x << shift >> shift) == x;
}
