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

void InitRGB (uint8_t *rgb[3], size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 5, 250 };
	default_random_engine rng{ seed };
	
	for (size_t i = 0; i < in_size; i++) {
		rgb[0][i] = uint8_t (ui_dist (rng));
		rgb[1][i] = uint8_t (ui_dist (rng));
		rgb[2][i] = uint8_t (ui_dist (rng));
	}
	// Set known min & max values for validation process
	rgb[0][in_size / 4] =   4; rgb[1][in_size / 2]     =   1; rgb[2][3 * in_size / 4] = 3;
	rgb[0][in_size / 3] = 254; rgb[1][2 * in_size / 5] = 251; rgb[2][in_size - 1] = 252;
}

struct ClipData
{
	uint8_t *Src;
	uint8_t *Dest;
	uint64_t NumPixels;
	uint64_t NumClippedPixels;
	uint8_t  ThreshLow;
	uint8_t  ThreshHigh;
};
extern "C" bool AVX2ClipPixels_ (ClipData *cd);

extern "C" bool AVX2CalcRGBMinMax_ (uint8_t *rgb[3], size_t num_pixels, uint8_t min_vals[3], uint8_t max_vals[3]);

struct RGBA32
{
	union
	{
		uint8_t clr[4];
		struct { uint8_t r, g, b, a; };
	};
	uint8_t operator[](size_t posn)
	{
		return clr[posn];
	}
};
std::ostream &operator<<(std::ostream &out, RGBA32 in)
{
	out << std::setw (4) << uint16_t (in.r) << ' ' << std::setw (4) << uint16_t (in.g) << ' ' << std::setw (4) << uint16_t (in.b) << ' ' << std::setw (4) << uint16_t (in.a);
	return out;
}
extern "C" const uint32_t c_NumPixelsMin = 32;
extern "C" const uint32_t c_NumPixelsMax = 256 * 1024 * 1024;
extern "C" bool AVX2ConvertRGBToGS_ (const RGBA32* pb_rba, uint32_t num_pixels, uint8_t *pb_gs, const float coef[4]);
int main ()
{
	using namespace std;
	{
		constexpr size_t n = 4 * 32; // 1024
		AlignedMem::AlignedArray<uint8_t> dataSrc (n, 32);
		AlignedMem::AlignedArray<uint8_t> dataDest (n, 32);
		ClipData clp_data;
		clp_data.Src = dataSrc.Data ();
		clp_data.Dest = dataDest.Data ();
		clp_data.NumPixels = n;
		clp_data.ThreshLow = 23;
		clp_data.ThreshHigh = 109;
		Init (dataSrc.Data (), n, 3);
		{
			uint8_t *data = clp_data.Src;
			constexpr size_t width = 40;
			for (size_t i = 0; i < n; i += width) {
				for (size_t j = 0; j < width && i+j < n; j++)
					cout << setw (4) << uint16_t (data[i + j]);
				cout << '\n';
			};
		}
		AVX2ClipPixels_ (&clp_data);
		{
			uint8_t *dataSrc = clp_data.Dest;
			uint8_t *dataCmpWith = clp_data.Src;
			constexpr size_t width = 40;
			for (size_t i = 0; i < n; i += width) {
				for (size_t j = 0; j < width && i+j < n; j++)
					if (dataSrc[i + j] != dataCmpWith[i + j])
						cout << setw (4) << dataSrc[i + j];
					else
						cout << setw (4) << uint16_t (dataSrc[i + j]);
				cout << '\n';
			};

			cout << "NumOfPixels processed: " << clp_data.NumPixels << "  NumPixelsClipped: " << clp_data.NumClippedPixels << '\n';
			cout << "ThreshLow: " << uint16_t(clp_data.ThreshLow) << '\''<< clp_data.ThreshLow <<'\''<< "  ThreshHigh: " << uint16_t (clp_data.ThreshHigh) << '\''<< clp_data.ThreshHigh <<'\''<< '\n';
		}
	}
	std::cout << '\n' << '\n' << '\n';
	{
		constexpr size_t n = 1024;
		uint8_t min_vals[3], max_vals[3];
		AlignedMem::AlignedArray<uint8_t> r (n, 32);
		AlignedMem::AlignedArray<uint8_t> g (n, 32);
		AlignedMem::AlignedArray<uint8_t> b (n, 32);

		uint8_t *rgb[3];
		rgb[0] = r.Data ();
		rgb[1] = g.Data ();
		rgb[2] = b.Data ();

		InitRGB (rgb, n, 73);
		AVX2CalcRGBMinMax_ (rgb, n, min_vals, max_vals);
		cout << "Results for AVX2CalcRGBMinMax:\n";
		cout << "--------------R----G----B---\n";
		cout << "min_vals: " 
			 << setw (4) << uint16_t (min_vals[0]) << ' '
			 << setw (4) << uint16_t (min_vals[1]) << ' '
			 << setw (4) << uint16_t (min_vals[2]) << '\n';
		cout << "max_vals: " 
			 << setw (4) << uint16_t (max_vals[0]) << ' '
			 << setw (4) << uint16_t (max_vals[1]) << ' '
			 << setw (4) << uint16_t (max_vals[2]) << '\n';
	}
	std::cout << '\n' << '\n' << '\n';
	{
		constexpr size_t n = 1024;
		float colorContribution[] = { 0.2126f, 0.7152f, 0.0722f, 0.0f };
		AlignedMem::AlignedArray<RGBA32> rgba (n, 32);
		AlignedMem::AlignedArray<uint8_t> gs (n, 32);
		{
			RGBA32 *data = rgba.Data ();
			//for (uint32_t i = 0; i < n; i++) {
			//	data[i].r = 100;
			//	data[i].g = 100;
			//	data[i].b = 100;
			//	data[i].a = 100;
			//}
			Init ((uint8_t *)(data), n*4);
		}
		bool success = AVX2ConvertRGBToGS_ (rgba.Data (), n, gs.Data (), colorContribution);
		cout << "Results of AVX2ConvertRGBToGS [" << success << "]:\n";
		
		{
			RGBA32 *data = rgba.Data ();
			uint8_t *_gs = gs.Data ();
			//float gry_s = 0;
			//for (uint8_t i = 0; i < 4; i++) {
			//	float tmp = rgba[0][i];
			//	tmp *= colorContribution[i];
			//	gry_s += tmp;
			//}
			//cout << "for rgba[0] gs = " << gry_s + 0.5f << '\n';
			for (uint32_t i = 0; i < n; i++)
				cout << data[i] << " | " << uint16_t(_gs[i]) << '\n';
		}
	}
	return 0;
};