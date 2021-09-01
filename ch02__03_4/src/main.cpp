#include <iostream>
#include <bitset>

// using uint8_t as bool to gaurentee its 1 byte
extern "C" uint8_t IntegerLeftRightShift_(int, uint32_t, int*, int*);
extern "C" void IntegerLeftRightShift2_(int, uint32_t, int*, int*, uint8_t*); // 5th param
extern "C" int64_t Add8Elements_(int a, uint32_t b, int8_t c, uint16_t d, uint32_t e, int8_t f, uint16_t g, int8_t h); // 5th param

int main ()
{
	int a, b, r1, r2;
	bool sucess = false;

	bool *ptr = &sucess;

	a = 9, b = 32, r1 = 0, r2 = 0;
	sucess = bool(IntegerLeftRightShift_(a, b, &r1, &r2));
	std::cout << "a: " << std::bitset<32>(a) << ", b: " << b << " , (a << b): "<< std::bitset<32> (r1) << " , (a >> b): "<< std::bitset<32> (r2) << " good(" << sucess << ")" << std::endl;

	a = 8038094, b = 9, r1 = 0, r2 = 0, sucess = false;
	sucess = bool(IntegerLeftRightShift_(a, b, &r1, &r2));
	std::cout << "a: " << std::bitset<32>(a) << ", b: " << b << " , (a << b): "<< std::bitset<32> (r1) << " , (a >> b): "<< std::bitset<32> (r2) << " good(" << sucess << ")" << std::endl;

	a = 9, b = 32, r1 = 0, r2 = 0, sucess = false;
	IntegerLeftRightShift2_(a, b, &r1, &r2, (uint8_t*)(&sucess));
	std::cout << "a: " << std::bitset<32>(a) << ", b: " << b << " , (a << b): "<< std::bitset<32> (r1) << " , (a >> b): "<< std::bitset<32> (r2) << " good(" << sucess << ")" << std::endl;

	a = 8038094, b = 9, r1 = 0, r2 = 0, sucess = false;
	IntegerLeftRightShift2_(a, b, &r1, &r2, (uint8_t *)(&sucess));
	std::cout << "a: " << std::bitset<32>(a) << ", b: " << b << " , (a << b): "<< std::bitset<32> (r1) << " , (a >> b): "<< std::bitset<32> (r2) << " good(" << sucess << ")" << std::endl;
	
	std::cout << "result: " << Add8Elements_ (-32, 32, -125, 43, 22, -81, 64, -13);
	return 0;
}