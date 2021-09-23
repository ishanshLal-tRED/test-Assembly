#include <iostream>
#include <thread>
#include <chrono>

#include <random>

#include <string>
#include <sstream>
#include <iomanip>
#include <bitset>

#include "AlignedMem.h"

extern "C" bool AVXBuildImageHistogram_ (const uint8_t* pixels, const size_t, uint32_t* histogram, uint32_t& max_ht);

// Image threshold data structure. This structure must agree with the
// structure inside .asm
struct ITD
{
	uint8_t *m_PbSrc;				// Source image pixel buffer
	uint8_t *m_PbMask;				// Mask pixel buffer
	uint32_t m_NumPixels;			// Number of source pixel
	uint32_t m_NumMaskedPixels;		// Number of masked pixels
	uint32_t m_SumMaskedPixels;		// Sum of masked pixels
	uint8_t m_Threshold;			// Image threshold
	uint8_t m_Pad[3];				// Padding (Available for future use)
	double m_MeanMaskedPixels;      // mean of masked pixels
};
extern "C" bool AVXThresholdImage_ (ITD* itd);
extern "C" bool AVXCalcImageMean_ (ITD* itd);
const uint8_t g_TestThreshold = 96;

extern "C" bool IsValid (uint32_t num_pixels, const uint8_t *pb_src, const uint8_t *pb_mask)
{
	const size_t alignment = 16;
	//Make sure num_pixels is valid
	if ((num_pixels == 0) || (num_pixels > (4096*4096)))
		return false;
	if (num_pixels % 64 != 0)
		return false;
	if (!AlignedMem::IsAligned (pb_src,alignment))
		return false;
	if (!AlignedMem::IsAligned (pb_mask,alignment))
		return false;
	return true;
}
void FillImage (AlignedMem::AlignedArray<uint8_t>& arr, const uint32_t width, const uint32_t height)
{
	uint8_t *arr_raw = arr.Data ();

	int32_t radius = (width/2);
	int32_t radiusQuarter = (radius/6);
	int32_t radiusSqr = radius*radius;

	for (uint32_t y = 0; y < height; y++) {
		int32_t ySqr = y;
		ySqr -= (height/2);
		ySqr *=	ySqr;

		for (uint32_t x = 0; x < width; x++) {
			int32_t xSqr = x;
			xSqr -= radius; // width/2;
			xSqr *= xSqr;
			int32_t val = std::max<int32_t>(radiusSqr - (xSqr + ySqr), 0);
			val /= radiusQuarter;
			arr_raw[y*width + x] = uint8_t(std::clamp (val, 0, 255));
		}
	}
}
void AVXThreshold (void)
{
	constexpr uint32_t wid = 64, ht = 64;
	AlignedMem::AlignedArray<uint8_t> pixarr (wid*ht, 16);
	AlignedMem::AlignedArray<uint8_t> mskarr (wid*ht, 16);
	FillImage (pixarr, wid, ht);
	{
		uint8_t *arr_raw = pixarr.Data ();
		for (uint32_t i = 0; i < ht; i++) {
			for (uint32_t j = 0; j < wid; j++) {
				std::cout << std::setw (3) << uint16_t (arr_raw[i*wid + j]);
			}
			std::cout << '\n';
		}
	}
	ITD itd;
	itd.m_PbSrc  = pixarr.Data ();
	itd.m_PbMask = mskarr.Data ();
	itd.m_NumPixels = wid*ht;
	itd.m_Threshold = g_TestThreshold;
	bool success1 = AVXThresholdImage_ (&itd);
	bool success2 = AVXCalcImageMean_  (&itd);
	//size_t sumOfMask = 0, numOfMask = 0;
	{
		uint8_t *pix_raw = pixarr.Data ();
		uint8_t *arr_raw = mskarr.Data ();
		for (uint32_t i = 0; i < ht; i++) {
			std::cout << '\n';
			for (uint32_t j = 0; j < wid; j++) {
				uint16_t val = arr_raw[i*wid + j];
				std::cout << std::setw (3) << val;
				//if (val > 0)
				//{
				//	sumOfMask += pix_raw[i*wid + j];
				//	numOfMask++;
				//}
			}
		}
		std::cout << '\n';
	}
	std::cout << std::fixed << std::setprecision (4)
		<< "\nResults For " << __FUNCTION__ << '\n'
		<< "SumMaskedPixels:  " << itd.m_SumMaskedPixels  << '\n'//' ' << sumOfMask << '\n'
		<< "NumPixelsMasked:  " << itd.m_NumMaskedPixels  << '\n'//' ' << numOfMask << '\n'
		<< "MeanMaskedPixels: " << itd.m_MeanMaskedPixels << '\n'
	;
}

template<typename Typ> requires std::integral<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 0, 255 };
	default_random_engine rng{ seed };

	for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng));
}
int main ()
{
	using namespace std;
	{// Display Histogram
		const size_t max_width = 100;
		alignas(16) uint32_t histogram[256];
		alignas(16) uint32_t histogram2[256];
		uint32_t max_ht = 1;
		{
			auto *tmp = &max_ht;
			tmp = tmp;
		}
		constexpr size_t num_of_pixels = 64*64;
		AlignedMem::AlignedArray<uint8_t> pixarr(num_of_pixels,16);
		FillImage (pixarr, 64, 64);

		//{
		//	auto *pix_arr = pixarr.Data ();
		//	memset (histogram2, 0, 256 * sizeof (uint32_t));
		//	for (uint32_t i = 0; i < num_of_pixels; i++)
		//		histogram2[pix_arr[i]]++;
		//}
		//if (bool _this =
		 AVXBuildImageHistogram_ (pixarr.Data (), num_of_pixels, histogram, max_ht);
		//_this)
		{
			cout << "_________________________\n";
			for (size_t y = 256; y > 0; y--) {
				cout << setw (4) << y-1 << ' ' << '|';
				const size_t ht = histogram[y-1];
				const size_t width = (max_width*ht)/max(max_ht,uint32_t(1));
				for (size_t x = 0; x < width; x++) {
					cout << '=';
				}
				cout << ' ' << ht;
				//if (ht!=histogram2[y-1])
				//{
				//	cout << ' ' << histogram2[y-1];
				//}
				cout << '\n';
			}
			cout << "`````````````````````````\n";
		} 
		// else {
		//	std::runtime_error ("AVXBuildImageHistogram failed");
		//	__debugbreak ();
		//}
	}
	AVXThreshold ();
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};