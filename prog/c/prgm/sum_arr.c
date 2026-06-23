#include <stdio.h>

int sum_arr(int *arr);

int main() {
  int arr[3] = {1, 2, 3};
  int sum = sum_arr(arr);

  printf("sum = %d\n", sum);

  return 0;
}
