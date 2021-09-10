import <iostream>;
import testModule;

namespace Extrinsic
{
	void MyClass::Init ()
	{
		std::cout << __FUNCSIG__ << std::endl;
	}
	void MyClass::Run ()
	{
		for (uint32_t i = 0; i <= 5000; i++)
			std::cout << '\r' << __FUNCSIG__ << " #" << i;
		std::cout << std::endl;
	}
	void MyClass::Destroy ()
	{
		std::cout << __FUNCSIG__ <<  std::endl;
	}
};