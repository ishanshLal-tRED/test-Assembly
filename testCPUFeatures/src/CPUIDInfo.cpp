﻿#include "CPUIDInfo.h"

// CPUIDInfo_.asm
extern "C" void     Xgetbv_ (uint32_t r_ecx, uint32_t *r_eax, uint32_t  *r_edx);
extern "C" uint32_t CPUID_ (uint32_t r_eax, uint32_t  r_ecx, CPUIDRegs *r_out);

void CPUIDInfo::Init (void)
{
	m_MaxEax            = 0;
	m_MaxEaxExt         = 0;
	m_FeatureFlags      = 0;
	m_OSXSave           = false;
	m_OSAVXState        = false;
	m_OSAVX512State     = false;
	m_VendorID[0]       = 0;
	m_ProcessorBrand[0] = 0;
	m_CacheInfo.clear ();
}
void CPUIDInfo::InitProcessorBrand (void)
{
	if (m_MaxEaxExt >= 0x80000004) {
		CPUIDRegs r2, r3, r4;
		char *p = m_ProcessorBrand;

		CPUID_ (0x80000002, 0, &r2);
		CPUID_ (0x80000003, 0, &r3);
		CPUID_ (0x80000004, 0, &r4);

		*(uint32_t *)(p +  0) = r2.EAX;
		*(uint32_t *)(p +  4) = r2.EBX;
		*(uint32_t *)(p +  8) = r2.ECX;
		*(uint32_t *)(p + 12) = r2.EDX;
		*(uint32_t *)(p + 16) = r3.EAX;
		*(uint32_t *)(p + 20) = r3.EBX;
		*(uint32_t *)(p + 24) = r3.ECX;
		*(uint32_t *)(p + 28) = r3.EDX;
		*(uint32_t *)(p + 32) = r4.EAX;
		*(uint32_t *)(p + 36) = r4.EBX;
		*(uint32_t *)(p + 40) = r4.ECX;
		*(uint32_t *)(p + 44) = r4.EDX;

		m_ProcessorBrand[sizeof (m_ProcessorBrand) - 1] = 0;
	} else
		strcpy_s (m_ProcessorBrand, "Unknown");
}
void CPUIDInfo::LoadInfo (void)
{
	LoadInfo0 ();
	LoadInfo1 ();
	LoadInfo2 ();
	LoadInfo3 ();
	LoadInfo4 ();
	LoadInfo5 ();
}
void CPUIDInfo::LoadInfo0 (void)
{
	CPUIDRegs r1;

	// Perform required initializations
	Init ();

	// Get MaxEax and VendorID
	CPUID_ (0, 0, &r1);
	m_MaxEax = r1.EAX;
	*(uint32_t *)(m_VendorID + 0) = r1.EBX;
	*(uint32_t *)(m_VendorID + 4) = r1.EDX;
	*(uint32_t *)(m_VendorID + 8) = r1.ECX;
	m_VendorID[sizeof (m_VendorID) - 1] = '\0';

	// Get MaxEaxExt
	CPUID_ (0x80000000, 0, &r1);
	m_MaxEaxExt = r1.EAX;

	// Initialize processor brand string
	InitProcessorBrand ();
}
void CPUIDInfo::LoadInfo1 (void)
{
	CPUIDRegs r;

	if (m_MaxEax < 1)
		return;

	CPUID_ (1, 0, &r);

	// Decode r.ECX flags
	// CPUID.(EAX = 01H, ECX = 00H) : ECX.SSE3[bit 0]
	if (r.ECX & (0x01 << 0))
		m_FeatureFlags |= uint64_t (FF::SSE3);

	// CPUID.(EAX = 01H, ECX = 00H) : ECX.PCLMULDQ[bit 1]
	if (r.ECX & (0x01 << 1))
		m_FeatureFlags |= uint64_t (FF::PCLMULQDQ);

	// CPUID.(EAX = 01H, ECX = 00H) : ECX.SSSE3[bit 9]
	if (r.ECX & (0x01 << 9))
		m_FeatureFlags |= uint64_t (FF::SSSE3);

	// CPUID.(EAX = 01H, ECX = 00H) : ECX.SSE4.1[bit 19]
	if (r.ECX & (0x01 << 19))
		m_FeatureFlags |= uint64_t (FF::SSE4_1);

	// CPUID.(EAX = 01H, ECX = 00H) : ECX.SSE4.2[bit 20]
	if (r.ECX & (0x01 << 20))
		m_FeatureFlags |= uint64_t (FF::SSE4_2);

	// CPUID.(EAX = 01H, ECX = 00H) : ECX.MOVBE[bit 22]
	if (r.ECX & (0x01 << 22))
		m_FeatureFlags |= uint64_t (FF::MOVBE);

	// CPUID.(EAX = 01H, ECX = 00H) : ECX.POPCNT[bit 23]
	if (r.ECX & (0x01 << 23))
		m_FeatureFlags |= uint64_t (FF::POPCNT);
	
	// CPUID.(EAX = 01H, ECX = 00H) : ECX.RDRAND[bit 30]
	if (r.ECX & (0x01 << 30))
		m_FeatureFlags |= uint64_t (FF::RDRAND);

	// Decode r.EDX flags
	// CPUID.(EAX = 01H, ECX = 00H) : EDX.MMX[bit 23]
	if (r.EDX & (0x01 << 23))
		m_FeatureFlags |= uint64_t (FF::MMX);

	// CPUID.(EAX = 01H, ECX = 00H) : EDX.FXSR[bit 24]
	if (r.EDX & (0x01 << 24))
		m_FeatureFlags |= uint64_t (FF::FXSR);

	// CPUID.(EAX = 01H, ECX = 00H) : EDX.SSE[bit 25]
	if (r.EDX & (0x01 << 25))
		m_FeatureFlags |= uint64_t(FF::SSE);

	// CPUID.(EAX = 01H, ECX = 00H) : EDX.SSE[bit 26]
	if (r.EDX & (0x01 << 26))
		m_FeatureFlags |= uint64_t(FF::SSE2);
}
void CPUIDInfo::LoadInfo2 (void)
{
	CPUIDRegs r;
	if (m_MaxEax < 7)
		return;

	CPUID_ (7, 0, &r);

	// CPUID.(EAX = 07h, ECX = 00H) : ECX.PREFETCHWT1[bit 0]
	if (r.ECX & (0x01 << 0))
		m_FeatureFlags |= uint64_t (FF::PREFETCHWT1);

	// CPUID.(EAX = 07h, ECX = 00H) : EBX.BMI1[bit 0]
	if(r.EBX & (0x01 << 3))
		m_FeatureFlags |= uint64_t(FF::BMI1);

	// CPUID.(EAX = 07h, ECX = 00H) : EBX.BMI2[bit 8]
	if(r.EBX & (0x01 << 8))
		m_FeatureFlags |= uint64_t(FF::BMI2);

	// CPUID.(EAX = 07h, ECX = 00H) : EBX.ERMSB[bit 9] // Enhanced REP MOVSB/STOSB
	if(r.EBX & (0x01 << 9))
		m_FeatureFlags |= uint64_t(FF::ERMSB);

	// CPUID.(EAX = 07h, ECX = 00H) : EBX.RDSEED[bit 18]
	if(r.EBX & (0x01 << 18))
		m_FeatureFlags |= uint64_t(FF::RDSEED);

	// CPUID.(EAX = 07h, ECX = 00H) : EBX.ADX[bit 19]
	if(r.EBX & (0x01 << 19))
		m_FeatureFlags |= uint64_t(FF::ADX);

	// CPUID.(EAX = 07h, ECX = 00H) : EBX.CLWB[bit 24]
	if(r.EBX & (0x01 << 24))
		m_FeatureFlags |= uint64_t(FF::CLWB);
}
void CPUIDInfo::LoadInfo3 (void)
{
	CPUIDRegs r;

	if (m_MaxEaxExt < 0x80000001)
		return;

	CPUID_ (0x80000001, 0, &r);

	// CPUID.(EAX = 80000001H, ECX = 00H) : ECX.LZCNT[bit 5]
	if (r.ECX & (0x01 << 5))
		m_FeatureFlags |= uint64_t (FF::LZCNT);
	
	// CPUID.(EAX = 80000001H, ECX = 00H) : ECX.PREFETCHW[bit 8]
	if (r.ECX & (0x01 << 8))
		m_FeatureFlags |= uint64_t (FF::PREFETCHW);
}
void CPUIDInfo::LoadInfo4 (void)
{
	CPUIDRegs r_eax01h;
	CPUIDRegs r_eax07h;

	if (m_MaxEax < 7)
		return;

	CPUID_ (1, 0, &r_eax01h);
	CPUID_ (7, 0, &r_eax07h);

	// Test CPUID.(EAX = 01H, ECX = 00H) : ECX.OSXSAVE[bit 27] // to verify the use of XGETBV
	m_OSXSave = (r_eax01h.ECX & (0x01 << 27)) ? true : false;

	if (m_OSXSave) {
		// Use XGETBV to obtain following information
		// AVX state is enabled by OS if (XCRO[2:1] == '11b') is true
		// AVX512 state is enabled by OS if (XCRO[7:5] == '111b') is true

		uint32_t xgetbv_eax, xgetbv_edx;

		Xgetbv_ (0, &xgetbv_eax, &xgetbv_edx);
		m_OSAVXState = (((xgetbv_eax >> 1) & 0x03) == 0x03) ? true : false;

		if (m_OSAVXState) {
			// CPUID.(EAX = 01H, ECX = 00H) : ECX.AVX[bit 28]
			if (r_eax01h.ECX & (0x01 << 28)) 
			{
				m_FeatureFlags |= uint64_t (FF::AVX);

				// CPUID.(EAX = 01H, ECX = 00H) : ECX.FMA[bit 12]
				if (r_eax01h.ECX & (0x01 << 12))
					m_FeatureFlags |= uint64_t (FF::FMA);

				// CPUID.(EAX = 01H, ECX = 00H) : ECX.F16C[bit 29]
				if (r_eax01h.ECX & (0x01 << 29))
					m_FeatureFlags |= uint64_t (FF::F16C);

				// CPUID.(EAX = 01H, ECX = 00H) : EBX.AVX2[bit 5]
				if (r_eax07h.EBX & (0x01 << 5))
					m_FeatureFlags |= uint64_t (FF::AVX2);
				
				m_OSAVX512State = (((xgetbv_eax >> 5) & 0x07) == 0x03) ? true : false;
				
				if (m_OSAVX512State) 
				{
					// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512F[bit 16]
					if (r_eax07h.EBX & (0x01 << 16)) {
						m_FeatureFlags |= uint64_t (FF::AVX512F);

						// Decode EBX flags
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512DQ[bit 17]
						if (r_eax07h.EBX & (0x01 << 17))
							m_FeatureFlags |= uint64_t (FF::AVX512DQ);
						
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512_IFMA[bit 21]
						if (r_eax07h.EBX & (0x01 << 21))
							m_FeatureFlags |= uint64_t (FF::AVX512_IFMA);
						
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512PF[bit 26]
						if (r_eax07h.EBX & (0x01 << 26))
							m_FeatureFlags |= uint64_t (FF::AVX512PF);
						
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512DER[bit 27]
						if (r_eax07h.EBX & (0x01 << 27))
							m_FeatureFlags |= uint64_t (FF::AVX512PF);
						
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512ER[bit 28]
						if (r_eax07h.EBX & (0x01 << 28))
							m_FeatureFlags |= uint64_t (FF::AVX512ER);
						
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512ER[bit 30]
						if (r_eax07h.EBX & (0x01 << 30))
							m_FeatureFlags |= uint64_t (FF::AVX512ER);
						
						// CPUID.(EAX = 07H, ECX = 00H) : EBX.AVX512ER[bit 31]
						if (r_eax07h.EBX & (0x01 << 31))
							m_FeatureFlags |= uint64_t (FF::AVX512ER);

						// Decode ECX flags
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_VBMI[bit 1]
						if (r_eax07h.ECX & (0x01 << 1))
							m_FeatureFlags |= uint64_t (FF::AVX512_VBMI);
						
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_VBMI2[bit 6]
						if (r_eax07h.ECX & (0x01 << 6))
							m_FeatureFlags |= uint64_t (FF::AVX512_VBMI2);
						
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_VNNI[bit 11]
						if (r_eax07h.ECX & (0x01 << 11))
							m_FeatureFlags |= uint64_t (FF::AVX512_VNNI);
						
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_BITALG[bit 12]
						if (r_eax07h.ECX & (0x01 << 12))
							m_FeatureFlags |= uint64_t (FF::AVX512_BITALG);
						
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_VPOPCNTDQ[bit 14]
						if (r_eax07h.ECX & (0x01 << 14))
							m_FeatureFlags |= uint64_t (FF::AVX512_VPOPCNTDQ);

						// Decode EDX flags
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_4FMAPS[bit 2]
						if (r_eax07h.EDX & (0x01 << 2))
							m_FeatureFlags |= uint64_t (FF::AVX512_4FMAPS);
						
						// CPUID.(EAX = 07H, ECX = 00H) : ECX.AVX512_4VNNIW[bit 3]
						if (r_eax07h.EDX & (0x01 << 3))
							m_FeatureFlags |= uint64_t (FF::AVX512_4VNNIW);

					}
				}
			}
		}
	}
}
void CPUIDInfo::LoadInfo5 (void)
{
	if (m_MaxEax < 4)
		return;

	bool done = false;
	uint32_t idx = 0;

	while (!done) {
		CPUIDRegs r;

		CPUID_ (4, idx, &r);

		uint32_t cache_type  = r.EAX & 0x01f;
		uint32_t cache_level = ((r.EAX >> 5) & 0x03);

		if (cache_type == 0)
			done = true;
		else {
			uint32_t ways = ((r.EBX >> 22) & 0x03ff) + 1;
			uint32_t partitions = ((r.EBX >> 12) & 0x03ff) + 1;
			uint32_t line_size = (r.EBX & 0xfff) + 1;
			uint32_t sets = r.ECX + 1;
			uint32_t cache_size = ways * partitions * line_size * sets;

			CacheInfo ci (cache_level, cache_type, cache_size);
			m_CacheInfo.push_back (ci);
			idx++;
		}
	}
}