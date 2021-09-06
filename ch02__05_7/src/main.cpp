#include <iostream>
#include <bitset>

// using uint8_t as bool to gaurentee its 1 byte
extern "C" bool FibLookup_ (int index, int *val1, int *val2, int *val3, int *val4);
extern "C" int FibTableSize_;
extern "C" int FibValsSum_;

extern "C" int Max_ (int a, int b, int c);
extern "C" int Min_ (int a, int b, int c);

extern "C" int MaxT_ (int a, int b, int c);
extern "C" int MinT_ (int a, int b, int c);

int main ()
{
	int val1 = 0, val2 = 0, val3 = 0, val4 = 0;

	for (int32_t i = -2; i < FibTableSize_ + 2; i++)
	{
		bool sucess = FibLookup_ (i, &val1, &val2, &val3, &val4);
		std::cout << "idx: " << i << "  good(" << sucess << ")  val1: " << val1 << " val2: " << val2 << " val3: " << val3 << " val4: " << val4 << std::endl;
		val1 = 0, val2 = 0, val3 = 0, val4 = 0;
	}
	std::cout << "-----Sum: " << FibValsSum_ << std::endl << std::endl;

	std::cout << "Max ( "<<10<<", "<<20<<", "<<30<<") -> "<<Max_ (10, 20, 30)<<std::endl;
	std::cout << "MaxT( "<<10<<", "<<20<<", "<<30<<") -> "<<MaxT_ (10, 20, 30)<<std::endl;

	std::cout << "Min ( "<<10<<", "<<20<<", "<<30<<") -> "<<Min_ (10, 20, 30)<<std::endl;
	std::cout << "MinT( "<<10<<", "<<20<<", "<<30<<") -> "<<MinT_ (10, 20, 30)<<std::endl;
	return 0;
}