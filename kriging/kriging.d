module kriging;
import std.stdio;
import std.typecons;

import matrix;

alias Tuple!(double, double, double) Point;
//value, x, y

double krige(Point[] points, Tuple!(double, double) unknown) {
  Matrix mat = krigingMatrix(points);
  return krigeMatrix(points, unknown, mat);
}

Matrix krigingMatrix(Point[] points) {
  double x, y;
  Matrix result = Matrix(points.length + 1, points.length + 1);
  foreach (i; 0..points.length - 1) {
    foreach (j; i + 1..points.length) {
      x = points[i][1] - points[j][1];
      y = points[i][2] - points[j][2];
      result[i, j] = (x * x + y * y) / 2;
      result[j, i] = result[i, j];
    }
  }
  foreach (i; 0..points.length) {
    result[i, points.length] = 1;
    result[points.length, i] = 1;
  }
  return result.inverse;
}

double krigeMatrix(Point[] points, Tuple!(double, double)unknown, Matrix matrix) {
  debug writeln("krige ", matrix.values);
  Matrix k = Matrix(points.length + 1, 1);
  double x, y;
  foreach (i; 0..points.length) {
    x = points[i][1] - unknown[0];
    y = points[i][2] - unknown[1];
    k[i, 0] = (x * x + y * y) / 2;
  }
  k[points.length, 0] = 1;
  Matrix w = matrix * k;
  Matrix v = Matrix(points.length + 1, 1);
  foreach (i; 0..points.length) {
    v[i, 0] = points[i][0];
  }
  Matrix result = v.transpose;
  result = result * w;
  return result[0, 0];
}