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

extern "C" bool AVXCalcCorrCoef_ (const double *x, const double *y, size_t n, double sum[5], double epsilon, double *rho);
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
	cout << '\n' << '\n';
	{
		constexpr size_t n = 103;
		constexpr size_t alignment = 32;
		alignas(alignment) double x_aa[n];
		alignas(alignment) double y_aa[n];
		double sum[5], rho;// , sum_cpp[5] = { 0,0,0,0,0 };
		double epsilon = 1.0e-12;
		{
			uint16_t arr[n];
			Init (arr, n, 7);
			for (uint32_t i = 0; i < n; i++) {
				x_aa[i] = double (arr[i]);
				y_aa[i] = (int (arr[i]) % 6000) - 3000;
				//sum_cpp[0] += x_aa[i];
				//sum_cpp[1] += y_aa[i];
				//sum_cpp[2] += x_aa[i]*x_aa[i];
				//sum_cpp[3] += y_aa[i]*y_aa[i];
				//sum_cpp[4] += x_aa[i]*y_aa[i];
			}
		}
		//double val_num = n*sum_cpp[4] - sum_cpp[0] * sum_cpp[1];
		//double val_denom_t1 = sqrt(n*sum_cpp[2] - sum_cpp[0]*sum_cpp[0]);
		//double val_denom_t2 = sqrt(n*sum_cpp[3] - sum_cpp[1]*sum_cpp[1]);
		//double val_denom = val_denom_t1*val_denom_t2;
		//// t1 = sqrt (n * sum_xx - sum_x * sum_x)
		//// t2 = sqrt (n * sum_yy - sum_y * sum_y)
		bool success = AVXCalcCorrCoef_ (x_aa, y_aa, n, sum, epsilon, &rho);
		cout << "\nResults of AVXCalcCorrCoef():\n";
		for (uint32_t i = 0; i < n; i++) {
			cout << setw (3) << i << ' ' << setw (15) << x_aa[i] << setw (15) << y_aa[i] << '\n';
		}
		int w = 14;
		string sep (w * 3, '-');
		cout << fixed << setprecision (8);
		cout << "Value " << '\n';
		cout << sep << '\n';
		cout << "rho: " << setw (w) << rho << "\n\n"; //' ' << setw (w) << double(val_num/val_denom) << "\n\n";
		cout << setprecision (1);
		cout << "sum_x:  " << setw (w) << sum[0] << '\n';//' ' << setw (w) << sum_cpp[0] << '\n';
		cout << "sum_y:  " << setw (w) << sum[1] << '\n';//' ' << setw (w) << sum_cpp[1] << '\n';
		cout << "sum_xx: " << setw (w) << sum[2] << '\n';//' ' << setw (w) << sum_cpp[2] << '\n';
		cout << "sum_yy: " << setw (w) << sum[3] << '\n';//' ' << setw (w) << sum_cpp[3] << '\n';
		cout << "sum_xy: " << setw (w) << sum[4] << '\n';//' ' << setw (w) << sum_cpp[4] << '\n';
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};