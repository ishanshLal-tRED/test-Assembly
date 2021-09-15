#include <iostream>
#include <thread>
#include <chrono>

#define _USE_MATH_DEFINES
#include <math.h>

#include <string>
#include <sstream>
#include <iomanip>
#include <bitset>
struct XmmVal
{
public:
	union
	{
		int8_t     i8[16];
		int16_t    i16[8];
		int32_t    i32[4];
		int64_t    i64[2];
		uint8_t    u8[16];
		uint16_t   u16[8];
		uint32_t   u32[4];
		uint64_t   u64[2];
		float      f32[4];
		double     f64[2];
	};
	void PrintF32 (char addatend = 0)
	{
		std::cout << std::setprecision (6);
		std::cout << std::setw (8) << f32[0] << ' '  << std::setw (8) << f32[1] << ' '  
			<< std::setw (8) << f32[2] << ' '  << std::setw (8) << f32[3];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintF64 (char addatend = 0)
	{
		std::cout << std::setprecision (8);
		std::cout << std::setw(8) << f64[0] << ' '  << std::setw (8) << f64[1];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintI32 (char addatend = 0)
	{
		std::cout << std::setw (8) << i32[0] << ' '  << std::setw (8) << i32[1] << ' '  
			<< std::setw (8) << i32[2] << ' '  << std::setw (8) << i32[3];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintI64 (char addatend = 0)
	{
		std::cout << std::setw(8) << i64[0] << ' '  << std::setw (8) << i64[1];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void Printbin32 (char addatend = 0)
	{
		std::bitset<32> b[4];
		b[0] = u32[0], b[1] = u32[1], b[2] = u32[2], b[3] = u32[3];

		std::cout << b[0] << ' ' << b[1] << ' ' << b[2] << ' ' << b[3];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void Printbin64 (char addatend = 0)
	{
		std::bitset<64> b[2];
		b[0] = u64[0], b[1] = u64[1];
		std::cout << b[0] << ' ' << b[1];
		if (addatend) {
			std::cout << addatend;
		}
	}
};

extern "C" void AVXPackedMathF32_ (const XmmVal&, const XmmVal&, XmmVal*);
extern "C" void AVXPackedMathF64_ (const XmmVal&, const XmmVal&, XmmVal*);
void AVXPackedMathF32 ();
void AVXPackedMathF64 ();

extern "C" void AvxPackedCampareF32_ (const XmmVal &, const XmmVal &, XmmVal *);
extern "C" void AvxPackedCampareF64_ (const XmmVal &, const XmmVal &, XmmVal *);
void AvxPackedCampareF32 ();
void AvxPackedCampareF64 ();


enum CvtOp
	: uint8_t
{
	I32_F32 = 0,
	I32_F64_,
	//I64_I32, // No AVX equivalent
	//I64_F32, // No AVX equivalent
	//I64_F64, // No AVX equivalent
	F32_I32,
	//F32_I64_, // No AVX equivalent
	F32_F64_,
	F64_I32,
	//F64_I64, // No AVX equivalent
	F64_F32

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
extern "C" RoundingMode GetMxcsrRoundingMode_ (void);
extern "C" void SetMxcsrRoundingMode_ (RoundingMode);
extern "C" void ConvertPackedScaler_ (XmmVal *a, CvtOp typ, XmmVal *b, uint32_t arr_length = 1);
void ConvertPackedScaler ();

int main ()
{
	using namespace std;
	{
		AVXPackedMathF32 ();
		AVXPackedMathF64 ();
	}
	std::cout << "\n\n\n";
	{
		AvxPackedCampareF32 ();
		AvxPackedCampareF64 ();
	}
	std::cout << "\n\n\n";
	{
		ConvertPackedScaler ();
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};
void AVXPackedMathF32 ()
{
	using namespace std;
	alignas(16) XmmVal a;
	alignas(16) XmmVal b;
	alignas(16) XmmVal c[8];

	a.f32[0] = 36, b.f32[0] = -float (1.0/9.0);
	a.f32[1] = float (1.0/32.0), b.f32[1] = 64.0f;
	a.f32[2] = 2.0f, b.f32[2] = -0.0625f;
	a.f32[3] = 42.0f, b.f32[3] = 8.666667f;

	AVXPackedMathF32_ (a, b, c);

	cout << "Results from " << __FUNCTION__ << '\n';
	cout << "a:       "; a.PrintF32 ('\n');
	cout << "b:       "; b.PrintF32 ('\n'); std::cout << std::endl;
	cout << "addps:   "; c[0].PrintF32 ('\n');
	cout << "subps:   "; c[1].PrintF32 ('\n');
	cout << "mulps:   "; c[2].PrintF32 ('\n');
	cout << "divps:   "; c[3].PrintF32 ('\n');
	cout << "absps:   "; c[4].PrintF32 ('\n');
	cout << "sqrtps:  "; c[5].PrintF32 ('\n');
	cout << "minps:   "; c[6].PrintF32 ('\n');
	cout << "maxps:   "; c[7].PrintF32 ('\n');
};
void AVXPackedMathF64 ()
{
	using namespace std;
	alignas(16) XmmVal a;
	alignas(16) XmmVal b;
	alignas(16) XmmVal c[8];

	a.f64[0] = 2.0, b.f64[0] = M_E;
	a.f64[1] = M_PI, b.f64[1] = -M_1_PI;

	AVXPackedMathF64_ (a, b, c);

	cout << "Results from " << __FUNCTION__ << '\n';
	cout << "a:       "; a.PrintF64 ('\n');
	cout << "b:       "; b.PrintF64 ('\n'); std::cout << std::endl;
	cout << "addpd:   "; c[0].PrintF64 ('\n');
	cout << "subpd:   "; c[1].PrintF64 ('\n');
	cout << "mulpd:   "; c[2].PrintF64 ('\n');
	cout << "divpd:   "; c[3].PrintF64 ('\n');
	cout << "abspd:   "; c[4].PrintF64 ('\n');
	cout << "sqrtpd:  "; c[5].PrintF64 ('\n');
	cout << "minpd:   "; c[6].PrintF64 ('\n');
	cout << "maxpd:   "; c[7].PrintF64 ('\n');
};
void AvxPackedCampareF32 ()
{
	using namespace std;
	constexpr size_t Campares = 8;
	constexpr const char *campareStr[Campares] = { "EQ","NE","LT","LE","GT","GE","ORDERED","UNORDERED" };
	
	alignas(16) XmmVal a;
	alignas(16) XmmVal b;
	alignas(16) XmmVal c[Campares];
	
	a.f32[0] =  2.0 , b.f32[0] =  1.0;
	a.f32[1] =  7.0 , b.f32[1] = 12.0;
	a.f32[2] = -6.0 , b.f32[2] = -6.0;
	a.f32[3] =  3.0 , b.f32[3] =  8.0;

	AvxPackedCampareF32_ (a, b, c);

	cout << "Results from " << __FUNCTION__ << '\n';
	cout << "a:       "; a.PrintF32 ('\n');
	cout << "b:       "; b.PrintF32 ('\n'); std::cout << std::endl;
	for (uint32_t i = 0; i < Campares; i++) {
		cout << campareStr[i] << ' '; c[i].Printbin32 ('\n');
	}
}
void AvxPackedCampareF64 ()
{
	using namespace std;
	constexpr size_t Campares = 8;
	constexpr const char *campareStr[Campares] = { "EQ","NE","LT","LE","GT","GE","ORDERED","UNORDERED" };

	alignas(16) XmmVal a;
	alignas(16) XmmVal b;
	alignas(16) XmmVal c[Campares];

	a.f64[0] = 2.0 , b.f64[0] = M_E;
	a.f64[1] = M_PI, b.f64[1] = -M_1_PI;
	
	AvxPackedCampareF64_ (a, b, c);

	cout << "Results from " << __FUNCTION__ << '\n';
	cout << "a:   "; a.PrintF64 ('\n');
	cout << "b:   "; b.PrintF64 ('\n'); std::cout << std::endl;
	for (uint32_t i = 0; i < Campares; i++) {
		cout << campareStr[i] << ' '; c[i].Printbin64 ('\n');
	}
}
void ConvertPackedScaler ()
{
	constexpr size_t src_length = 5;
	XmmVal src[src_length];
	src[0].f32[0] = float (M_PI), src[0].f32[1] = float (M_PI), src[0].f32[2] = float (M_PI), src[0].f32[3] = float (M_PI);
	src[1].f32[0] = float (-M_E), src[1].f32[1] = float (-M_E), src[1].f32[2] = float (-M_E), src[1].f32[3] = float (-M_E); // I'm curious what no. it'll generate
	src[2].f64[0] = M_SQRT2          , src[2].f64[1] = M_SQRT2          ;
	src[3].f64[0] = M_SQRT1_2        , src[3].f64[1] = M_SQRT1_2        ; // I'm curious what no. it'll generate
	src[4].f64[0] = 1.0 + DBL_EPSILON, src[4].f64[1] = 1.0 + DBL_EPSILON;

	for (size_t i = 0; i < RoundingMode::_TOTAL; i++) {
		XmmVal dest[src_length];
		RoundingMode rm_Save = GetMxcsrRoundingMode_ ();
		RoundingMode rm_Test = RoundingMode (uint8_t (i));

		SetMxcsrRoundingMode_ (rm_Test);
		ConvertPackedScaler_ (&src[0], CvtOp::F32_I32, &dest[0]);
		ConvertPackedScaler_ (&src[1], CvtOp::I32_F32, &dest[1]);
		ConvertPackedScaler_ (&src[2], CvtOp::F64_I32, &dest[2]);
		ConvertPackedScaler_ (&src[3], CvtOp::I32_F64_, &dest[3]);
		ConvertPackedScaler_ (&src[4], CvtOp::F64_F32, &dest[4]);
		SetMxcsrRoundingMode_ (rm_Save);

		std::cout << std::fixed;
		std::cout << "Rounding Mode = " << str_RoundingMode[rm_Test] << '\n';

		std::cout << " F32_I32: " << std::setprecision (8);
		src[0].PrintF32 ();
		std::cout << " --> "; 
		dest[0].PrintI32 ('\n');
		std::cout << " I32_F32: " << std::setprecision (8);
		src[1].PrintI32 ();
		std::cout << " --> ";
		dest[1].PrintF32 ('\n');
		std::cout << " F64_I32: " << std::setprecision (8);
		src[2].PrintF64 ();
		std::cout << " --> ";
		dest[2].PrintI32 ('\n');
		std::cout << " I32_F64: " << std::setprecision (8);
		src[3].PrintI32 ();
		std::cout << " --> ";
		dest[3].PrintF64 ('\n');
		std::cout << " F64_F32: ";
		src[4].PrintF64 ();
		std::cout << " --> ";
		dest[4].PrintF32 ('\n');
	}
}