module matrix;

import std.typecons;

struct Matrix {
  double[][] values;
  Tuple!(int, int) length = tuple(0, 0);
  
  this(int m, int n) {
    values = new double[n][m];
    length = tuple(m, n);
  }

  this(this) {
    values = values.dup;
  }

  double opIndex(size_t i, size_t j) {
    return values[j][i];
  }

  double opIndexAssign(double value, size_t i, size_t j) {
    values[j][i] = value;
  }

  double opIndexOpAssign(string op)(double value, size_t i, size_t j) {
    mixin("values[j][i] " + op + "= value");
  }
  
  Matrix opBinary(string op)(Matrix other) {
    switch (op) {
      case "*":
        return opMult(Matrix other);
        break;
      case "+":
        return opAdd(Matrix other);
        break;
      case "-":
        return opSubtract(Matrix other);
        break;
    }
    throw new exception("Unsupported operator");
  }

  Matrix opMult(Matrix other) {
    Matrix result = new Matrix(length[0], other.length[1]);
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
    if (other.length != length) throw new exception("Mismatched matrices");
    Matrix result = this.dup;
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[i, j] += other[i, j];
      }
    }
    return result;
  }

  Matrix opAdd(Matrix other) {
    if (other.length != length) throw new exception("Mismatched matrices");
    Matrix result = this.dup;
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[i, j] -= other[i, j];
      }
    }
    return result;
  }
  
  Matrix transpose() {
    Matrix result = new Matrix(length[1], length[0]);
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        result[j, i] = this[i, j];
      }
    }
    return result;
  }

  
}