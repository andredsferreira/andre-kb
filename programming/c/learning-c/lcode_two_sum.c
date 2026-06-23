#include <stdio.h>
#include <stdlib.h>

typedef struct {
  unsigned char i;
  unsigned char j;
} Indices;
      
Indices two_sum(int nums[], int len, int target) {
  for (int i = 0; i < len; i++) {
    for (int j = i + 1; j < len; j++) {
      if (nums[i] + nums[j] == target) {
        return (Indices){i, j};
      }
    }
  }
  fprintf(stderr, "Error: no valid indices found for the target.\n");
  exit(EXIT_FAILURE);
}

int main() {
  int arr[] = {2, 7, 3, 15};
  int target = 10;

  Indices indices = two_sum(arr, 4, target);

  printf("Indices found: %d, %d\n", indices.i, indices.j);

  return 0;
}