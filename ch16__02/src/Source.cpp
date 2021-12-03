#include <iostream>
#include <fstream>
#include <iomanip>
#include <thread>
#include <chrono>
#include <random>
#include <concepts>
#include "AlignedMem.h"

#define   _USE_MATH_DEFINES
#include <math.h>

extern "C" bool CalcResultA_(float *c, const float *a, const float *b, const size_t n);
extern "C" bool CalcResultB_(float *c, const float *a, const float *b, const size_t n);

uint32_t g_RngSeedVal = 100;

template<typename Typ> requires std::floating_point<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 1, 160 };
	default_random_engine rng{ seed };

	for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng)) / Typ (ui_dist (rng));
}

bool CalcResultCpp (float *c, const float *a, const float *b, const size_t n)
{
	constexpr size_t align = 32;

	if ((n == 0) || ((n & 0x0f) != 0))
		return false;

	if (!AlignedMem::IsAligned (a, align))
		return false;
	if (!AlignedMem::IsAligned (b, align))
		return false;
	if (!AlignedMem::IsAligned (c, align))
		return false;

	for (size_t i = 0; i < n; i++)
		c[i] = sqrt (a[i] * a[i] + b[i] * b[i]);

	return true;
}
void CampareResults (const float *c1, const float *c2a, const float *c2b, const size_t n)
{
	bool campare_ok = true;
	const float epsilon = 1.0e-9f;

	std::cout << std::fixed << std::setprecision (4);
	for (size_t i = 0; i < n && campare_ok; i++) {
		bool b1 = fabs (c1[i] - c2a[i]) > epsilon;
		bool b2 = fabs (c1[i] - c2b[i]) > epsilon;

		std::cout
			<< std::setw ( 2) << i << ' '
			<< std::setw (10) << c1 [i] << ' '
			<< std::setw (10) << c2a[i] << ' '
			<< std::setw (10) << c2b[i] << '\n';

		if (b1||b2)
			campare_ok = false;
	}

	if (campare_ok)
		std::cout << "Array campare Success\n";
	else
		std::cout << "Array campare Failed\n";
}
void NonTemporalStore ()
{
	constexpr size_t n = 16;
	constexpr size_t align = 32;
	AlignedMem::AlignedArray<float> a_aa (n, align);
	AlignedMem::AlignedArray<float> b_aa (n, align);
	AlignedMem::AlignedArray<float> c1_aa (n, align);
	AlignedMem::AlignedArray<float> c2a_aa (n, align);
	AlignedMem::AlignedArray<float> c2b_aa (n, align);
	float *a = a_aa.Data ();
	float *b = b_aa.Data ();
	float *c1 = c1_aa.Data ();
	float *c2a = c2a_aa.Data ();
	float *c2b = c2b_aa.Data ();

	Init (a, n, 67);
	Init (b, n, 68);

	bool rc1 = CalcResultCpp (c1 , a, b, n);
	bool rc2 = CalcResultA_  (c2a, a, b, n);
	bool rc3 = CalcResultB_  (c2b, a, b, n);

	if (!rc1 || !rc2 || !rc3) {
		std::cout << "Invalid return code\n"
			<< "  rc1: " << std::boolalpha << rc1 << '\n'
			<< "  rc2: " << std::boolalpha << rc2 << '\n'
			<< "  rc3: " << std::boolalpha << rc3 << '\n';
		return;

	}
	std::cout << "Results for non-temporal store:\n";
	CampareResults (c1, c2a, c2b, n);
}
int main ()
{
	NonTemporalStore ();
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};