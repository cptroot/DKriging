import std.stdio;
import std.typecons;

import matrix;
import kriging;
alias Tuple!(double, double, double) Point;

void main() {
  Point[] points;
  points ~= tuple(1., 0., 0.);
  points ~= tuple(2., 1., 0.);
  Tuple!(double, double) unknown = tuple(1.75, 0.);
  writeln(krige(points, unknown));
}