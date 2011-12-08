module matrix;

import std.typecons;

struct Matrix {
  double[][] values;
  Tuple!(int, int) length = tuple(1, 1);
  
  this(int m, int n) {
    values = new double[][m];
    length = tuple(m, n);
  }

  this(this) {
    values = values.dup;
  }

  double opIndex(size_t i, size_t j) {
    return values[j][i];
  }

  void opIndexAssign(double value, size_t i, size_t j) {
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

  Matrix augment(Matrix other) if (length[0] == other.length[0]) {
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

  Matrix inverse() if (length[0] == length[1]) {
    Matrix augmented = this.augment(identity(length[1]));
    return augmented;

    //Not Done!!
  }
}