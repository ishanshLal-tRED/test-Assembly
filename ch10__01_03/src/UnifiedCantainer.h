#pragma once
#include <iostream>
#include <iomanip>
#include <concepts>
#include <random>

// CantainerWidth in bytes {equ 16,32,64}
template<size_t CantainerWidth = 16>
struct Unified
{
public:
	union
	{
		int8_t		i8[CantainerWidth];
		int16_t		i16[CantainerWidth/2];
		int32_t		i32[CantainerWidth/4];
		int64_t		i64[CantainerWidth/8];
		uint8_t		u8[CantainerWidth];
		uint16_t	u16[CantainerWidth/2];
		uint32_t	u32[CantainerWidth/4];
		uint64_t	u64[CantainerWidth/8];
		float		f32[CantainerWidth/4];
		double		f64[CantainerWidth/8];
	};
	template<typename Typ, typename InterpretTyp = Typ> requires std::integral<Typ> || std::floating_point<Typ>
	std::ostream& Print (char addatend = 0, size_t width = 0, size_t precision = 0)
	{
		constexpr size_t offset = sizeof (Typ);
		
		if(width == 0)
			width =
				offset > 7 ? 19 :
				offset > 3 ? 12 :
				offset > 1 ? 7 : 4
			;
		if(precision == 0)
			precision =
				offset > 7 ? 10 :
				offset > 3 ? 5  : 0
			;

		std::cout << std::fixed << std::setprecision (precision);

		for (size_t i = 0; i < CantainerWidth; i += offset)
			std::cout << std::setw (width) << InterpretTyp (*((Typ *)(&u8[i]))) << ' ';

		if (addatend)
			std::cout << addatend;

		return std::cout;
	}
	template<typename Typ> requires std::unsigned_integral<Typ>
	std::ostream &PrintHex (char addatend = 0, size_t width = 0)
	{
		constexpr size_t offset = sizeof (Typ);

		if (width == 0)
			width = offset*2;
		
		std::cout << std::setfill ('0') << std::hex;

		for (size_t i = 0; i < CantainerWidth; i += offset)
			std::cout << '0' << 'x' << std::setw (width) << *((Typ *)(&u8[i])) << ' ';

		if (addatend)
			std::cout << addatend;
		
		std::cout << std::setfill (' ') << std::dec;

		return std::cout;
	}
};

template<typename Typ> requires std::integral<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1, int64_t lower_limit = std::numeric_limits<Typ>::min (), int64_t upper_limit = std::numeric_limits<Typ>::max ())
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ Typ(lower_limit), Typ(upper_limit) };
	default_random_engine rng{ seed };

	for (size_t i = 0; i < in_size; i++)
		in[i] = Typ (ui_dist (rng));
}

template<typename Typ> requires std::floating_point<Typ>
void Init (Typ *in, size_t in_size, uint32_t seed = 1)
{
	using namespace std;
	uniform_int_distribution<> ui_dist{ -2000, 2000 };
	default_random_engine rng { seed };

	for (size_t i = 0; i < in_size; i++) {
		auto tmp = ui_dist (rng);
		auto tmp2 = ui_dist (rng);
		tmp = tmp == 0 ? 1 : tmp;
		in[i] = Typ (ui_dist (rng))/Typ (tmp);
	}
}