import std.stdio;

import matrix;

void main() {
  Matrix m = Matrix(3, 3);
  m[0, 0] = 2;
  m[0, 1] = -1;
  m[1, 0] = -1;
  m[1, 1] = 2;
  m[1, 2] = -1;
  m[2, 1] = -1;
  m[2, 2] = 2;

  writeln(m.values);
  
  Matrix result = m.inverse();
  writeln(result.values);
}