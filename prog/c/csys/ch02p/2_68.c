int lower_one_mask(int n) {
  int word_size = sizeof(int) << 3;
  unsigned mask = ~0U >> (word_size - n);
  return mask;
}
