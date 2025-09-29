#include <iostream>

#ifdef HAS_ARMADILLO
#include <armadillo>
#endif

#include <chrono>

#include <Eigen/Dense>
#include <complex>

using complex_f64 = std::complex<double>;

int main() 
{
  Eigen::Vector2cd v(complex_f64(0, 0), complex_f64(1, 0));

  std::cout << v << '\n';

  Eigen::Matrix2cd m;
  m << complex_f64(1, 0), complex_f64(1, 0), complex_f64(1, 0), complex_f64(-1, 0);

  std::cout << m << '\n';

  std::cout << sqrt(2) * m * v << '\n';
}