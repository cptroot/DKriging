import std.stdio;
import std.typecons;

import kriging.matrix;
import kriging.krige;
alias Tuple!(double, double, double) Point;

void main() {
  Point[] points;
  points ~= tuple(1., 0., 0.);
  points ~= tuple(2., 1., 0.);
  points ~= tuple(-1., 1., 2.);
  points ~= tuple(.25, 2., 1.);
  points ~= tuple(1., 2.5, 1.);
  points ~= tuple(1.3, .5, .5);
  Tuple!(double, double) unknown = tuple(1, 0);
  writeln(krige(points, unknown));
}