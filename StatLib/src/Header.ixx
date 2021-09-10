module;
#include <iostream>
export module testModule;

namespace Extrinsic
{
	export class MyClass;
	
	class MyClass
	{
	public:
		MyClass ()
		{
			std::cout << __FUNCSIG__ << std::endl;
		}
		~MyClass ()
		{
			std::cout << __FUNCSIG__ << std::endl;
		}
		void Init ();
		void Run ();
		void Destroy ();
	protected:
	private:
	};
};