/**
 * This program demonstrates dynamic memory allocation. It asks the user
 * to enter the size of an array, allocates memory for the array, initializes
 * the array with some numbers printing them. Finally it frees the memory
 * allocated for the array.
 */

#include <stdio.h>
#include <stdlib.h>

int main() {
  unsigned short array_size;

  printf("Enter the size of the array: ");
  scanf("%hu", &array_size);

  int* arr = malloc(array_size * sizeof(int));
  if (arr == NULL) {
    fprintf(stderr, "memory allocation failed\n");
    exit(EXIT_FAILURE);
  }

  for (int i = 0; i < array_size; i++) {
    arr[i] = i + 1;
  }

  printf("Your array: ");
  for (int i = 0; i < array_size; i++) {
    printf("%d ", arr[i]);
  }
  printf("\n");

  free(arr);
  arr = NULL;

  return 0;
}