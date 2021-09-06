#include <iostream>
#include <cmath>
#include <bitset>

// using uint8_t as bool to gaurentee its 1 byte
extern "C" bool SumAndSqrs_ (int32_t* src_arr, int32_t* dest_arr, int32_t* arrSum, int32_t* arrSqrSum, int64_t arraySize);
extern "C" bool TransposeSqrMat_ (int32_t* src, int32_t size);

struct TestStruct
{
public:
	uint8_t val8_t;
	uint8_t __pad8_t;
	int16_t ival16_t;
	uint32_t val32_t;
	int64_t ival64_t;
};
extern "C" bool TestStructureSum_ (TestStruct* src_arr, uint32_t length, TestStruct* result);

int main ()
{
	int32_t arr[] = {10, 20};
	constexpr int64_t arrSize = sizeof (arr) / sizeof (arr[0]);
	int32_t *sqr_arr = new int32_t[arrSize];

	int32_t sum, sqr_sum;
	bool success = SumAndSqrs_ (arr, nullptr, &sum, &sqr_sum, arrSize);

	for (uint32_t i = 0; i < arrSize; i++) {
		std::cout << "#" << i << "  arr{" << arr[i] << "} sqr_arr{" << sqr_arr[i]<<"}\n";
	}
	std::cout << "-good("<<success<<")---- SUM: " << sum << "  SQR_SUM: " << sqr_sum << "\n";

	constexpr int32_t MatSize = 4;
	int32_t matrix[MatSize][MatSize] =
	{
		{1, 2, 3, 4},
		{1, 2, 3, 4},
		{1, 2, 3, 4},
		{1, 2, 3, 4}
	};

	std::cout << "\n\nbefore";
	for (uint32_t i = 0; i < MatSize; i++) {
		std::cout << "\n{";
		for (uint32_t j = 0; j < MatSize; j++) {
			std::cout << ", " << matrix[i][j];
		}
		std::cout << " }";
	}
	//int32_t size = int32_t (sqrt (float (sizeof (matrix)/matrix[0][0])));
	success = TransposeSqrMat_ ((int32_t*)(&matrix[0][0]), MatSize);

	std::cout << "\n\nafter"; 
	for (uint32_t i = 0; i < MatSize; i++)
	{
		std::cout << "\n{";
		for (uint32_t j = 0; j < MatSize; j++) {
			std::cout << ", " << matrix[i][j];
		}
		std::cout << " }";
	}

	TestStruct* src = new TestStruct[3];
	TestStruct dest;
	success = TestStructureSum_ (src, 3, &dest);

	return 0;
}