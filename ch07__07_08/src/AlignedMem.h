#pragma once
#include <malloc.h>
#include <stdexcept>

class AlignedMem
{
public:
	static void *Allocate (size_t mem_size, size_t mem_Alignment)
	{
		void *p = _aligned_malloc (mem_size, mem_Alignment);

		if (p==nullptr)
			throw std::runtime_error ("Memory allocation error: __FUNCSIG__");
		return p;
	}
	static void Release (void *p)
	{
		_aligned_free (p);
	}

	template<typename Typ>
	static bool IsAligned (const Typ *ptr, size_t alignment)
	{
		bool return_me = 
			(ptr == nullptr) ? false : 
			((uintptr_t (ptr) % alignment) == 0);
		
		return return_me;
	}
	template <typename Typ> 
	class AlignedArray
	{
	public:
		AlignedArray (void) = delete;
		AlignedArray (const AlignedArray &) = delete;
		AlignedArray (AlignedArray &&) = delete;
		AlignedArray &operator=(const AlignedArray &) = delete;
		AlignedArray &operator=(AlignedArray &&) = delete;

		AlignedArray (size_t size, size_t alignment)
		{
			m_Size = size;
			m_Ptr = (Typ *)(Allocate (size*sizeof (Typ), alignment));
		}
		~AlignedArray ()
		{
			Release (m_Ptr);
			m_Size = 0;
		}

		Typ *Data (void) { return m_Ptr; }
		size_t Size (void) { return m_Size; }
		void Fill (Typ data)
		{
			memset (m_Ptr, data, m_Size*sizeof (Typ));
		}
		Typ operator[](size_t at)
		{
			return *(m_Ptr + at);
		}
	private:
		Typ *m_Ptr;
		size_t m_Size;
	};
};