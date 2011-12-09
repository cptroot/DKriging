module matrix;

import std.typecons;
import std.math : abs;
import std.conv;
import std.stdio;

struct Matrix {
  double[][] values;
  Tuple!(int, int) length = tuple(1, 1);
  
  this(int m, int n) {
    values = new double[][n];
    foreach (j; 0..n) {
      values[j] = new double[m];
      foreach (i; 0..m) {
        values[j][i] = 0;
      }
    }
    length = tuple(m, n);
  }

  this(this) {
    values = values.dup;
  }

  double opIndex(size_t i, size_t j) {
    debug writeln(i, " ", j, " ", length);
    return values[j][i];
  }

  void opIndexAssign(double value, size_t i, size_t j) {
    debug writeln(value, " ", i, " ", j, " ", length);
    values[j][i] = value;
  }

  void opIndexOpAssign(string op)(double value, size_t i, size_t j) {
    mixin("values[j][i] " ~ op ~ "= value;");
  }
  
  Matrix opBinary(string op)(Matrix other) {
    switch (op) {
      case "*":
        return opMult(other);
        break;
      case "+":
        return opAdd(other);
        break;
      case "-":
        return opSubtract(other);
        break;
    }
    throw new Exception("Unsupported operator");
  }

  Matrix opMult(Matrix other) {
    Matrix result = Matrix(length[0], other.length[1]);
    double sum;
    foreach (i; 0..length[0]) {
      foreach (j; 0..other.length[1]) {
        foreach (n; 0..length[1]) {
          sum += this[i, n] * other[n, j];
        }
        result[i, j] = sum;
      }
    }
    return result;
  }

  Matrix opAdd(Matrix other) {
    if (other.length != length) throw new Exception("Mismatched matrices");
    Matrix result = this;
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[i, j] += other[i, j];
      }
    }
    return result;
  }

  Matrix opSubtract(Matrix other) {
    if (other.length != length) throw new Exception("Mismatched matrices");
    Matrix result = this;
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[i, j] -= other[i, j];
      }
    }
    return result;
  }
  
  Matrix transpose() {
    Matrix result = Matrix(length[1], length[0]);
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[j, i] = this[i, j];
      }
    }
    return result;
  }

  Matrix augment(Matrix other) {
    debug writeln("augment");
    if (length[0] != other.length[0]) throw new Exception("Mismatched lengths");
    Matrix result = Matrix(length[0], length[1] + other.length[1]);
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[i, j] = this[i, j];
      }
      foreach (j; 0..other.length[1]) {
        result[i, j + length[1]] = other[i, j];
      }
    }
    return result;
  }

  static Matrix identity(int n) {
    Matrix result = Matrix(n, n);
    foreach (i; 0..n) {
      result[i, i] = 1;
    }
    return result;
  }

  Matrix inverse() {
    if (length[0] != length[1]) throw new Exception("Non-Square Matrix");
    debug writeln("inverse()");
    Matrix augmented = this.augment(identity(length[1]));
    double eps = .00000000001;

    int h = length[0];
    int w = length[0] * 2;
    double c;
    foreach (y; 0..h){
      int maxrow = y;
      debug writeln("Find Max Pivot");
      foreach (i; y+1..h) {    // Find max pivot
        if (to!double(abs(augmented[i, y])) > to!double(abs(augmented[maxrow, y]))) {
          maxrow = i;
        }
      }
      double[] temp;
      temp = values[y];
      values[y] = values[maxrow];
      values[maxrow] = temp;
      
      debug writeln("Singular?");
      if (to!double(abs(augmented[y, y])) <= eps)     // Singular?
        return Matrix.init;
      debug writeln("Eliminate column y");
      foreach (i; y+1..h) {   // Eliminate column y
        c = augmented[i, y] / augmented[y, y];
        foreach (x; y..w) 
          augmented[i, x] -= augmented[y, x] * c;
      }
    }
    debug writeln("Backsubstitute");
    for (int y = h-1; y > -1; y--) { // Backsubstitute
      c  = augmented[y, y];
      foreach (i; 0..y) {
        for (int x = w - 1; x > y - 1; x--) {
          augmented[i, x] -=  augmented[y, x] * augmented[i, y] / c;
        }
      }
      augmented[y, y] /= c;
      foreach (x; h..w) {       // Normalize row y
        augmented[y, x] /= c;
      }
    }
    Matrix result = Matrix(h, h);
    foreach (i; 0..h) {
      foreach (j; 0..h) {
        result[i, j] = augmented[i, j + h];
      }
    }
    return result;
  }
}