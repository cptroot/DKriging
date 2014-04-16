module kriging.matrix;

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
    //debug writeln(i, " ", j, " ", length);
    if (i >= length[0] || j >= length[1]) throw new Exception("Range violation");
    return values[j][i];
  }

  void opIndexAssign(double value, size_t i, size_t j) {
    //debug writeln(value, " ", i, " ", j, " ", length);
    if (i >= length[0] || j >= length[1]) throw new Exception("Range violation");
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
      default:
        throw new Exception("Unsupported operator: " ~ op);
        break;
    }
    throw new Exception("Unsupported operator");
  }

  Matrix opMult(Matrix other) {
    debug writeln("opMult()");
    Matrix result = Matrix(length[0], other.length[1]);
    double sum;
    foreach (i; 0..length[0]) {
      foreach (j; 0..other.length[1]) {
        sum = 0;
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
    debug writeln("transpose ", result.values);
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

    int m = length[0];
    int n = length[0] * 2;
    double c;
    foreach (k; 0..m){
      debug writeln("k: ", k);
      
      debug augmented.display();
      int maxrow = k;
      debug writeln("Find Max Pivot");
      foreach (i; k+1..m) {    // Find max pivot
        if (to!double(abs(augmented[i, k])) > to!double(abs(augmented[maxrow, k]))) {
          maxrow = i;
        }
      }
      
      debug writeln("Singular?");
      debug writeln("maxrow: ", maxrow);
      //debug writeln(augmented[maxrow, k], " ", eps);
      if (abs(augmented[maxrow, k]) == 0) {
        throw new Exception("Singular");
      }
      //Swap kth row with maxrowth row
      double temp;
      foreach (j; 0..n) {
        temp = augmented[k, j];
        augmented[k, j] = augmented[maxrow, j];
        augmented[maxrow, j] = temp;
      }
      
      debug writeln("Swap rows");
      debug augmented.display();
      debug writeln("Eliminate column ", k);
      foreach (i; k+1..m) {   // Eliminate column k
        c = augmented[i, k] / augmented[k, k];
        foreach (j; k..n) {
          augmented[i, j] -= augmented[k, j] * c;
          //if (abs(augmented[i, j]) <= eps) augmented[i, j] = 0;
        }
      }
    }
    debug writeln("Backsubstitute");
    for (int k = m-1; k > -1; k--) { // Backsubstitute
      c  = augmented[k, k];
      foreach (i; 0..k) {
        for (int j = n - 1; j > k - 1; j--) {
          augmented[i, j] -= augmented[k, j] * augmented[i, k] / c;
          if (abs(augmented[i, j]) <= eps) augmented[i, j] = 0;
        }
      }
      augmented[k, k] /= c;
      foreach (j; m..n) {       // Normalize row k
        augmented[k, j] /= c;
      }
    }
    Matrix result = Matrix(m, m);
    foreach (i; 0..m) {
      foreach (j; 0..m) {
        result[i, j] = augmented[i, j + m];
      }
    }
    debug augmented.display();
    return result;
  }

  void display() {
    foreach (i; 0..length[0]) {
      foreach (j; 0..length[1]) {
        writef("%+.2f  ", values[j][i]);
      }
      writeln();
    }
  }
}