#include <stdio.h>

char *get_str_buggy();
void test_get_str_buggy();

const char *get_str();
void test_get_str();

void change_number_buggy(int x);
void change_number(int *x);

int main() {
  printf("Hi\n");
  return 0;
}

char *get_str_buggy() { return "Hello!"; }

void test_get_str_buggy() {
  char *str = get_str_buggy();
  // Will crash the program (segfault)!
  str[0] = 'J';
  printf("%s\n", str);
}

/*
 * When returning string literals, you are actually returning a const
 * pointer to a char. The function declaration should reflect that.
 */

const char *get_str() { return "Hello"; }

void test_get_str() {
  const char *str = get_str_buggy();
  // Compiler will throw an error (program does not crash at runtime).
  // NOTE: It is commented so the program can run, try uncommenting.
  // str[0] = 'J';
  printf("%s\n", str);
}

void change_number_buggy(int x) { x = 0; }

void test_change_number_buggy() {
  int x = 22;
  change_number_buggy(x);
  printf("%d\n", x);
}

void change_number(int *x) { *x = 0; }

void test_change_number() {
  int x = 22;
  change_number(&x);
  printf("%d\n", x);
}