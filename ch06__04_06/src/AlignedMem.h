#pragma once
//AlignedMem::IsAligned(float*, 16)

class AlignedMem
{
public:
	template<typename Typ>
	static bool IsAligned (const Typ *ptr, size_t alignment)
	{
		bool return_me = 
			(ptr == nullptr) ? false : 
			((uintptr_t (ptr) % alignment) == 0);
		
		return return_me;
	}
protected:
private:
};