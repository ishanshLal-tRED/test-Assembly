#pragma once
#include <string>
#include <vector>

struct CPUIDRegs
{
	uint32_t EAX;
	uint32_t EBX;
	uint32_t ECX;
	uint32_t EDX;
};

class CPUIDInfo
{
public:
	class CacheInfo
	{
	public:
		enum class Type
			: uint32_t
		{
			Unknown = 0,
			Data,
			Instruction,
			Unified,

			_TOTAL_TYPES
		};

	public:
		CacheInfo (uint32_t level, uint32_t type, uint32_t size)
			: m_Level(level), m_Type(Type(type)), m_Size(size)
		{}
		std::string GetTypeString (void) const
		{
			const char *type_to_cstring[uint32_t (Type::_TOTAL_TYPES)] = { "Unknown", "Data", "Instruction", "Unified" };
			return std::string (type_to_cstring[uint32_t(m_Type)]);
		}

		uint32_t GetLevel (void) const { return m_Level; }
		uint32_t GetSize  (void) const { return m_Size;  }
		Type     GetType  (void) const { return m_Type;  }

	private: 
		uint32_t m_Level = 0;
		Type     m_Type  = Type::Unknown;
		uint32_t m_Size  = 0;
	};

public:
	enum class FF // Feature flag
		: uint64_t
	{
		FXSR                    = uint64_t (1) <<  0,
		MMX                     = uint64_t (1) <<  1,
		MOVBE                   = uint64_t (1) <<  2,
		SSE                     = uint64_t (1) <<  3,
		SSE2                    = uint64_t (1) <<  4,
		SSE3                    = uint64_t (1) <<  5,
		SSSE3                   = uint64_t (1) <<  6,
		SSE4_1                  = uint64_t (1) <<  7,
		SSE4_2                  = uint64_t (1) <<  8,
		PCLMULQDQ               = uint64_t (1) <<  9,
		POPCNT                  = uint64_t (1) << 10,
		PREFETCHW               = uint64_t (1) << 11,
		PREFETCHWT1             = uint64_t (1) << 12,
		RDRAND                  = uint64_t (1) << 13,
		RDSEED                  = uint64_t (1) << 14,
		ERMSB                   = uint64_t (1) << 15,
		AVX                     = uint64_t (1) << 16,
		AVX2                    = uint64_t (1) << 17,
		F16C                    = uint64_t (1) << 18,
		FMA                     = uint64_t (1) << 19,
		BMI1                    = uint64_t (1) << 20,
		BMI2                    = uint64_t (1) << 21,
		LZCNT                   = uint64_t (1) << 22,
		ADX                     = uint64_t (1) << 23,
		AVX512F                 = uint64_t (1) << 24,
		AVX512ER                = uint64_t (1) << 25,
		AVX512PF                = uint64_t (1) << 26,
		AVX512DQ                = uint64_t (1) << 27,
		AVX512CD                = uint64_t (1) << 28,
		AVX512BW                = uint64_t (1) << 29,
		AVX512VL                = uint64_t (1) << 30,
		AVX512_IFMA             = uint64_t (1) << 31,
		AVX512_VBMI             = uint64_t (1) << 32,
		AVX512_4FMAPS           = uint64_t (1) << 33,
		AVX512_4VNNIW           = uint64_t (1) << 34,
		AVX512_VPOPCNTDQ        = uint64_t (1) << 35,
		AVX512_VNNI             = uint64_t (1) << 36,
		AVX512_VBMI2            = uint64_t (1) << 37,
		AVX512_BITALG           = uint64_t (1) << 38,
		CLWB                    = uint64_t (1) << 39
	};
	CPUIDInfo (void)
	{
		Init ();
	}
	~CPUIDInfo (void) = default;

	const std::vector<CacheInfo> &GetCacheInfo (void) const
	{
		return m_CacheInfo;
	}
	bool GetFlag (FF feature_flag) const
	{
		return ((m_FeatureFlags & uint64_t (feature_flag)) != 0 ? true : false);
	}
	std::string GetProcessorBrand (void) const
	{
		return std::string (m_ProcessorBrand);
	}
	std::string GetVendorID (void) const
	{
		return std::string (m_VendorID);
	}

	void LoadInfo (void);
private:
	void Init (void);
	void InitProcessorBrand (void);
	void LoadInfo0 (void);
	void LoadInfo1 (void);
	void LoadInfo2 (void);
	void LoadInfo3 (void);
	void LoadInfo4 (void);
	void LoadInfo5 (void);
private: 
	uint32_t m_MaxEax;
	uint32_t m_MaxEaxExt;
	uint32_t m_FeatureFlags;
	std::vector<CacheInfo> m_CacheInfo;
	char m_VendorID[13];
	char m_ProcessorBrand[49];
	bool m_OSXSave;
	bool m_OSAVXState;
	bool m_OSAVX512State;
};