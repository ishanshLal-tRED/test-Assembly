#include <iostream>

extern "C" int Add_ (int a, int b); // use c style naming for function declaration, as cpp style adds decoration to it (C jindabad)
extern "C" int Sub_ (int a, int b);
extern "C" int Mul_ (int a, int b);
extern "C" int Div_ (int a, int b);

int main ()
{
	int a, b, result;
	a = 9, b = 6;

	result = Add_ (a, b);
	std::cout << "a: " << a << ", b: " << b << " , (a + b): "<< result << std::endl;
	result = Sub_ (a, b);
	std::cout << "a: " << a << ", b: " << b << " , (a - b): "<< result << std::endl;
	result = Mul_ (a, b);
	std::cout << "a: " << a << ", b: " << b << " , (a * b): "<< result << std::endl;
	result = Div_ (a, b);
	std::cout << "a: " << a << ", b: " << b << " , (a / b): "<< result << std::endl;

	return 0;
}