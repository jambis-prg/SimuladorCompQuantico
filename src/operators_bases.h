#pragma once

#include <Eigen/Dense>
#include <complex>

namespace SimQ
{
    using complex_f64 = std::complex<double>;
    using QMatrix2 = Eigen::Matrix2cd;
    using QMatrix4 = Eigen::Matrix4cd;
    using QBit = Eigen::Vector2cd;

    namespace QBases
    {
        static const QBit KetZero {
        complex_f64(1, 0), 
        complex_f64(0, 0)
        };

        static const QBit KetOne {
        complex_f64(0, 0), 
        complex_f64(1, 0)
        };

        static const QBit KetPlus {
        complex_f64(1/sqrt(2), 0), 
        complex_f64(1/sqrt(2), 0)
        };

        static const QBit KetMinus {
        complex_f64(1/sqrt(2), 0), 
        complex_f64(-1/sqrt(2), 0)
        };

        static const QBit KetI {
        complex_f64(1/sqrt(2), 0), 
        complex_f64(0, 1/sqrt(2))
        };

        static const QBit KetNegI {
        complex_f64(1/sqrt(2), 0), 
        complex_f64(0, -1/sqrt(2))
        };
    }

    namespace QOps
    {
        static const QMatrix2 I = Eigen::Matrix2cd::Identity();

        static const QMatrix2 GlobalPhase(double phase)
        {
        return std::polar(1.0, phase) * I;
        }

        static const QMatrix2 H {
        {complex_f64(1/sqrt(2), 0), complex_f64(1/sqrt(2), 0)},
        {complex_f64(1/sqrt(2), 0), complex_f64(-1/sqrt(2), 0)}
        };

        static const QMatrix2 X {
        {complex_f64(0, 0), complex_f64(1, 0)},
        {complex_f64(1, 0), complex_f64(0, 0)}
        };

        static const QMatrix2 Y {
        {complex_f64(0, 0), complex_f64(0, -1)},
        {complex_f64(0, 1), complex_f64(0, 0)}
        };

        static const QMatrix2 Z {
        {complex_f64(1, 0), complex_f64(0, 0)},
        {complex_f64(0, 0), complex_f64(-1, 0)}
        };

        static const QMatrix2 S {
        {complex_f64(1, 0), complex_f64(0, 0)},
        {complex_f64(0, 0), complex_f64(0, 1)}
        };

        static const QMatrix4 CNOT {
        {complex_f64(1, 0), complex_f64(0, 0), complex_f64(0, 0), complex_f64(0, 0)},
        {complex_f64(0, 0), complex_f64(1, 0), complex_f64(0, 0), complex_f64(0, 0)},
        {complex_f64(0, 0), complex_f64(0, 0), complex_f64(0, 0), complex_f64(1, 0)},
        {complex_f64(0, 0), complex_f64(0, 0), complex_f64(1, 0), complex_f64(0, 0)}
        };
    } // namespace QOps

    template<typename MatrixA, typename MatrixB>
    Eigen::Matrix<typename MatrixA::Scalar, Eigen::Dynamic, Eigen::Dynamic>
    KroneckerProduct(const MatrixA& A, const MatrixB& B) 
    {
        Eigen::Index rowsA = A.rows();
        Eigen::Index colsA = A.cols();
        Eigen::Index rowsB = B.rows();
        Eigen::Index colsB = B.cols();

        Eigen::Matrix<typename MatrixA::Scalar, Eigen::Dynamic, Eigen::Dynamic> result(rowsA * rowsB, colsA * colsB);

        for (Eigen::Index i = 0; i < rowsA; ++i) {
            for (Eigen::Index j = 0; j < colsA; ++j) {
                result.block(i * rowsB, j * colsB, rowsB, colsB) = A(i, j) * B;
            }
        }

        return result;
    }
} // namespace SimQ