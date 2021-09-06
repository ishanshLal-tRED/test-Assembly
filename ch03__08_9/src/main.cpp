#include <iostream>
#include <string>
#include <iomanip>

extern "C" uint32_t CountElements_ (int32_t* src_arr, uint32_t num_of_elements, int32_t find);
extern "C" bool CampareArrays_ (int32_t* src1_arr, int32_t* src2_arr, uint32_t num_of_elements, int32_t* change_at);
extern "C" bool RevertArray_ (int32_t* src1_arr, int32_t* src2_arr, uint32_t num_of_elements);

int main ()
{
	int32_t arr[] = {10, 20, 199, 10};
	constexpr uint32_t arrSize = sizeof (arr) / sizeof (arr[0]);
	int32_t element = 10;

	auto count = CountElements_ (arr, arrSize, element);

	for (uint32_t i = 0; i < arrSize; i++) {
		std::cout << "#" << i << "  arr -> " << std::setw(6) << arr[i] << "\n";
	}
	std::cout << "  ---- ELEM: " << element << "  count: " << std::setw (6) << count << "\n";


	int32_t *arr1 = new int32_t[]{ 10, 20, 192, 10 }; // Heap allocation is must for null termination like strings
	int32_t *arr2 = new int32_t[]{ 10, 20, 192, 10 }; // Heap allocation is must for null termination like strings
	int32_t at;
	bool success = CampareArrays_ (arr1, arr2, arrSize, &at);

	std::cout << "\n\n----      arr1    arr2\n";
	for (uint32_t i = 0; i < arrSize; i++) {
		std::string tmp = "#" + std::to_string (i);
		std::cout << std::setw(4) << tmp << "   " << std::setw (6) << arr1[i] << " " << std::setw (6) << arr2[i] << "\n";
	}
	std::cout << "good("<<success<<")"<<"  at: "<<std::setw (3)<<at;

	success = RevertArray_ (arr1, arr2, arrSize);

	std::cout << "\n\n----      arr1    arr2\n";
	for (uint32_t i = 0; i < arrSize; i++) {
		std::string tmp = "#" + std::to_string (i);
		std::cout << std::setw (4) << tmp << "   " << std::setw (6) << arr1[i] << " " << std::setw (6) << arr2[i] << "\n";
	}
	std::cout << "good("<<success<<")";


	return 0;
}