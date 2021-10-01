#include <thread>
#include <chrono>

#include <string>
#include <bitset>

#include "UnifiedCantainer.h"
#define _USE_MATH_DEFINES
#include <math.h>

#define CANTAINER_WIDTH 32
#define cnt_wid CANTAINER_WIDTH
extern "C" bool AVX2PackedMathI16_ (const Unified<cnt_wid>&a, const Unified<cnt_wid>&b, Unified<cnt_wid> *c);
extern "C" bool AVX2PackedMathI32_ (const Unified<cnt_wid>&a, const Unified<cnt_wid>&b, Unified<cnt_wid> *c);

struct YmmVal2
{
	Unified<cnt_wid> a;
	Unified<cnt_wid> b;
};
extern "C" YmmVal2 AVX2UnpackU32_U64_ (const Unified<cnt_wid>& a, const Unified<cnt_wid>& b);
extern "C" void AVX2PackI32_I16_ (const Unified<cnt_wid>& a, const Unified<cnt_wid>& b, Unified<cnt_wid> *c);

extern "C" void AVX2ZeroExtU8_U16_  (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[2]);
extern "C" void AVX2ZeroExtU8_U32_  (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[4]);
extern "C" void AVX2SignExtI16_I32_ (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[2]);
extern "C" void AVX2SignExtI16_I64_ (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[4]);
int main ()
{
	using namespace std;
	{
		typedef int16_t theTyp;//int32_t theTyp;
		
		alignas(cnt_wid) Unified<cnt_wid> a;
		alignas(cnt_wid) Unified<cnt_wid> b;
		alignas(cnt_wid) Unified<cnt_wid> c[6];
		Init ((theTyp *)(&a.u8[0]), cnt_wid/sizeof (theTyp), 1, -70, 90);
		Init ((theTyp *)(&b.u8[0]), cnt_wid/sizeof (theTyp), 2, -70, 90);
		a.Print<theTyp> () << " :A\n";
		b.Print<theTyp> () << " :B\n";
		bool success = false;
		constexpr size_t numOfOptrns = 6;
		const char *mathOpStrW[numOfOptrns] = { "vpaddw","vpaddsw","vpsubw","vpsubsw","vpminsw","vpmaxsw" };
		const char *mathOpStrD[numOfOptrns] = { "vpaddd","vpsubd","vpmulld","vpsllvd","vpsravd","vpabsd" };
		if (sizeof (theTyp) == sizeof (int16_t))
			success = AVX2PackedMathI16_ (a, b, c);
		else if (sizeof (theTyp) == sizeof (int32_t))
			success = AVX2PackedMathI32_ (a, b, c);
		cout << "good(" << success << ") Results of AvxPackedMathF32:\n";
		for (uint32_t i = 0; i < numOfOptrns; i++)
			c[i].Print<theTyp> () << ' ' << (sizeof (theTyp) == sizeof (int16_t) ? mathOpStrW[i] : 
											 sizeof (theTyp) == sizeof (int32_t) ? mathOpStrD[i] : "unknown") << '\n';
	}
	cout << '\n' << '\n';
	{
		{
			alignas(32) Unified<cnt_wid> a;
			alignas(32) Unified<cnt_wid> b;
			alignas(32) Unified<cnt_wid> c;

			a.i32[0] =      10, b.i32[0] =  32768;
			a.i32[1] = -200000, b.i32[1] =   6500;
			a.i32[2] =  300000, b.i32[2] =  42000;
			a.i32[3] =   -4000, b.i32[3] = -68000;
			a.i32[4] =    9000, b.i32[4] =  25000;
			a.i32[5] =   80000, b.i32[5] = 500000;
			a.i32[6] =     200, b.i32[6] =  -7000;
			a.i32[7] =  -32769, b.i32[7] =  12500;

			AVX2PackI32_I16_ (a, b, &c);
			cout << "\nResults of AVX2PackI32_I16:\n";
			a.Print<int32_t> () << " :A\n";
			b.Print<int32_t> () << " :B\n";
			c.Print<int16_t> () << " :C\n";
		}
		{
			alignas(32) Unified<cnt_wid> a;
			alignas(32) Unified<cnt_wid> b;

			a.u32[0] = 0x00000000, b.u32[0] = 0x88888888;
			a.u32[1] = 0x11111111, b.u32[1] = 0x99999999;
			a.u32[2] = 0x22222222, b.u32[2] = 0xAAAAAAAA;
			a.u32[3] = 0x33333333, b.u32[3] = 0xBBBBBBBB;
			a.u32[4] = 0x44444444, b.u32[4] = 0xCCCCCCCC;
			a.u32[5] = 0x55555555, b.u32[5] = 0xDDDDDDDD;
			a.u32[6] = 0x66666666, b.u32[6] = 0xEEEEEEEE;
			a.u32[7] = 0x77777777, b.u32[7] = 0xFFFFFFFF;

			cout << "\nResults of AVX2UnpackU32_U64_ (a, b):\n";
			a.PrintHex<uint32_t> () << " :A\n";
			b.PrintHex<uint32_t> () << " :B\n---nvpunpckldq-results--------------------------------------\n";
			AVX2UnpackU32_U64_ (a, b); // when we are calling function it is allocating the space for Ymmval2 but since there's no one to pickup the variable the stack allocation lefts unattended.
			YmmVal2 c = AVX2UnpackU32_U64_ (a, b);
			c.a.PrintHex<uint64_t> () << " :C(lower_order)\n";
			c.b.PrintHex<uint64_t> () << " :C(higher_order)\n\n";
		}
	}
	cout << '\n' << '\n';
	{
		alignas(cnt_wid) Unified<cnt_wid> src;
		alignas(cnt_wid) Unified<cnt_wid> dest[4];
		Init (src.u8, cnt_wid, 19);
		AVX2ZeroExtU8_U16_ (src, dest);
		src.Print<uint8_t, uint16_t> () << " :SRC\n";
		cout << "Results of AVX2ZeroExtU8_U16:\n";
		dest[0].Print<uint16_t> () << " :Dest[0]\n";
		dest[1].Print<uint16_t> () << " :Dest[1]\n";

		AVX2ZeroExtU8_U32_ (src, dest);
		cout << "\nResults of AVX2ZeroExtU8_U32:\n";
		dest[0].Print<uint32_t> () << " :Dest[0]\n";
		dest[1].Print<uint32_t> () << " :Dest[1]\n";
		dest[2].Print<uint32_t> () << " :Dest[2]\n";
		dest[3].Print<uint32_t> () << " :Dest[3]\n\n";

		Init (src.i16, cnt_wid/2, 11);
		AVX2SignExtI16_I32_ (src, dest);
		src.Print<int16_t> () << " :SRC\n";
		cout << "Results of AVX2SignExtI16_I32:\n";
		dest[0].Print<int32_t> () << " :Dest[0]\n";
		dest[1].Print<int32_t> () << " :Dest[1]\n";

		AVX2SignExtI16_I64_ (src, dest);
		cout << "\nResults of AVX2SignExtI16_I64:\n";
		dest[0].Print<int64_t> () << " :Dest[0]\n";
		dest[1].Print<int64_t> () << " :Dest[1]\n";
		dest[2].Print<int64_t> () << " :Dest[2]\n";
		dest[3].Print<int64_t> () << " :Dest[3]\n\n";

	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};