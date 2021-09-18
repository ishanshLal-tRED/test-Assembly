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
		constexpr uint32_t w = 8;
		std::cout << std::setprecision (6);
		std::cout 
			<< std::setw (w) << f32[0] << ' '  << std::setw (w) << f32[1] << ' '  
			<< std::setw (w) << f32[2] << ' '  << std::setw (w) << f32[3];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintF64 (char addatend = 0)
	{
		constexpr uint32_t w = 12;
		std::cout << std::setprecision (8);
		std::cout << std::setw(w) << f64[0] << ' '  << std::setw (w) << f64[1];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintI16 (char addatend = 0)
	{
		constexpr uint32_t w = 6;
		std::cout << std::setprecision (6);
		std::cout
			<< std::setw (w) << i16[0] << ' '  << std::setw (w) << i16[1] << ' ' << std::setw (w) << i16[2] << ' '  << std::setw (w) << i16[3]
			<< std::setw (w) << i16[4] << ' '  << std::setw (w) << i16[5] << ' ' << std::setw (w) << i16[6] << ' '  << std::setw (w) << i16[7]
			;
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintI32 (char addatend = 0)
	{
		constexpr uint32_t w = 8;
		std::cout 
			<< std::setw (w) << i32[0] << ' '  << std::setw (w) << i32[1] << ' '  
			<< std::setw (w) << i32[2] << ' '  << std::setw (w) << i32[3];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintI64 (char addatend = 0)
	{
		constexpr uint32_t w = 12;
		std::cout << std::setw(w) << i64[0] << ' '  << std::setw (w) << i64[1];
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintU8 (char addatend = 0)
	{
		constexpr uint32_t w = 4;
		std::cout << std::setprecision (6);
		std::cout 
			<< std::setw (w) << u8[ 0] << ' '  << std::setw (w) << u8[ 1] << ' ' << std::setw (w) << u8[ 2] << ' '  << std::setw (w) << u8[ 3] << ' '
			<< std::setw (w) << u8[ 4] << ' '  << std::setw (w) << u8[ 5] << ' ' << std::setw (w) << u8[ 6] << ' '  << std::setw (w) << u8[ 7] << "...\n..."
			<< std::setw (w) << u8[ 8] << ' '  << std::setw (w) << u8[ 9] << ' ' << std::setw (w) << u8[10] << ' '  << std::setw (w) << u8[11] << ' '
			<< std::setw (w) << u8[12] << ' '  << std::setw (w) << u8[13] << ' ' << std::setw (w) << u8[14] << ' '  << std::setw (w) << u8[15]
			;
		if (addatend) {
			std::cout << addatend;
		}
	}
	void PrintU16 (char addatend = 0)
	{
		constexpr uint32_t w = 6;
		std::cout << std::setprecision (6);
		std::cout 
			<< std::setw (w) << u16[0] << ' '  << std::setw (w) << u16[1] << ' ' << std::setw (w) << u16[2] << ' '  << std::setw (w) << u16[3]
			<< std::setw (w) << u16[4] << ' '  << std::setw (w) << u16[5] << ' ' << std::setw (w) << u16[6] << ' '  << std::setw (w) << u16[7]
		;
		if (addatend) {
			std::cout << addatend;
		}
	}
	void Printbin16 (char addatend = 0)
	{
		std::bitset<16> b[8];
		b[0] = u16[0], b[1] = u16[1], b[2] = u16[2], b[3] = u16[3];
		b[4] = u16[4], b[5] = u16[5], b[6] = u16[6], b[7] = u16[7];

		std::cout 
			<< b[0] << ' ' << b[1] << ' ' << b[2] << ' ' << b[3] << ' '
			<< b[4] << ' ' << b[5] << ' ' << b[6] << ' ' << b[7];
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

extern "C" void AVXPackedAddU16_ (const XmmVal&, const XmmVal&, XmmVal*);
extern "C" void AVXPackedAddI16_ (const XmmVal&, const XmmVal&, XmmVal*);
extern "C" void AVXPackedSubU16_ (const XmmVal&, const XmmVal&, XmmVal*);
extern "C" void AVXPackedSubI16_ (const XmmVal&, const XmmVal&, XmmVal*);

extern "C" void AVXPackedMulI16_  (const XmmVal&, const XmmVal&, XmmVal*); // Lossless
extern "C" void AVXPackedMulI32A_ (const XmmVal&, const XmmVal&, XmmVal*); // Lossless
extern "C" void AVXPackedMulI32B_ (const XmmVal&, const XmmVal&, XmmVal&); // Lossy

void AVXPackedMathU16 ();
void AVXPackedMathI16 ();
void AVXPackedMathI32 ();


enum ShiftOp
	: uint8_t
{
	U16_LL, // shift left logical - word
	U16_RL, // shift right logical - word
	U16_RA, // shift right arithmetic - word
	U32_LL, // shift left logical - double-word
	U32_RL, // shift right logical - double-word
	U32_RA  // shift right arithmetic - double-word
};
extern "C" bool AVXPackedIntShift_ (const XmmVal &, const uint32_t count, ShiftOp, XmmVal &);
void AVXPackedIntShift ();
int main ()
{
	using namespace std;
	AVXPackedMathU16 ();
	std::cout << "\n\n";
	AVXPackedMathI16 ();
	std::cout << "\n\n";
	AVXPackedMathI32 ();
	std::cout << "\n\n";
	AVXPackedIntShift();
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};
void AVXPackedMathU16 ()
{
	std::cout << "Results of " << __FUNCTION__ << ":\n";
	alignas(16) XmmVal a, b, c[2];
	a.u16[0] = 10,	  b.u16[0] = 100;
	a.u16[1] = 200,	  b.u16[1] = 200;
	a.u16[2] = 30,	  b.u16[2] = 7;
	a.u16[3] = 65000, b.u16[3] = 5000;
	a.u16[4] = 60,	  b.u16[4] = 500;
	a.u16[5] = 25000, b.u16[5] = 28000;
	a.u16[6] = 32000, b.u16[6] = 1200;
	a.u16[7] = 1200,  b.u16[7] = 950;
	
	std::cout << 'a' << ':' << ' '; a.PrintU16 ('\n');
	std::cout << 'b' << ':' << ' '; b.PrintU16 ('\n');
	std::cout << "-------------\n";
	AVXPackedAddU16_ (a, b, c);
	std::cout << "WrapAround Addition:    "; c[0].PrintU16 ('\n');
	std::cout << "Saturated  Addition:    "; c[1].PrintU16 ('\n');
	AVXPackedSubU16_ (a, b, c);
	std::cout << "WrapAround Subtraction: "; c[0].PrintU16 ('\n');
	std::cout << "Saturated  Subtraction: "; c[1].PrintU16 ('\n');
}
void AVXPackedMathI16 ()
{
	std::cout << "Results of " << __FUNCTION__ << ":\n";
	alignas(16) XmmVal a, b, c[2];
	a.i16[0] = 10,	   b.i16[0] = 100;
	a.i16[1] = 200,	   b.i16[1] = -200;
	a.i16[2] = -30,	   b.i16[2] = 32760;
	a.i16[3] = -32766, b.i16[3] = 400;
	a.i16[4] = 50,	   b.i16[4] = 500;
	a.i16[5] = 60,	   b.i16[5] = -600;
	a.i16[6] = 32000,  b.i16[6] = 1200;
	a.i16[7] = -32000, b.i16[7] = 950;
	std::cout << 'a' << ':' << ' ';a.PrintI16 ('\n');
	std::cout << 'b' << ':' << ' ';b.PrintI16 ('\n');
	std::cout << "-------------\n";
	AVXPackedAddI16_ (a, b, c);
	std::cout << "WrapAround Addition:    "; c[0].PrintI16 ('\n');
	std::cout << "Saturated  Addition:    "; c[1].PrintI16 ('\n');
	AVXPackedSubI16_ (a, b, c);
	std::cout << "WrapAround Subtraction: "; c[0].PrintI16 ('\n');
	std::cout << "Saturated  Subtraction: "; c[1].PrintI16 ('\n');
	
	// Note : when multiplying resulting size is 2 times the input size
	AVXPackedMulI16_ (a, b, c);
	std::cout << "Multiplication:         "; c[0].PrintI32 (); c[1].PrintI32 ('\n');
}
void AVXPackedMathI32 ()
{
	std::cout << "Results of " << __FUNCTION__ << ":\n";
	alignas(16) XmmVal a, b, c[2];
	a.i32[0] = 10,	   b.i32[0] = 100;
	a.i32[1] = 200,	   b.i32[1] = -200;
	a.i32[2] = -30,	   b.i32[2] = 32760;
	a.i32[3] = -32766, b.i32[3] = 400;

	std::cout << 'a' << ':' << ' '; a.PrintI32 ('\n');
	std::cout << 'b' << ':' << ' '; b.PrintI32 ('\n');
	std::cout << "-------------\n";
	AVXPackedMulI32A_ (a, b, c);
	std::cout << "MultiplicationA(result in I64): "; c[0].PrintI64 (); c[1].PrintI64 ('\n');
	AVXPackedMulI32B_ (a, b, c[0]);
	std::cout << "MultiplicationB(result in I32): "; c[0].PrintI32 ('\n');
}
void AVXPackedIntShift ()
{
	std::cout << "Results of " << __FUNCTION__ << ":\n";
	alignas(16) XmmVal a, b;
	constexpr uint32_t count = 6;
	a.u16[0] = 0x1234;
	a.u16[1] = 0xFF00;
	a.u16[2] = 0x00CC;
	a.u16[3] = 0x8080;
	a.u16[4] = 0x00FF;
	a.u16[5] = 0xAAAA;
	a.u16[6] = 0x0F0F;
	a.u16[7] = 0x0101;

	bool success;
	std::cout << "a:               "; a.Printbin16 ('\n');
	std::cout << "------------- Count: " << count << '\n';
	success = AVXPackedIntShift_ (a, count, ShiftOp::U16_LL, b);
	std::cout << "ShiftOp::U16_LL: "; b.Printbin16 ('\n');
	success = AVXPackedIntShift_ (a, count, ShiftOp::U16_RL, b);
	std::cout << "ShiftOp::U16_RL: "; b.Printbin16 ('\n');
	success = AVXPackedIntShift_ (a, count, ShiftOp::U16_RA, b);
	std::cout << "ShiftOp::U16_RA: "; b.Printbin16 ('\n');

	std::cout << "\na:               "; a.Printbin32 ('\n');
	success = AVXPackedIntShift_ (a, count, ShiftOp::U32_LL, b);
	std::cout << "ShiftOp::U32_LL: "; b.Printbin32 ('\n');
	success = AVXPackedIntShift_ (a, count, ShiftOp::U32_RL, b);
	std::cout << "ShiftOp::U32_RL: "; b.Printbin32 ('\n');
	success = AVXPackedIntShift_ (a, count, ShiftOp::U32_RA, b);
	std::cout << "ShiftOp::U32_RA: "; b.Printbin32 ('\n');
}