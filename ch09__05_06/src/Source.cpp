#include <iostream>

#include <thread>
#include <chrono>

#define _USE_MATH_DEFINES
#include <math.h>

extern "C" void AVXMat4x4TransposeF64_ (double *src_mat_ptr, double *dest_mat_ptr);
extern "C" void AVXMat4x4MultiplyF64_ (double *src1_mat_ptr, double *src2_mat_ptr, double *dest_mat_ptr);

extern "C" bool AVX2Mat4x4InvertF64_ (double *src_mat_ptr, double *dest_mat_ptr, const double epsilon, bool& isSingular);
int main ()
{
	using namespace std;
	{
		constexpr size_t matrix_size = 4*4;
		alignas(32) double matrix4x4[matrix_size] = {
			1,2,3,4,
			1,2,3,4,
			1,2,3,4,
			1,2,3,4
		};
		cout << fixed << setprecision (2);
		cout << "orignal Matrix:\n";
		for (size_t i = 0; i < matrix_size; i++)
			cout << setw (8) << matrix4x4[i] << (i%4 == 3 ? '\n' : ' ');

		alignas(32) double dest_matrix[matrix_size];
		AVXMat4x4TransposeF64_ (matrix4x4, dest_matrix);
		cout << "transposed Matrix:\n";
		for (size_t i = 0; i < matrix_size; i++)
			cout << setw (8) << dest_matrix[i] << (i%4 == 3 ? '\n' : ' ');

		alignas(32) double dest2_matrix[matrix_size];
		AVXMat4x4MultiplyF64_ (matrix4x4, dest_matrix, dest2_matrix);
		cout << "result of multiply:\n";
		for (size_t i = 0; i < matrix_size; i++)
			cout << setw (8) << dest2_matrix[i] << (i%4 == 3 ? '\n' : ' ');
	}
	cout << '\n' << '\n';
	{
		{
			constexpr size_t matrix_size = 4*4; constexpr double epsilon = 1.0e-12;
			alignas(32) double matrix4x4[matrix_size] = {
				2  ,7   ,3    ,4,
				5  ,9   ,6    ,4.75,
				6.5,3   ,4    ,10,
				7  ,5.25,8.125,6
			};
			cout << fixed << setprecision (2);
			cout << "orignal(non-singular) Matrix:\n";
			for (size_t i = 0; i < matrix_size; i++)
				cout << setw (8) << matrix4x4[i] << (i%4 == 3 ? '\n' : ' ');

			alignas(32) double dest_matrix[matrix_size];
			bool isSingular, success = AVX2Mat4x4InvertF64_ (matrix4x4, dest_matrix, epsilon, isSingular);
			cout << "inverted Matrix:\n";
			for (size_t i = 0; i < matrix_size; i++)
				cout << setw (8) << dest_matrix[i] << (i%4 == 3 ? '\n' : ' ');

			alignas(32) double dest_matrix2[matrix_size];
			bool isSingular2, success2 = AVX2Mat4x4InvertF64_ (dest_matrix, dest_matrix2, epsilon, isSingular2);
			cout << "re-inverted Matrix:\n";
			for (size_t i = 0; i < matrix_size; i++)
				cout << setw (8) << dest_matrix2[i] << (i%4 == 3 ? '\n' : ' ');
			cout << "good(" << success2 << ") isSingular(" << isSingular2 << ")\n";
		}
		{
			constexpr size_t matrix_size = 4*4; constexpr double epsilon = 1.0e-12;
			alignas(32) double matrix4x4[matrix_size] = {
				2  ,0   ,0    ,1,
				0  ,4   ,5    ,0,
				0  ,0   ,0    ,7,
				0  ,0   ,0    ,6
			};
			cout << fixed << setprecision (2);
			cout << "orignal(non-singular) Matrix:\n";
			for (size_t i = 0; i < matrix_size; i++)
				cout << setw (8) << matrix4x4[i] << (i%4 == 3 ? '\n' : ' ');

			alignas(32) double dest_matrix[matrix_size];
			bool isSingular, success = AVX2Mat4x4InvertF64_ (matrix4x4, dest_matrix, epsilon, isSingular);
			cout << "inverted Matrix:\n";
			for (size_t i = 0; i < matrix_size; i++)
				cout << setw (8) << dest_matrix[i] << (i%4 == 3 ? '\n' : ' ');
			cout << "good(" << success << ") isSingular(" << isSingular << ")\n";
		}
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};