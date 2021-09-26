#include <thread>
#include <chrono>

#include <string>
#include <bitset>
#include <array>

#include "UnifiedCantainer.h"
#define _USE_MATH_DEFINES
#include <math.h>

#define CANTAINER_WIDTH 32
#define cnt_wid CANTAINER_WIDTH
extern "C" void AVXBlendF32_ (const Unified<cnt_wid>*src1, const Unified<cnt_wid>*src2, const Unified<cnt_wid>*dest, const Unified<cnt_wid>*idx);
extern "C" void AVX2PermuteF32_ (const Unified<cnt_wid>*src1, const Unified<cnt_wid> *dest1, const Unified<cnt_wid> *idx1, const Unified<cnt_wid> *src2, const Unified<cnt_wid> *dest2, const Unified<cnt_wid> *idx2);


template <typename T, typename I, typename M, size_t N>
void Print (const std::string &msg, const std::array<T, N> &y, const std::array<I, N> &indices, const std::array<M, N> &merge)
{
	if (y.size () != indices.size () || y.size () != merge.size ())
		throw std::runtime_error ("Non-conforming arrays - Print");
	std::cout << '\n' << msg << '\n';
	for (size_t i = 0; i < y.size (); i++) {
		std::string merge_s = (merge[i] == 1) ? "Yes" : "No";
		std::cout << "i: " << std::setw (2) << i << ' ';
		std::cout << "y: " << std::setw (10) << y[i] << ' ';
		std::cout << "index: " << std::setw (4) << int32_t(indices[i]) << ' ';
		std::cout << "merge: " << std::setw (4) << merge_s << '\n';
	}
}
void Avx2Gather8xF32_I32 ();
void AVX2Gather8xF32_I64 ();
void AVX2Gather8xF64_I32 ();
void AVX2Gather8xF64_I64 ();
extern "C" void AVX2Gather8xF32_I32_ (const float *, float *, int32_t* indices, const int32_t* masks);
extern "C" void AVX2Gather8xF32_I64_ (const float *, float *, int64_t* indices, const int32_t* masks);
extern "C" void AVX2Gather8xF64_I32_ (const double*, double*, int32_t* indices, const int64_t* masks);
extern "C" void AVX2Gather8xF64_I64_ (const double*, double*, int64_t* indices, const int64_t* masks);
int main ()
{
	using namespace std;
	{
		const uint32_t sel0 = 0x00000000;
		const uint32_t sel1 = 0x80000000;
		alignas(cnt_wid) Unified<cnt_wid> src1, src2, dest1, dest2, idx1, idx2;

		src1.f32[0] = 10.0f, src2.f32[0] = 100.0f, idx1.i32[0] = sel1;
		src1.f32[1] = 20.0f, src2.f32[1] = 200.0f, idx1.i32[1] = sel0;
		src1.f32[2] = 30.0f, src2.f32[2] = 300.0f, idx1.i32[2] = sel0;
		src1.f32[3] = 40.0f, src2.f32[3] = 400.0f, idx1.i32[3] = sel1;
		src1.f32[4] = 50.0f, src2.f32[4] = 500.0f, idx1.i32[4] = sel1;
		src1.f32[5] = 60.0f, src2.f32[5] = 600.0f, idx1.i32[5] = sel0;
		src1.f32[6] = 70.0f, src2.f32[6] = 700.0f, idx1.i32[6] = sel1;
		src1.f32[7] = 80.0f, src2.f32[7] = 800.0f, idx1.i32[7] = sel0;

		AVXBlendF32_ (&src1, &src2, &dest1, &idx1);
		cout << "\nResults of AVXBlendF32():\n";
		src1.Print<float> (NULL,NULL,2) << " :SRC1\n";
		src2.Print<float> (NULL,NULL,2) << " :SRC2\n";
		cout << "----------------------------------------------------------------------------------------------------------------------\n";
		idx1.PrintHex<uint32_t> () << " :IDX1\n";
		dest1.Print<float> () << " :DEST1\n";

		src1.f32[0] = 100.0f, src2.f32[0] = 100.0f, idx1.i32[0] = 3, idx2.i32[0] = 3;
		src1.f32[1] = 200.0f, src2.f32[1] = 200.0f, idx1.i32[1] = 7, idx2.i32[1] = 1;
		src1.f32[2] = 300.0f, src2.f32[2] = 300.0f, idx1.i32[2] = 0, idx2.i32[2] = 1;
		src1.f32[3] = 400.0f, src2.f32[3] = 400.0f, idx1.i32[3] = 4, idx2.i32[3] = 2;
		src1.f32[4] = 500.0f, src2.f32[4] = 500.0f, idx1.i32[4] = 6, idx2.i32[4] = 3;
		src1.f32[5] = 600.0f, src2.f32[5] = 600.0f, idx1.i32[5] = 6, idx2.i32[5] = 2;
		src1.f32[6] = 700.0f, src2.f32[6] = 700.0f, idx1.i32[6] = 1, idx2.i32[6] = 0;
		src1.f32[7] = 800.0f, src2.f32[7] = 800.0f, idx1.i32[7] = 2, idx2.i32[7] = 0;
		AVX2PermuteF32_ (&src1, &dest1, &idx1, &src2, &dest2, &idx2);
		cout << "\nResults of AVX2PermuteF32():\n";

		src1.Print<float> () << " :SRC1\n";
		src2.Print<float> () << " :SRC2\n";
		cout << "----------------------------------------------------------------------------------------------------------------------\n";
		idx1.PrintHex<uint32_t> () << " :IDX1\n";
		dest1.Print<float> () << " :DEST1\n";
		idx2.PrintHex<uint32_t> () << " :IDX2\n";
		dest2.Print<float> () << " :DEST2\n";
	}
	cout << '\n' << '\n';
	{
		Avx2Gather8xF32_I32 ();
		AVX2Gather8xF32_I64 ();
		AVX2Gather8xF64_I32 ();
		AVX2Gather8xF64_I64 ();
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};
void Avx2Gather8xF32_I32 ()
{
	std::array<float, 20> x;
	for (size_t i = 0; i < x.size (); i++)
		x[i] = (float)(i * 10);
	std::array<float, 8> y{ -1, -1, -1, -1, -1, -1, -1, -1 };
	std::array<int32_t, 8> indices{ 2, 1, 6, 5, 4, 13, 11, 9 };
	std::array<int32_t, 8> merge{ 1, 1, 0, 1, 1, 0, 1, 1 };
	std::cout << std::fixed << std::setprecision (1);
	std::cout << "\nResults for Avx2Gather8xF32_I32\n";
	Print ("Values before", y, indices, merge);
	AVX2Gather8xF32_I32_ (x.data (), y.data (), indices.data (), merge.data ());
	Print ("Values after", y, indices, merge);
}
void AVX2Gather8xF32_I64 ()
{
	std::array<float, 20> x;
	for (size_t i = 0; i < x.size (); i++)
		x[i] = (float)(i * 10);
	std::array<float, 8> y{ -1, -1, -1, -1, -1, -1, -1, -1 };
	std::array<int64_t, 8> indices{ 19, 1, 0, 5, 4, 3, 11, 11 };
	std::array<int32_t, 8> merge{ 1, 1, 1, 1, 0, 0, 1, 1 };
	std::cout << std::fixed << std::setprecision (1);
	std::cout << "\nResults for Avx2Gather8xF32_I64\n";
	Print ("Values before", y, indices, merge);
	AVX2Gather8xF32_I64_ (x.data (), y.data (), indices.data (), merge.data ());
	Print ("Values after", y, indices, merge);
}
void AVX2Gather8xF64_I32 ()
{
	std::array<double, 20> x;
	for (size_t i = 0; i < x.size (); i++)
		x[i] = (double)(i * 10);
	std::array<double, 8> y{ -1, -1, -1, -1, -1, -1, -1, -1 };
	std::array<int32_t, 8> indices{ 12, 11, 6, 15, 4, 13, 18, 3 };
	std::array<int64_t, 8> merge{ 1, 1, 0, 1, 1, 0, 1, 0 };
	std::cout << std::fixed << std::setprecision (1);
	std::cout << "\nResults for Avx2Gather8xF64_I32\n";
	Print ("Values before", y, indices, merge);
	AVX2Gather8xF64_I32_ (x.data (), y.data (), indices.data (), merge.data ());
	Print ("Values after", y, indices, merge);
}
void AVX2Gather8xF64_I64 ()
{
	std::array<double, 20> x;
	for (size_t i = 0; i < x.size (); i++)
		x[i] = (double)(i * 10);
	std::array<double, 8> y{ -1, -1, -1, -1, -1, -1, -1, -1 };
	std::array<int64_t, 8> indices{ 11, 17, 1, 6, 14, 13, 8, 8 };
	std::array<int64_t, 8> merge{ 1, 0, 1, 1, 1, 0, 1, 1 };
	std::cout << std::fixed << std::setprecision (1);
	std::cout << "\nResults for Avx2Gather8xF64_I64\n";
	Print ("Values before", y, indices, merge);
	AVX2Gather8xF64_I64_ (x.data (), y.data (), indices.data (), merge.data ());
	Print ("Values after", y, indices, merge);
}