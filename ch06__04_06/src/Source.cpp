#include <iostream>
#include <iomanip>
#include <thread>
#include <chrono>
#include <random>
#include <limits>
#include "AlignedMem.h"

extern "C" bool  AVXPackedSqrtsF32Array_ (float*src, float*dest, uint32_t length);

extern "C" float g_MinValInit = -std::numeric_limits<float>::max (); // See FLT_MAX & FLT_MIN
extern "C" float g_MaxValInit =  std::numeric_limits<float>::max (); // See FLT_MAX & FLT_MIN
extern "C" bool  AVXMinMaxFromPackedF32Array_ (const float *arr, float &, float &, size_t n);

extern "C" double LsEpsilon = 1.0e-12;
extern "C" bool  AVXLeastSquaresFromPackedF64Array_ (const double *x, const double *y, int32_t n, double *m, double *b);

template<typename Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1, bool floaty = false)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 1, 2000 };
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
	{
		constexpr size_t n = 19;
		alignas(16) float x[n]; // align address to a 16-byte boundary i.e (uintptr_t)x % 16 = 0 or uint64_t(x) % 16 = 0 (in 64bit platform)
		alignas(16) float y[n]; // align address to a 16-byte boundary i.e (uintptr_t)y % 16 = 0 or uint64_t(x) % 16 = 0 (in 64bit platform)

		Init (x, n);

		bool success = AVXPackedSqrtsF32Array_ (x, y, n);

		cout << fixed << setprecision (4);
		cout << "\nResults for AVXPackedSqrtsF32Array_:\n";
		for (size_t i = 0; i < n; i++)
			cout << "#" << i << "  x: " << setw (8) << x[i] << " y: " << setw (8) << y[i] << '\n';
	}
	std::cout << "\n\n\n";
	{
		constexpr size_t length = 10;
		alignas(16) float arr[10] = { 9,4,3,6,2,11,54,14,4,7 };
		
		if (!AlignedMem::IsAligned (arr, 16))
			__debugbreak ();

		for (size_t i = 0; i < length; i++)
			cout << "#" << i << "  " << arr[i] << '\n';
		float min_t, max_t;
		AVXMinMaxFromPackedF32Array_ (arr, min_t, max_t, length);
		cout << "------------\nmin: " << min_t << "\nmax: " << max_t;
	}
	std::cout << "\n\n\n";
	{
		constexpr int32_t n = 11;
		alignas(16) double x[n] = { 10, 13, 17, 19, 23, 7, 35, 51, 89, 92, 99 };
		alignas(16) double y[n] = { 1.2, 1.1, 1.8, 2.2, 1.9, 0.5, 3.1, 5.5, 8.4, 9.7, 10.4 };
		
		// Init (x, n), Init (y, n, 20,true);
		double m, b;

		bool success = AVXLeastSquaresFromPackedF64Array_ (x, y, n, &m, &b);
		cout << "index      x        y\n";
		for (size_t i = 0; i < n; i++)
			cout << "#" << i << "  " << x[i] << "  " << y[i] << '\n';
		cout << "\nslope: " << m;
		cout << "\nintercept: " << b << "  good{" << success << "}";
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};