#include <iostream>
#include <iomanip>
#include <thread>
#include <chrono>
#include <random>
#include <limits>
#include <concepts>
#include "AlignedMem.h"

template<typename Typ> requires std::integral<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 0, 255 };
	default_random_engine rng{ seed };
	
	for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng));
}
template<typename Typ> requires std::floating_point<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 1, 160 };
	default_random_engine rng{ seed };
	
	for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng)) / Typ (ui_dist (rng));
}

extern "C" bool AVXCalcMinMaxU8_ (const uint8_t* data, size_t n, uint8_t& x_min, uint8_t& x_max);
void AVXCalcMinMaxU8 ();

// MAX~4048*4048 num of pixels(of 4 uint8_t channels) after that it may be inaccurate
extern "C" bool AVXCalcMeanU8_ (const uint8_t* data, size_t n, uint64_t& x_sum, double& x_mean);
void AVXCalcMeanU8 ();
// MAX~1677216
// Ch07_06_Misc.cpp
extern bool ConvertImgVerify (const float *src1, const float *src2, uint32_t num_pixels)
{
	bool return_me = true;
	std::cout << std::setprecision (4);
	for (uint32_t i = 0; i < num_pixels; i++)
	{
		bool cmp = (src1[i] != src2[i]);
		if (cmp)
			std::cout << '>';
		std::cout << std::setw (2) << src1[i] << std::setw (9) << src2[i] << '\n';
		return_me &= !cmp;
	}
	return return_me;
}
extern bool ConvertImgVerify  (const uint8_t *src1, const uint8_t *src2, uint32_t num_pixels)
{
	bool return_me = true;
	for (uint32_t i = 0; i < num_pixels; i++)
	{
		bool cmp = (src1[i] != src2[i]);
		if (cmp)
			std::cout << '>';
		std::cout << std::setw (4) << src1[i] << std::setw (4) << src2[i] << '\n';
		return_me &= !cmp;
	}
	return return_me;
}
extern "C" bool ConvertImgU8ToF32_(const uint8_t *src ,         float *des , uint32_t num_pixels);
extern "C" bool ConvertImgF32ToU8_(  const float *src ,       uint8_t *des , uint32_t num_pixels);
void ConvertBetweenU8AndF32 ();

int main ()
{
	//AVXCalcMinMaxU8 ();
	//std::cout << '\n' << '\n' << '\n';
	//AVXCalcMeanU8 ();
	//std::cout << '\n' << '\n' << '\n';
	ConvertBetweenU8AndF32 ();
	return 0;
};
void AVXCalcMinMaxU8 ()
{
	using namespace std;
	constexpr size_t n = 4 * 16*16; // 1024
	AlignedMem::AlignedArray<uint8_t> data (n, 16);
	Init (data.Data (), n, 32);

	constexpr size_t width = 40;
	for (size_t i = 0; i < n; i += width) {
		for (size_t j = 0; j < width && i+j < n; j++)
			cout << setw (4) << uint16_t (data[i + j]);

		cout << '\n';
	}
	uint8_t min = 100, max = 100;
	AVXCalcMinMaxU8_ (data.Data (), n, min, max);
	cout << " min: " << uint16_t (min) << " max: " << uint16_t (max);
}
void AVXCalcMeanU8 ()
{
	using namespace std;
	constexpr size_t n = 4 * 16*16; // 1024
	AlignedMem::AlignedArray<uint8_t> data (n, 16);
	Init (data.Data (), n, 32);

	constexpr size_t width = 40;
	for (size_t i = 0; i < n; i += width) {
		for (size_t j = 0; j < width && i+j < n; j++)
			cout << setw (4) << uint16_t (data[i + j]);

		cout << '\n';
	}
	uint64_t sum = 0;
	double mean = 0.0;
	AVXCalcMeanU8_ (data.Data (), n, sum, mean);
	std::cout << sum << ' ' << mean;
}
void ConvertBetweenU8AndF32 ()
{
	constexpr uint32_t num_pixel = 32;
	AlignedMem::AlignedArray<uint8_t> u8Pixarr (num_pixel, 16);
	Init (u8Pixarr.Data (), num_pixel);
	AlignedMem::AlignedArray<float> f32Pixarr (num_pixel, 16);
	
	AlignedMem::AlignedArray<uint8_t> u8Pixarr2 (num_pixel, 16);
	AlignedMem::AlignedArray<float> f32Pixarr2 (num_pixel, 16);

	ConvertImgU8ToF32_ (u8Pixarr.Data (), f32Pixarr.Data (), num_pixel);
	//std::cout << "> U8ToF32_\n";
	//for (uint32_t i = 0; i < num_pixel; i++) {
	//	std::cout << std::setw (4) << uint16_t(u8Pixarr[i]) << std::setw (8) << f32Pixarr[i]*255 << (i%8 == 7 ? "\n" : "  |  ");
	//}
	ConvertImgF32ToU8_ (f32Pixarr.Data(), u8Pixarr2.Data (), num_pixel);
	//std::cout << "> F32ToU8_\n";
	//for (uint32_t i = 0; i < num_pixel; i++) {
	//	std::cout << std::setw (4) << f32Pixarr[i]*255 << std::setw (8) << uint16_t(u8Pixarr2[i]) << (i%8 == 7 ? "\n" : "  |  ");
	//}
	ConvertImgU8ToF32_ (u8Pixarr2.Data(), f32Pixarr2.Data(), num_pixel);

	bool Success1 = false, Success2 = false;
	Success1 = ConvertImgVerify (u8Pixarr.Data (), u8Pixarr2.Data (), num_pixel);
	Success2 = ConvertImgVerify (f32Pixarr.Data(), f32Pixarr2.Data(), num_pixel);

	if (!Success1 || !Success2)
	{
		__debugbreak ();
	}
}