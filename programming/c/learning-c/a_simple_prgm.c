#include <stdio.h>

int arr_sum(int *arr, int len) {
  int sum=0;
  for (int i = 0; i < len; i++) {
    sum+= arr[i];
  }
  return sum;
}

void print_arr_addr(int*arr, int len) {
  for (int i = 0; i < len; i++) {
    printf("%p\n", arr);
    arr++;
  }
}


int main() {
  int arr[] = {1,2,4,8};
  int sum = arr_sum(arr, 4);
  
  printf("sum    = %d\n", sum);
  printf("sizeof = %lu\n", sizeof(arr));

  printf("addresses:\n");
  print_arr_addr(arr, 4);

}