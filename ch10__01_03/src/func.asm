	.code
AVX2PackedMathI16_ proc ; (const Unified<cnt_wid>&a, const Unified<cnt_wid>&b, Unified<cnt_wid> *c) -> bool
; Load
	vmovdqa	ymm0,ymmword ptr[rcx]
	vmovdqa	ymm1,ymmword ptr[rdx]
; Packed Sp floating-point values
; Addition
	vpaddw	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8],ymm2
; Saturated addition
	vpaddsw	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+32],ymm2
; Subtraction
	vpsubw	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+64],ymm2
; Saturated subtraction
	vpsubsw	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+96],ymm2
; min
	vpminsw	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+128],ymm2
; max
	vpmaxsw	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+160],ymm2

	vzeroupper
	mov		al,1
	ret	
AVX2PackedMathI16_ endp
AVX2PackedMathI32_ proc ; (const Unified<cnt_wid>&a, const Unified<cnt_wid>&b, Unified<cnt_wid> *c) -> bool
; Load
	vmovdqa	ymm0,ymmword ptr[rcx]
	vmovdqa	ymm1,ymmword ptr[rdx]
; Packed Sp floating-point values
; Addition
	vpaddd	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8],ymm2
; Subtraction
	vpsubd	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+32],ymm2
; signed mul (low 32 bit)
	vpmulld	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+64],ymm2
; shift left logical
	vpsllvd	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+96],ymm2
; shift right arithemetic
	vpsravd	ymm2,ymm0,ymm1
	vmovdqa	ymmword ptr[r8+128],ymm2
; absolute
	vpabsd	ymm2,ymm0
	vmovdqa	ymmword ptr[r8+160],ymm2
	
	vzeroupper
	mov		al,1
	ret	
AVX2PackedMathI32_ endp


AVX2UnpackU32_U64_ proc ; YmmVal2 <- (const Unified<cnt_wid>& a, const Unified<cnt_wid>& b)
						;     [rcx]                       rdx  ,                     r8
	vmovdqa	ymm0,ymmword ptr[rdx]
	vmovdqa	ymm1,ymmword ptr[r8]

	vpunpckldq ymm2,ymm0,ymm1 ; inter-leave low-order doubleword quad (i.e 1st half in doublword quad chunks i.e 128bit parts, see result) 
	vpunpckhdq ymm3,ymm0,ymm1 ; inter-leave high-order doubleword (2nd half in 128bit parts) 

	test	rcx,1fh
	jnz		Unaligned
	vmovdqa	ymmword ptr[rcx], ymm2
	vmovdqa	ymmword ptr[rcx+20h], ymm3
	jmp		RETURN
Unaligned:
	vmovdqu	ymmword ptr[rcx], ymm2
	vmovdqu	ymmword ptr[rcx+20h], ymm3
RETURN:
	vzeroupper
	mov		rax,rcx
	ret
AVX2UnpackU32_U64_ endp
AVX2PackI32_I16_ proc ; (const Unified<cnt_wid>& a, const Unified<cnt_wid>& b, Unified<cnt_wid> *b)
	vmovdqa	ymm0,ymmword ptr[rcx]
	vmovdqa	ymm1,ymmword ptr[rdx]

	vpackssdw ymm2,ymm0,ymm1 ; this instruction also processes in xmmwords, packing 1st 4 signed dwords to words ymm0[127:0] followed by ymm1[127:0] then next 4 dwords of ymm0[255:128] then ymm1[255:128]

	test	r8,1fh
	jnz		Unaligned
	vmovdqa	ymmword ptr[r8],ymm2
	jmp		RETURN
Unaligned:
	vmovdqu	ymmword ptr[r8],ymm2
RETURN:
	vzeroupper
	ret
AVX2PackI32_I16_ endp

AVX2ZeroExtU8_U16_ proc ; (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[2])
	vpmovzxbw ymm0,xmmword ptr[rcx]
	vpmovzxbw ymm1,xmmword ptr[rcx+10h]

	vmovdqa	ymmword ptr[rdx],ymm0
	vmovdqa	ymmword ptr[rdx+20h],ymm1
	ret
AVX2ZeroExtU8_U16_ endp
AVX2ZeroExtU8_U32_ proc ; (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[4])
	vpmovzxbd ymm0,qword ptr[rcx]
	vpmovzxbd ymm1,qword ptr[rcx+08h]
	vpmovzxbd ymm2,qword ptr[rcx+10h]
	vpmovzxbd ymm3,qword ptr[rcx+18h]

	vmovdqa	ymmword ptr[rdx],ymm0
	vmovdqa	ymmword ptr[rdx+20h],ymm1
	vmovdqa	ymmword ptr[rdx+40h],ymm2
	vmovdqa	ymmword ptr[rdx+60h],ymm3
	ret
AVX2ZeroExtU8_U32_ endp
AVX2SignExtI16_I32_ proc ; (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[2])
	vpmovsxwd ymm0,xmmword ptr[rcx]
	vpmovsxwd ymm1,xmmword ptr[rcx+10h]
	
	vmovdqa	ymmword ptr[rdx],ymm0
	vmovdqa	ymmword ptr[rdx+20h],ymm1
	ret
AVX2SignExtI16_I32_ endp
AVX2SignExtI16_I64_ proc ; (const Unified<cnt_wid> &src, Unified<cnt_wid> dest[4])
	vpmovsxwq ymm0,qword ptr[rcx]
	vpmovsxwq ymm1,qword ptr[rcx+08h]
	vpmovsxwq ymm2,qword ptr[rcx+10h]
	vpmovsxwq ymm3,qword ptr[rcx+18h]
	
	vmovdqa	ymmword ptr[rdx],ymm0
	vmovdqa	ymmword ptr[rdx+20h],ymm1
	vmovdqa	ymmword ptr[rdx+40h],ymm2
	vmovdqa	ymmword ptr[rdx+60h],ymm3
	ret
AVX2SignExtI16_I64_ endp
	END