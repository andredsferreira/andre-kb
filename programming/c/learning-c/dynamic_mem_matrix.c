/**
 * @brief Same as c01.c but for a 2D array.
 */

#include <stdio.h>
#include <stdlib.h>

void init_2D(int** arr, unsigned short rows, unsigned short cols) {
  printf("Your array:\n");
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      arr[i][j] = i * cols + j + 1;
    }
  }
}

void print_2D(int** arr, unsigned short rows, unsigned short cols) {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      printf("%d ", arr[i][j]);
    }
    printf("\n");
  }
}

int main() {
  unsigned short rows, cols;

  printf("Enter the rows of the array: ");
  scanf("%hu", &rows);
  printf("Enter the columns of the array: ");
  scanf("%hu", &cols);

  int** arr = malloc(rows * sizeof(int*));
  if (arr == NULL) {
    fprintf(stderr, "memory allocation failed\n");
    exit(EXIT_FAILURE);
  }

  for (int i = 0; i < rows; i++) {
    arr[i] = malloc(cols * sizeof(int));
    if (arr[i] == NULL) {
      fprintf(stderr, "memory allocation failed\n");
      exit(EXIT_FAILURE);
    }
  }

  init_2D(arr, rows, cols);

  print_2D(arr, rows, cols);

  for (int i = 0; i < rows; i++) {
    free(arr[i]);
    arr[i] = NULL;
  }

  free(arr);
  arr = NULL;

  return 0;
}