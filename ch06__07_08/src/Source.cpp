#include <iostream>
#include <iomanip>
#include <thread>
#include <chrono>
#include <random>
#include <limits>
#include "AlignedMem.h"

extern "C" void AVXTransposeMat4x4_ (float *);

extern "C" void AVXMultiplyMat4x4_ (const float *mat1, const float *mat2, float *result);

class Mat4x4
{
public:
	Mat4x4 (float in = 0)
		: data{in, in, in, in, in, in, in, in, in, in, in, in, in, in, in, in}
	{}
	Mat4x4 (float in01, float in02, float in03, float in04, float in05, float in06, float in07, float in08, float in09, float in10, float in11, float in12, float in13, float in14, float in15, float in16)
		: data{in01, in02, in03, in04, in05, in06, in07, in08, in09, in10, in11, in12, in13, in14, in15, in16}
	{}
	operator float *() {
		return data;
	}
	Mat4x4 operator*(const Mat4x4 &other)
	{
		Mat4x4 matrix;

		AVXMultiplyMat4x4_ (data, other.data, matrix.data);
		return matrix;
	}
private:
	float data[16];
};
template<typename Typ>
Typ transpose (Typ)
{
	static_assert(false);
	return Typ ();
}

Mat4x4 transpose (Mat4x4 in)
{
	AVXTransposeMat4x4_ (in);
	return in;
}

template<typename Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1, bool floaty = false)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 1, 160 };
	default_random_engine rng{ seed };

	if (floaty)
		for (size_t i = 0; i < in_size; i++)
			in[i] = Typ (ui_dist (rng)) / Typ (ui_dist (rng));
	else for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng));
}
int main ()
{
	using namespace std;
	
	Mat4x4 matrix (10.0, 11.0, 12.0, 13.0,
				   20.0, 21.0, 22.0, 23.0,
				   30.0, 31.0, 32.0, 33.0,
				   40.0, 41.0, 42.0, 43.0);
	//Init<float> (matrix, 16);

	cout << "\n\nmatrix = \n";
	for (size_t i = 0; i < 16; i+=4)
	{
		float *ptr = matrix;
		cout << setw(4) << ptr[i] << ", " << setw(4) << ptr[i+1] << ", " << setw(4) << ptr[i+2] << ", " << setw(4) << ptr[i+3] << '\n';
	}
	
	matrix = transpose (matrix);

	cout << "\n\ntranspose (matrix) = \n";
	for (size_t i = 0; i < 16; i += 4) {
		float *ptr = matrix;
		cout << setw(4) << ptr[i] << ", " << setw(4) << ptr[i+1] << ", " << setw(4) << ptr[i+2] << ", " << setw(4) << ptr[i+3] << '\n';
	}

	matrix = transpose (matrix)*Mat4x4 (100.0, 101.0, 102.0, 103.0,
							200.0, 201.0, 202.0, 203.0,
							300.0, 301.0, 302.0, 303.0,
							400.0, 401.0, 402.0, 403.0);

	cout << "\n\nmatrix * anotherMat = \n" << setprecision(8);
	for (size_t i = 0; i < 16; i += 4) {
		float *ptr = matrix;
		cout << setw(20) << ptr[i] << ", " << setw(20) << ptr[i+1] << ", " << setw(20) << ptr[i+2] << ", " << setw(20) << ptr[i+3] << '\n';
	}

	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};