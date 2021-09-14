#include <iostream>
#include <iomanip>
#include <thread>
#include <chrono>

extern "C" uint64_t ComputeSum_ (uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t);


extern "C" bool ComputeSumPdt_ (int64_t*, int64_t*, int64_t, int64_t*, int64_t*, int64_t*, int64_t*);


extern "C" bool ComputeConesSAandVol_ (const double *, const double *, int32_t, double *, double *);


extern "C" bool HomoSapiansBodySurfaceArea_ (const double *, const double *, int32_t, double *, double *, double *);

int main ()
{
	using namespace std;
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
		bool success = ComputeConesSAandVol_ (r, h, NumOfCones, sa_cones, vol_cones);

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
	{

		constexpr uint32_t NUM = 6;
		const double ht[NUM] = { 150,160,170,180,190,200 };
		const double wt[NUM] = { 50,60.0,70,80.0,90,100.0 };
		double bsa1[NUM], bsa2[NUM], bsa3[NUM];
		//bsa1[i] = 0.007184 * pow (ht[i], 0.725) * pow (wt[i], 0.425);
		//bsa2[i] = 0.0235 * pow (ht[i], 0.42246) * pow (wt[i], 0.51456);
		//bsa3[i] = sqrt (ht[i] * wt[i] / 3600.0);
		bool success = HomoSapiansBodySurfaceArea_ (ht, wt, NUM, bsa1, bsa2, bsa3);

		cout << fixed;
		cout << "Result:\n";
		cout << "     Height       Width  SurfaceArea1 SurfaceArea2 SurfaceArea13\n";
		for (uint32_t i = 0; i < NUM; i++) {
			cout << setprecision (2);
			cout << setw (11) << ht[i] << ' ';
			cout << setw (11) << wt[i] << ' ';
			cout << setprecision (6);
			cout << setw (11) << bsa1[i] << ' ';
			cout << setw (11) << bsa2[i] << ' ';
			cout << setw (11) << bsa3[i] << '\n';
		}
		cout << "good(" << success << ")\n";
	}
	std::this_thread::sleep_for (std::chrono::seconds (2));
	return 0;
};