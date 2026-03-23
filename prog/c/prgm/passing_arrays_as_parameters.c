#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

/*
 * The type of an array argument of a function should always be a
 * pointer. C will naturally decay arrays to pointers:
 * int arr[] -> int *arr
 */

void print_arr(int *arr, size_t len) {
  for (int i = 0; i < len; i++) {
    printf("arr[%d] = %d\n", i, *arr++);
  }
}

void double_arr(int *arr, size_t len) {
  for (int i = 0; i < len; i++) {
    arr[i] = 2 * arr[i];
  }
}

void double_arr_ptr_version(int *arr, size_t len) {
  for (int i = 0; i < len; i++) {
    *arr = 2 * (*arr);
    arr++;
  }
}

/*
 * The type of a matrix argument of a function should also be a
 * pointer. The important distinction happens when calling the
 * function on the matrix. You should cast the matrix into a pointer
 * (see the calling of print_matrix() in main()).
 * A matrix does not decay into a double pointer (int **matrix).
 * For more info: https://www.youtube.com/watch?v=Cfm4D_Mxpiw.
 */

void print_matrix(int *matrix, size_t rows, size_t cols) {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      printf("matrix[%d][%d] = %d\n", i, j, matrix[i * cols + j]);
    }
  }
}

void print_matrix_gpt_version(int rows, int cols, int arr[rows][cols]) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%d ", arr[i][j]);
        }
        printf("\n");
    }
}


int main() {
  int arr[6] = {1, 2, 3, 4, 5, 6};
  double_arr(arr, 6);

  int matrix[3][3] = {
      {1, 2, 3},
      {1, 2, 3},
      {1, 2, 3},
  };

  print_arr(arr, 6);

  // Casting matrix to a pointer...
  print_matrix((int *)matrix, 3, 3);

  return 0;
}