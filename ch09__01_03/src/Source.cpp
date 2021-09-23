#include <thread>
#include <chrono>

#include <string>
#include <bitset>

#include "UnifiedCantainer.h"
#define _USE_MATH_DEFINES
#include <math.h>

#define CANTAINER_WIDTH 32
#define cnt_wid CANTAINER_WIDTH
extern "C" bool AvxPackedMathF32_ (const Unified<cnt_wid>&a, const Unified<cnt_wid>&b, Unified<cnt_wid> c[8]);
extern "C" bool AvxPackedMathF64_ (const Unified<cnt_wid>&a, const Unified<cnt_wid>&b, Unified<cnt_wid> c[8]);

extern "C" float c_PI_F32 = float (M_PI);
extern "C" float c_QNaN_F32 = std::numeric_limits<float>::quiet_NaN ();
extern "C" void AVXCalcSphereAreaVolume_ (const float *r, const size_t n, float *sa, float *vol);

extern "C" size_t c_NumRowsMax = 1024*1024;
extern "C" size_t c_NumColsMax = 1024*1024;
extern "C" bool AVXCalcColumnMeans_ (const double *x, size_t nrows, size_t ncols, double *col_means);
int main ()
{
	using namespace std;
	{
		typedef float theTyp;//double theTyp;
		
		alignas(cnt_wid) Unified<cnt_wid> a;
		alignas(cnt_wid) Unified<cnt_wid> b;
		alignas(cnt_wid) Unified<cnt_wid> c[8];
		Init ((theTyp *)(&a.u8[0]), cnt_wid/sizeof (theTyp), 1);
		Init ((theTyp *)(&b.u8[0]), cnt_wid/sizeof (theTyp), 2);
		a.Print<theTyp> () << " :A\n";
		b.Print<theTyp> () << " :B\n";
		bool success = false;
		if (sizeof (theTyp) == sizeof (float))
			success = AvxPackedMathF32_ (a, b, c);
		else if (sizeof (theTyp) == sizeof (double))
			success = AvxPackedMathF64_ (a, b, c);
		cout << "good(" << success << ") Results of AvxPackedMathF32_ \n";
		const char *mathOpStr[8] = { "addps","subps","mulps","divps","absps(b)","sqrtps(a)","minps","maxps" };
		for (uint32_t i = 0; i < 8; i++)
			c[i].Print<theTyp> () << ' ' << mathOpStr[i] << '\n';
	}
	cout <<'\n'<<'\n';
	{
		constexpr size_t n = 21;
		alignas(32) float r[n];
		alignas(32) float sa[n];
		alignas(32) float vol[n];
		Init (r, n);

		AVXCalcSphereAreaVolume_ (r, n, sa, vol);

		cout << "\nResults for AvxCalcSphereAreaVolume\n";
		cout << fixed;
		for (size_t i = 0; i < n; i++) {
			cout << setw (2) << i << ": ";
			cout << setprecision (2);
			cout << setw (5) << r[i] << " | ";
			cout << setprecision (6);
			cout << setw (12) << sa[i] << " ";
			cout << setw (12) << vol[i] << '\n';
		}
	}
	cout << '\n' << '\n';
	{
		const size_t n_rows = 20;
		const size_t n_cols = 11;
		double *arr = new double[n_cols*n_rows];
		double *cols_means = new double[n_rows];
		
		Init (arr, n_cols*n_rows, 20);

		bool success = AVXCalcColumnMeans_ (arr, n_rows, n_cols, cols_means);
		cout << "good(" << success << ") Results of AVXCalcColumnMeans():\nmatrix:\n";
		cout << fixed << setprecision (4);
		for (size_t i = 0; i < n_rows; i++) {
			cout << "row " << setw (2) << i << "     ";
			for (size_t j = 0; j < n_cols; j++)
				cout << setw (11) << arr[i * n_cols + j];
			cout << '\n';
		}

		cout << "-----------------------------------------------------------------------------------------------------------------------------------------\n";
		cout << "ColumnMeans:" << setprecision (4);
		for (size_t j = 0; j < n_cols; j++) {
			cout << setw (10) << cols_means[j] << ' ';
		}
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};