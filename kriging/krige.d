module kriging.krige;
import std.stdio;
import std.typecons;
import std.conv;

import kriging.matrix;

alias Tuple!(double, double, double) Point;
//value, x, y

double krige(Point[] points, Tuple!(double, double) unknown) {
  Matrix mat = krigingMatrix(points);
  return krigeMatrix(points, unknown, mat);
}

Matrix krigingMatrix(Point[] points) {
  double x, y;
  Matrix result = Matrix(to!int(points.length), to!int(points.length));
  foreach (i; 0..points.length) {
    foreach (j; i..points.length) {
      x = points[i][1] - points[j][1];
      y = points[i][2] - points[j][2];
      result[i, j] = covariance(x, y);
      result[j, i] = result[i, j];
    }
  }
  /*foreach (i; 0..points.length) {
    result[i, points.length] = 1;
    result[points.length, i] = 1;
  }*/
  debug result.display();
  return result.inverse;
}

double krigeMatrix(Point[] points, Tuple!(double, double)unknown, Matrix matrix) {
  debug writeln("krige ", matrix.values);
  Matrix k = Matrix(to!int(points.length), 1);
  double x, y;
  foreach (i; 0..points.length) {
    x = points[i][1] - unknown[0];
    y = points[i][2] - unknown[1];
    k[i, 0] = covariance(x, y);
  }
  Matrix w = matrix * k;
  Matrix v = Matrix(to!int(points.length), 1);
  foreach (i; 0..points.length) {
    v[i, 0] = points[i][0];
  }
  Matrix result = v.transpose;
  result = result * w;
  return result[0, 0];
}

double covariance(double x, double y) {
  double distance_square = (x * x + y * y) / 2;
  if (distance_square > 25) return 0;
  return 1 - distance_square / 25;
}