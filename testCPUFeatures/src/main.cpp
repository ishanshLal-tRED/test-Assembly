#include <iostream>
#include "CPUIDInfo.h"
#include <iomanip>

static void DisplayCacheInfo    (CPUIDInfo &ci);
static void DisplayFeatureFlags (CPUIDInfo &ci);

int main ()
{
	CPUIDInfo ci;
	ci.LoadInfo ();
	std::cout << "Vendor: " << ci.GetVendorID () << '\n';
	std::cout << "CPU_Brand: " << ci.GetProcessorBrand () << '\n';

	DisplayCacheInfo (ci);
	DisplayFeatureFlags (ci);
	return 0;
}

void DisplayFeatureFlags (CPUIDInfo &ci)
{
	std::cout << "------ CPUID Feature Flags ------\n"
		<< "ADX         :" << ci.GetFlag (CPUIDInfo::FF::ADX) << '\n'
		<< "AVX         :" << ci.GetFlag (CPUIDInfo::FF::AVX) << '\n'
		<< "AVX2        :" << ci.GetFlag (CPUIDInfo::FF::AVX2) << '\n'
		<< "AVX512F     :" << ci.GetFlag (CPUIDInfo::FF::AVX512F) << '\n'
		<< "AVX512BW    :" << ci.GetFlag (CPUIDInfo::FF::AVX512BW) << '\n'
		<< "AVX512CD    :" << ci.GetFlag (CPUIDInfo::FF::AVX512CD) << '\n'
		<< "AVX512DQ    :" << ci.GetFlag (CPUIDInfo::FF::AVX512DQ) << '\n'
		<< "AVX512ER    :" << ci.GetFlag (CPUIDInfo::FF::AVX512ER) << '\n'
		<< "AVX512PF    :" << ci.GetFlag (CPUIDInfo::FF::AVX512PF) << '\n'
		<< "AVX512VL    :" << ci.GetFlag (CPUIDInfo::FF::AVX512VL) << '\n'
		<< "AVX512_IFMA :" << ci.GetFlag (CPUIDInfo::FF::AVX512_IFMA) << '\n'
		<< "AVX512_VBMI :" << ci.GetFlag (CPUIDInfo::FF::AVX512_VBMI) << '\n'
		<< "BMI1        :" << ci.GetFlag (CPUIDInfo::FF::BMI1) << '\n'
		<< "BMI2        :" << ci.GetFlag (CPUIDInfo::FF::BMI2) << '\n'
		<< "F16C        :" << ci.GetFlag (CPUIDInfo::FF::F16C) << '\n'
		<< "FMA         :" << ci.GetFlag (CPUIDInfo::FF::FMA) << '\n'
		<< "LZCNT       :" << ci.GetFlag (CPUIDInfo::FF::LZCNT) << '\n'
		<< "POPCNT      :" << ci.GetFlag (CPUIDInfo::FF::POPCNT) << '\n';
}
void DisplayCacheInfo    (CPUIDInfo &ci)
{
	auto &cache_info = ci.GetCacheInfo ();
	for (const CPUIDInfo::CacheInfo &val : cache_info) {
		uint32_t cache_size = val.GetSize ();
		std::string cache_size_str;

		if (cache_size < 1024*1024) {
			cache_size /= 1024;
			cache_size_str = "KB";
		} else {
			cache_size /= 1024*1024;
			cache_size_str = "MB";
		}

		std::cout << "Cache L" << val.GetLevel () << ": " << cache_size << cache_size_str << ' ' << val.GetTypeString () << '\n';
	}
}