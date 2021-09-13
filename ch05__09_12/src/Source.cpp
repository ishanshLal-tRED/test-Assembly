#include <iostream>
#include <iomanip>

extern "C" uint64_t ComputeSum_ (uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t);


extern "C" bool ComputeSumPdt_ (int64_t*, int64_t*, int64_t, int64_t*, int64_t*, int64_t*, int64_t*);

extern "C" bool ComputeConesSAandVol (const double *, const double *, int32_t, double *, double *);

int main ()
{
	{
		uint32_t arr[8] = { 1,2,3,4,5,6,7,8 };
		uint64_t sum = 0;
		for (auto i : arr)
			std::cout << i << "\n", sum += i;
		std::cout << "-------------\n";
		std::cout << ComputeSum_ (arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7]) << " " << sum;
	}
	std::cout << "\n\n\n";
	{
		int64_t arr[8] = { 1,2,3,4,5,6,7,8 };
		int64_t arr2[8] = { 1,2,3,4,5,6,7,8 };
		int64_t sum = 0, sum2 = 0;
		int64_t pdt = 0, pdt2 = 0;
		for (uint32_t i = 0; i < 8; i++)
			std::cout << "#" << i << "  " << std::setw (6) << arr[i] << " " << std::setw (6) << arr2[i] <<"\n";
		std::cout << "---------------------\n";
		bool success = ComputeSumPdt_ (arr, arr2, 8, &sum, &sum2, &pdt, &pdt2);
		std::cout << "SUM: " << std::setw (6) << sum << " " << std::setw (6) << sum2 << "\n";
		std::cout << "PDT: " << std::setw (6) << pdt << " " << std::setw (6) << pdt2 << "\n";
		std::cout << "good(" << success << ")";
	}
	std::cout << "\n\n\n";
	{
		constexpr int32_t NumOfCones = 7;
		double r[NumOfCones] = { 1,1,2,2,3,3,4.25 };
		double h[NumOfCones] = { 1,2,3,4,5,10,12.5 };

		double sa_cones[NumOfCones], vol_cones[NumOfCones];
		bool success = ComputeConesSAandVol (r, h, NumOfCones, sa_cones, vol_cones);

		using namespace std;
		cout << fixed;
		cout << "Result:\n";
		cout << "   Radius      Height      SurfaceArea    Volume\n";
		for (uint32_t i = 0; i < NumOfCones; i++)
		{
			cout << setprecision (2);
			cout << setw (7) << r[i] << ' ';
			cout << setw (7) << h[i] << ' ';
			cout << setprecision (6);
			cout << setw (7) << sa_cones[i] << ' ';
			cout << setw (7) << vol_cones[i] << '\n';
		}
	}
	return 0;
};