#include <iostream>

#ifdef HAS_ARMADILLO
#include <armadillo>
#endif

#include <chrono>

#include "operators_bases.h"

int main() 
{
  SimQ::QBit q1 = SimQ::QBases::KetZero;
  SimQ::QBit q2 = SimQ::QBases::KetZero;

  q1 = SimQ::QOps::H * q1;

  auto qbitsTensor = SimQ::KroneckerProduct(q1, q2);

  std::cout << SimQ::QOps::CNOT * qbitsTensor << '\n';
}