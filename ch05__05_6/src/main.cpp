#include <iostream>
#include <string>
#include <iomanip>
#include <limits>

#define _USE_MATH_DEFINES
#include <math.h>

extern "C" void CompareVCMPSS_ (float a, float b, bool *results);
extern "C" void CompareVCMPSD_ (double a, double b, bool *results);

const char *c_OpStrings[] = { "UO", "OR", "LT", "LE", "EQ", "NE", "GT", "GE"};
const size_t c_NumOpStrings = sizeof (c_OpStrings) / sizeof (char *);
const std::string g_Dashes (72, '-');
template <typename T> void PrintResults (T a, T b, const bool *cmp_results)
{
	std::cout << "a = " << a << ", ";
	std::cout << "b = " << b << '\n';
	for (size_t i = 0; i < c_NumOpStrings; i++) {
		std::cout << c_OpStrings[i] << " = ";
		std::cout << std::boolalpha << std::left << std::setw (6) << cmp_results[i] << ' ';
	}
	std::cout << "\n\n";
}
void CompareVCMPSS (void);
void CompareVCMPSD (void);


enum CvtOp
	: uint8_t
{
	I32 = 0,
	I64,
	F32,
	F64
};
enum RoundingMode
	: uint8_t
{
	Nearest = 0,
	Down,
	Up,
	Truncate,
	_TOTAL
};
const std::string str_RoundingMode[RoundingMode::_TOTAL] = { "Nearest","Down","Up","Truncate" };
union Union64
{
	int32_t i32;
	int64_t i64;
	float   f;
	double  d;
};
extern "C" RoundingMode GetMxcsrRoundingMode_ (void);
extern "C" void SetMxcsrRoundingMode_ (RoundingMode);
extern "C" void ConvertScaler_ (Union64 *a, CvtOp a_typ, Union64 *b, CvtOp b_typ, uint32_t arr_length = 1);
void ConvertScaler ();
int main ()
{
	CompareVCMPSD ();
	CompareVCMPSS ();

	std::cout << "\n\n";

	ConvertScaler ();
	return 0;
}

void CompareVCMPSS (void)
{
	const size_t n = 6;
	float a[n]{ 120.0, 250.0, 300.0, -18.0, -81.0, 42.0 };
	float b[n]{ 130.0, 240.0, 300.0, 32.0, -100.0, 0.0 };
	// Set NAN test value
	b[n - 1] = std::numeric_limits<float>::quiet_NaN ();
	std::cout << "\nResults for "<<__FUNCTION__<<"\n";
	std::cout << g_Dashes << '\n';
	for (size_t i = 0; i < n; i++) {
		bool cmp_results[c_NumOpStrings];

		CompareVCMPSS_ (a[i], b[i], cmp_results);
		PrintResults (a[i], b[i], cmp_results);
	}
}
void CompareVCMPSD (void)
{
	const size_t n = 6;
	double a[n]{ 120.0, 250.0, 300.0, -18.0, -81.0, 42.0 };
	double b[n]{ 130.0, 240.0, 300.0, 32.0, -100.0, 0.0 };
	// Set NAN test value
	b[n - 1] = std::numeric_limits<double>::quiet_NaN ();
	std::cout << "\nResults for "<<__FUNCTION__<<"\n";
	std::cout << g_Dashes << '\n';
	for (size_t i = 0; i < n; i++) {
		bool cmp_results[c_NumOpStrings];

		CompareVCMPSD_ (a[i], b[i], cmp_results);
		PrintResults (a[i], b[i], cmp_results);
	}
}


void ConvertScaler ()
{
	Union64 src[5];
	constexpr size_t src_length = 5;
	src[0].f = float (M_PI);
	src[1].f = float (-M_E);
	src[2].d = M_SQRT2;
	src[3].d = M_SQRT1_2;
	src[4].d = 1.0 + DBL_EPSILON;

	for (size_t i = 0; i < RoundingMode::_TOTAL; i++) {
		Union64 dest[src_length];
		RoundingMode rm_Save = GetMxcsrRoundingMode_ ();
		RoundingMode rm_Test = RoundingMode (uint8_t (i));

		SetMxcsrRoundingMode_ (rm_Test);
		ConvertScaler_ (&src[0], CvtOp::F32, &dest[0], CvtOp::I32);
		ConvertScaler_ (&src[1], CvtOp::F32, &dest[1], CvtOp::I64);
		ConvertScaler_ (&src[2], CvtOp::F64, &dest[2], CvtOp::I32);
		ConvertScaler_ (&src[3], CvtOp::F64, &dest[3], CvtOp::I64);
		ConvertScaler_ (&src[4], CvtOp::F64, &dest[4], CvtOp::F32);
		SetMxcsrRoundingMode_ (rm_Save);

		std::cout << std::fixed;
		std::cout << "Rounding Mode = " << str_RoundingMode[rm_Test] << '\n';
		
		std::cout << " F32_I32: " << std::setprecision (8);
		std::cout << src[0].f << " --> " << dest[0].i32 << '\n';
		std::cout << " F32_I64: " << std::setprecision (8);
		std::cout << src[1].f << " --> " << dest[1].i64 << '\n';
		std::cout << " F64_I32: " << std::setprecision (8);
		std::cout << src[2].d << " --> " << dest[2].i32 << '\n';
		std::cout << " F64_I64: " << std::setprecision (8);
		std::cout << src[3].d << " --> " << dest[3].i64 << '\n';
		std::cout << " F64_F32: ";
		std::cout << std::setprecision (16) << src[4].d << " --> ";
		std::cout << std::setprecision (8) << dest[4].f << '\n';
	}
}