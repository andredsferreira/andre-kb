// INCOMPLETE

#include <stdio.h>
#include <string.h>

#define BUFF_SIZE 8

int elems[BUFF_SIZE];

void topk_elem(int nums[], unsigned int len, unsigned int k) {
  int a = 0;
  for (int i = 0; i < len; i++) {
    int current = nums[i];
    int occurrences = 1;
    for (int j = i + 1; j < len; j++) {
      if (nums[j] == current) {
        occurrences++;
      }
    }
    elems[a] = current;
    a++;
    elems[a] = occurrences;
    a++;
  }
}


int main() {
  int nums[] = {88, 2, 2, 2, 3, 3, 3, 3};
  int len = sizeof(nums) / sizeof(int);
  int k = 2;

  memset(elems, 0, BUFF_SIZE);

  topk_elem(nums, len, k);

  for (int i = 0; i < BUFF_SIZE; i++) {
    printf("elems[%d]=%d\n", i, elems[i]);
  }

  return 0;
}