#include "../StatLib/src/Header_1.h"
import testModule;

int main ()
{
	Extrinsic::MyClass aclass;
	aclass.Init ();
	aclass.Run ();
	aclass.Destroy ();

	PrintHelloProject ();
}