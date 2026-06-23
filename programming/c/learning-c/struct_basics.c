#include <stdio.h>

typedef struct {
  int x;
  int y;
} Point;

typedef struct {
  char name[64];
  unsigned short age;
  float grade_avg;
} Student;

// Gets a copy of the struct, not modifying the original.

void change_coords_buggy(Point p, int new_x, int new_y) {
  p.x = new_x;
  p.y = new_y;
}

void change_coords(Point *p, int new_x, int new_y) {
  p->x = new_x;
  p->y = new_y;
}

void change_coords_v2(int *old_x, int new_x, int *old_y, int new_y) {
  *old_x = new_x;
  *old_y = new_y;
}

int main() {
  Point a = {2, 2};
  Point b = {-2, 1};

  printf("A(%d,%d)\n", a.x, a.y);
  printf("B(%d,%d)\n", b.x, b.y);

  change_coords(&a, 80, 80);
  printf("A(%d,%d)\n", a.x, a.y);

  change_coords_v2(&a.x, 2, &a.y, 2);
  printf("A(%d,%d)\n", a.x, a.y);

  printf("Size of the struct Point: %lu bytes\n", sizeof(Point));
  printf("Size of the struct Student: %lu bytes\n", sizeof(Student));

  return 0;
}