#include <iostream>
#include <fstream>
#include <string>
#include <iomanip>
#include <thread>
#include <chrono>
#include <random>
#include <bitset>
#include <concepts>
#include "AlignedMem.h"

#define   _USE_MATH_DEFINES
#include <math.h>

extern "C" uint64_t GprMulx_ (uint32_t a, uint32_t b, uint64_t flags[2]);
extern "C" void GprShiftx_ (uint32_t x, uint32_t count, uint32_t results[3], uint64_t flags[4]);
std::string FlagsToString (uint64_t flags);

extern "C" void GprCountZeroBits_ (uint32_t x, uint32_t *lzcnt, uint32_t *tzcnt);
extern "C" uint32_t GprBextr_ (uint32_t x, uint8_t start, uint8_t length);
extern "C" uint32_t GprAndNot_ (uint32_t x, uint32_t y);

extern "C" void SingleToHalfPricision (float x_sp[8], uint16_t x_hp[8], int rc);
extern "C" void HalfToSinglePricision (uint16_t x_hp[8], float x_sp[8]);
int main ()
{
	using namespace std;
	{
		{
			constexpr int n = 3;
			uint32_t a[n] = { 64, 3200, 100000000 };
			uint32_t b[n] = { 1001, 12, 250000000 };

			cout << "\nResults for AVXGprMulx:\n";

			for (int i = 0; i < n; i++) {
				uint64_t flags[2];
				uint64_t c = GprMulx_ (a[i], b[i], flags);

				cout << "\nTest case " << i << '\n';
				cout << " a: " << a[i] << " b: " << b[i] << " c: " << c << '\n';

				cout << setfill ('0') << hex;
				cout << " status flags before mulx: " << FlagsToString (flags[0]) << '\n'
					 << " status flags after  mulx: " << FlagsToString (flags[1]) << '\n';

				cout << setfill (' ') << dec;
			}
		}
		{
			constexpr int n = 4;
			uint32_t x[n] = { 0x00000008,0x00000080,0x00000040,0xfffffc10 };
			uint32_t count[n] = { 2,5,3,4 };

			cout << "\nResults for GprShiftx:\n";
			for (int i = 0; i < n; i++) {
				uint32_t results[3];
				uint64_t flags[4];
				GprShiftx_ (x[i], count[i], results, flags);
				cout << setfill (' ') << dec;
				cout << "\nTest case " << i << '\n';
				cout << setfill ('0') << hex << " x:    0x" << bitset<64>(x[i]) << " (";
				cout << setfill (' ') << dec << *(int32_t *)(&x[i]) << ") count: " << count[i] << '\n';
				cout << setfill ('0') << hex << " sarx: 0x" << bitset<64> (results[0]) << " (";
				cout << setfill (' ') << dec << *(int32_t *)(&results[0]) << ")\n";
				cout << setfill ('0') << hex << " shlx: 0x" << bitset<64> (results[1]) << " (";
				cout << setfill (' ') << dec << *(int32_t *)(&results[1]) << ")\n";
				cout << setfill ('0') << hex << " shrx: 0x" << bitset<64> (results[2]) << " (";
				cout << setfill (' ') << dec << *(int32_t *)(&results[2]) << ")\n";
				cout << " status flags before shifts: " << FlagsToString (flags[0]) << '\n'
					 << " status flags after sarx:    " << FlagsToString (flags[1]) << '\n'
					 << " status flags after shlx:    " << FlagsToString (flags[2]) << '\n'
					 << " status flags after shrx:    " << FlagsToString (flags[3]) << '\n';

			}
		}
	}
	cout << '\n' << '\n';
	{
		{
			constexpr int n = 5;
			uint32_t x[n] = { 0x001000008, 0x00008000,0x80000000,0x00000001 };
			
			cout << "\nResults of CountZeroBits:\n";

			for (int i = 0; i < n; i++) {
				uint32_t lzcnt, tzcnt;
				GprCountZeroBits_ (x[i], &lzcnt, &tzcnt);

				cout << setfill ('0') << hex
					 << "x:   0x" << setw (8) << x[i] << ' '
					 << setfill (' ') << dec
					 << "lzcnt: " << setw (3) << lzcnt << ' '
					 << "tzcnt: " << setw (3) << tzcnt << '\n';
			}
		}{
			constexpr int n = 3;
			uint32_t x[n] = { 0x12345678,0x80808080,0xfedcba98 };
			uint8_t start[n] = { 4,7,24 };

			uint8_t len[n] = { 16,9,8 };

			cout << "\nResults of GprExtractBitField:\n";

			for (int i = 0; i < n; i++)
			{
				uint32_t bextr = GprBextr_ (x[i], start[i], len[i]);

				cout << setfill ('0') << hex
					 << "x:    0x" << setw (8) << x[i] << ' '
					 << setfill (' ') << dec
					 << "start:  " << setw (3) << uint32_t (start[i]) << ' '
					 << "len:    " << setw (3) << uint32_t (len[i]) << ' '
					 << setfill ('0') << hex
					 << "bextr:0x" << setw (8) << uint32_t (start[i]) << '\n';
			}
		}{
			constexpr int n = 3;
			uint32_t x[n] = { 0xf000000f,0xff00ff00,0xaaaaaaaa };
			uint32_t y[n] = { 0x12345678,0x12345678,0xffaa5500 };

			cout << "\nResults for GprAndNot:\n" << setfill ('0') << hex;

			for (int i = 0; i < n; i++) {
				uint32_t andn = GprAndNot_ (x[i], y[i]);

				cout << "x:   0x" << setw (8) << x[i] << ' '
					 << "y:   0x" << setw (8) << y[i] << ' '
					 << "andn:0x" << setw (8) << andn << '\n';
			}
		}
	}
	cout << '\n' << '\n';
	{
		float x[8];
		x[0] =     4.125;
		x[1] =    32.900;
		x[2] =    56.3333;
		x[3] =   -68.6667;
		x[4] = 42000.5;
		x[5] = 75600.0;
		x[6] = -6002.125;
		x[7] =   170.0625;

		uint16_t x_hp[8];

		float rn[8], rd[8], ru[8], rz[8];

		SingleToHalfPricision (x , x_hp, 0); HalfToSinglePricision (x_hp,rn);
		SingleToHalfPricision (rn, x_hp, 1); HalfToSinglePricision (x_hp,rd);
		SingleToHalfPricision (rd, x_hp, 2); HalfToSinglePricision (x_hp,ru);
		SingleToHalfPricision (ru, x_hp, 3); HalfToSinglePricision (x_hp,rz);

		uint32_t w = 15;
		string line (76, '-');

		cout << fixed << setfill (' ') << setprecision (4);
		cout << setw (w) << "x"
			 << setw (w) << "|RoundNearest"
			 << setw (w) << "|RoundDown"
			 << setw (w) << "|RoundUp"
			 << setw (w) << "|RoundZero"
			 << '\n' << line << '\n';

		for (int i = 0; i < 8; i++) {
			cout << setw (w) <<  x[i]
				 << setw (w) << rn[i]
				 << setw (w) << rd[i]
				 << setw (w) << ru[i]
				 << setw (w) << rz[i]
				 << '\n';
		}
	}
	return 0;
};
std::string FlagsToString (uint64_t flags)
{
	std::ostringstream oss;
	oss << "OF: " << ((flags & (1ULL << 11)) ? '1' : '0') << ' ';
	oss << "SF: " << ((flags & (1ULL <<  7)) ? '1' : '0') << ' ';
	oss << "ZF: " << ((flags & (1ULL <<  6)) ? '1' : '0') << ' ';
	oss << "PF: " << ((flags & (1ULL <<  2)) ? '1' : '0') << ' ';
	oss << "CF: " << ((flags & (1ULL <<  0)) ? '1' : '0') << ' ';

	return oss.str ();
}