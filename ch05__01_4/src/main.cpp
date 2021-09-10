#include <iostream>
#include <string>
#include <iomanip>
#include <limits>

extern "C" float ConvertCtoF_ (float);
extern "C" float ConvertFtoC_ (float);

extern "C" bool CalcSphereAreaAndVol_ (double radius, double *cantainer_surface_area, double *cantainer_volume);

extern "C" double CalcDist_ (double x1, double y1, double z1, double x2, double y2, double z2);

extern "C" void CompareVCOMISS_ (float a, float b, bool *results);
extern "C" void CompareVCOMISD_ (double a, double b, bool *results);
const char *c_OpStrings[] = { "UO", "LT", "LE", "EQ", "NE", "GT", "GE" };
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
void CompareVCOMISS (void);
void CompareVCOMISD (void);

int main ()
{
	float val;
	std::cout <<"ConvertTemp\n";
	val = 40.0f;
	std::cout << "Fahrenheit: " << std::setw (10) << val << "  to Celsius: " << std::setw (10) << ConvertFtoC_(val) << "\n";
	val = 49.2f;
	std::cout << "Fahrenheit: " << std::setw (10) << val << "  to Celsius: " << std::setw (10) << ConvertFtoC_(val) << "\n";
	val = -76.3f;
	std::cout << "Fahrenheit: " << std::setw (10) << val << "  to Celsius: " << std::setw (10) << ConvertFtoC_(val) << "\n";

	val = -76.3f;
	std::cout << "Celsius: " << std::setw (10) << val << "  to Fahrenheit: " << std::setw (10) << ConvertCtoF_(val) << "\n";
	val = 49.2f;
	std::cout << "Celsius: " << std::setw (10) << val << "  to Fahrenheit: " << std::setw (10) << ConvertCtoF_(val) << "\n";
	val = 40.0f;
	std::cout << "Celsius: " << std::setw (10) << val << "  to Fahrenheit: " << std::setw (10) << ConvertCtoF_(val) << "\n";


	std::cout <<"\nCalcSphereAreaAndVol\n"<< std::setprecision (8);
	double SA, Vol;
	bool success;
	val = 10;
	success = CalcSphereAreaAndVol_ (double (val), &SA, &Vol);
	std::cout << "radius: "  << std::setw (5) << val << " good(" << success << ")" << "  SurfaceArea: " << SA << " Volume: " << Vol << "\n";
	val = 0;
	success = CalcSphereAreaAndVol_ (double (val), &SA, &Vol);
	std::cout << "radius: "  << std::setw (5) << val << " good(" << success << ")" << "  SurfaceArea: " << SA << " Volume: " << Vol << "\n";
	val = 1;
	success = CalcSphereAreaAndVol_ (double (val), &SA, &Vol);
	std::cout << "radius: " << std::setw (5) << val << " good(" << success << ")" << "  SurfaceArea: " << SA << " Volume: " << Vol << "\n";
	val = -1;
	success = CalcSphereAreaAndVol_ (double (val), &SA, &Vol);
	std::cout << "radius: " << std::setw(5) << val << " good(" << success << ")" << "  SurfaceArea: " << SA << " Volume: " << Vol << "\n";

	
	std::cout <<"\nCalcSphereAreaAndVol\n"<< std::setprecision (8);
	double a[3] = { 1,2,3 };
	double b[3] = { -3,-2,-1 };
	std::cout << "a{ " << a[0] << ", " << a[1] << ", " << a[2] << "}, b{ " << b[0] << ", " << b[1] << ", " << b[2] << "} -> " << CalcDist_ (a[0], a[1], a[2], b[0], b[1], b[2]) << "\n\n\n";


	CompareVCOMISS ();
	CompareVCOMISD ();
	return 0;
}

void CompareVCOMISS (void)
{
	const size_t n = 6;
	float a[n]{ 120.0, 250.0, 300.0, -18.0, -81.0, 42.0 };
	float b[n]{ 130.0, 240.0, 300.0, 32.0, -100.0, 0.0 };
	// Set NAN test value
	b[n - 1] = std::numeric_limits<float>::quiet_NaN ();
	std::cout << "\nResults for CompareVCOMISS\n";
	std::cout << g_Dashes << '\n';
	for (size_t i = 0; i < n; i++) {
		bool cmp_results[c_NumOpStrings];

		CompareVCOMISS_ (a[i], b[i], cmp_results);
		PrintResults (a[i], b[i], cmp_results);
	}
}
void CompareVCOMISD (void)
{
	const size_t n = 6;
	double a[n]{ 120.0, 250.0, 300.0, -18.0, -81.0, 42.0 };
	double b[n]{ 130.0, 240.0, 300.0, 32.0, -100.0, 0.0 };
	// Set NAN test value
	b[n - 1] = std::numeric_limits<double>::quiet_NaN ();
	std::cout << "\nResults for CompareVCOMISD\n";
	std::cout << g_Dashes << '\n';
	for (size_t i = 0; i < n; i++) {
		bool cmp_results[c_NumOpStrings];

		CompareVCOMISD_ (a[i], b[i], cmp_results);
		PrintResults (a[i], b[i], cmp_results);
	}
}