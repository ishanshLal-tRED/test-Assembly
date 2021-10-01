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

uint32_t g_RngSeedVal = 100;
extern "C" int32_t c_NumPtsMin = 32;
extern "C" int32_t c_NumPtsMax = 16*1024*1024;
extern "C" int32_t c_KernelSizeMin = 3;
extern "C" int32_t c_KernelSizeMax = 15;

template<typename Typ> requires std::integral<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ 0, 255 };
	default_random_engine rng{ seed };
	
	for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng));
}
template<typename Typ>
void Save (const char *idntfr, Typ *data, uint32_t size, std::ofstream &stream)
{
	stream << idntfr;
	for (int i = 0; i < size; i++)
		stream   << ' ' << ',' << std::setw (10) << data[i];
	stream << '\n';
}


void CreateSignal (float *x, int32_t n, int32_t kernl_size, uint32_t seed);
void PadSignal (float *x2, int32_t n2, const float *x1, int32_t n1, int32_t ks2);
extern "C" bool Convolve1_ (float *y, const float *x, int32_t num_pts, const float *kernel, int kernel_size);
extern "C" bool Convolve1Ks5_ (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size);

extern "C" bool Convolve2_ (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size);
extern "C" bool Convolve2Ks5_ (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size);
extern "C" bool Convolve2Ks5Test_ (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size) { return true; };

int main ()
{
	using namespace std;
	
	constexpr uint32_t n1 = 512;
	constexpr float kernel[]{ 0.0625,0.25,0.375,0.25,0.0625 };
	constexpr uint32_t ks = sizeof (kernel) / sizeof (float);
	constexpr uint32_t ks2 = ks/2;
	constexpr uint32_t n2 = n1 + ks2*2;

	// Create signal array
	unique_ptr<float[]> x1_up{ new float[n1] };
	unique_ptr<float[]> x2_up{ new float[n2] };

	float *x1 = x1_up.get ();
	float *x2 = x2_up.get ();

	CreateSignal (x1, n1, ks, g_RngSeedVal);
	PadSignal (x2, n2, x1, n1, ks2);

	constexpr int32_t num_pts = n1;
	{ // scaler
		// perform convolutions
		unique_ptr<float[]> y1_up{ new float[num_pts] };
		unique_ptr<float[]> y2_up{ new float[num_pts] };
		float *y1 = y1_up.get ();
		float *y2 = y2_up.get ();

		bool rc1 = Convolve1_ (y1, x2, num_pts, kernel, ks);
		bool rc2 = Convolve1Ks5_ (y2, x2, num_pts, kernel, ks);

		cout << "Results for Convolve1\n";
		cout << " rc1 = " << boolalpha << rc1 << '\n';
		cout << " rc2 = " << boolalpha << rc2 << '\n';
		if (!rc1 || !rc2)
			throw runtime_error("rc1 or rc2 is false");
		// Save data
		const char *fn = "Ch11_01_Convolve1Results.csv";
		ofstream ofs (fn);
		if (ofs.bad ())
			cout << "File create error - " << fn << '\n';
		else {
			ofs << fixed << setprecision (7);
			ofs << " i";
			for (int i = 0; i < num_pts; i++)
				ofs  << ',' << setw (10) << i << ' ';
			ofs << '\n';
			Save ("x1", x1, num_pts, ofs);
			Save ("y1", y1, num_pts, ofs);
			Save ("y2", y2, num_pts, ofs);
			ofs.close ();
			cout << "\nConvolution results saved to file " << fn << '\n';
		}
	}
	std::cout << '\n' << '\n' << '\n';
	{ // Packed
		// perform convolutions
		AlignedMem::AlignedArray<float> y1_up(num_pts,32);
		AlignedMem::AlignedArray<float> y2_up(num_pts,32);
		AlignedMem::AlignedArray<float> y3_up(num_pts,32);
		float *y1 = y1_up.Data ();
		float *y2 = y2_up.Data ();
		float *y3 = y3_up.Data ();

		bool rc1 = Convolve2_ (y1, x2, num_pts, kernel, ks);
		bool rc2 = Convolve2Ks5_ (y2, x2, num_pts, kernel, ks);
		bool rc3 = Convolve2Ks5Test_ (y3, x2, num_pts, kernel, ks);

		cout << "Results for Convolve1\n";
		cout << " rc1 = " << boolalpha << rc1 << '\n';
		cout << " rc2 = " << boolalpha << rc2 << '\n';
		cout << " rc3 = " << boolalpha << rc3 << '\n';
		if (!rc1 || !rc2 || !rc3)
			throw runtime_error ("rc1, rc2 or rc3 is false");
		// Save data
		const char *fn = "Ch11_02_Convolve2Results.csv";
		ofstream ofs (fn);
		if (ofs.bad ())
			cout << "File create error - " << fn << '\n';
		else {
			ofs << fixed << setprecision (7);
			ofs << " i";
			for (int i = 0; i < num_pts; i++)
				ofs  << ',' << setw (10) << i << ' ';
			ofs << '\n';
			Save ("x1", x1, num_pts, ofs);
			Save ("y1", y1, num_pts, ofs);
			Save ("y2", y2, num_pts, ofs);
			//Save ("y3", y3, num_pts, ofs);
			ofs.close ();
			cout << "\nConvolution results saved to file " << fn << '\n';
		}
	}
	return 0;
};
void CreateSignal (float *x, int32_t n, int32_t kernel_size, uint32_t seed)
{
	constexpr float degToRad = (float)(M_PI/180.0);
	constexpr float t_start = 0;
	constexpr float t_step = 0.002f;
	constexpr int m = 3;
	constexpr float amp[m]{ 1.0f, 8.0f, 1.20f };
	constexpr float freq[m]{ 5.0f,10.0f,15.0f };
	constexpr float phase[m]{ 0.0f,45.0f,90.0f };
	const int ks2 = kernel_size/2;

	std::uniform_int_distribution<> ui_dist{ 1, 255 };
	std::default_random_engine rng{ seed };
	
	float t = t_start;

	for (int32_t i = 0; i < n; i++) {
		float x_val = 0;
		for (int32_t j = 0; j < m; j++) {
			float omega = 2.0f * float (M_PI * freq[i]);
			float x_temp1 = amp[j]*sin (omega * t + phase[j]*degToRad);
			int rand_val = ui_dist (rng);
			float noise = float (rand_val - 250)/10.0f;
			float x_temp2 = x_temp1 + x_temp1*noise/100.0f;

			x_val += x_temp2;
		}
		x[i] = x_val;
	}
}
void PadSignal (float *x2, int32_t n2, const float *x1, int32_t n1, int32_t ks2)
{
	if (n2 != n1 + ks2*2)
		throw std::runtime_error ("InitPad - invalid size argument");

	for (int i = 0; i < n1; i++)
		x2[i + ks2] = x1[i];

	for (int32_t i = 0; i < ks2; i++) {
		x2[i] = x1[ks2 - i - 1];
		x2[n1 + ks2 + i] = x1[n1 - i - 1];
	}
};