	.code
ClipData struct
	Src				 qword ? ; uint8_t*
	Dest			 qword ? ; uint8_t*
	NumPixels		 qword ? ; uint64_t
	NumClippedPixels qword ? ; uint64_t
	ThreshLow		 byte  ? ; uint8_t
	ThreshHigh       byte  ? ; uint8_t
	; + uint8_t[6] for padding, though unnecessary
ClipData ends
AVX2ClipPixels_ proc ; (ClipData *cd) -> bool
	mov		rdx,qword ptr[rcx+ClipData.NumPixels]
	or		rdx,rdx
	jz		RETURN
	test	rdx,1fh
	jnz		RETURN

	mov		r8,qword ptr[rcx+ClipData.Src] ; src
	test	r8,1fh
	jnz		RETURN
	mov		r9,qword ptr[rcx+ClipData.Dest]; dest
	test	r9,1fh
	jnz		RETURN
	vpbroadcastb ymm4,byte ptr[rcx+ClipData.ThreshLow]
	vpbroadcastb ymm5,byte ptr[rcx+ClipData.ThreshHigh]
	xor		r10,r10

@@:
	vmovdqa	ymm0,ymmword ptr[r8]
	vpmaxub	ymm1,ymm0,ymm4 ; ymm1 = max(ymm0,threshLow)
	vpminub	ymm2,ymm1,ymm5 ; ymm1 = min(ymm1,threshHigh)
	vmovdqa	ymmword ptr[r9],ymm2
	
	vpcmpeqb ymm3,ymm2,ymm0
	vpmovmskb eax,ymm3
	not		eax
	popcnt	eax,eax
	add		r10,rax

	add		r8,32
	add		r9,32
	sub		rdx,32
	jnz		@B

	mov		eax,1
	mov		qword ptr[rcx+ClipData.NumClippedPixels],r10
RETURN:
	ret
AVX2ClipPixels_ endp

_YmmVPEXTRMINUB macro GprDest,YmmSrc,YmmTmp
.erridn	<YmmSrc>,<YmmTmp>,<Invalid registers>
	
	YmmSrcSuffix SUBSTR <YmmSrc>,2
	XmmSrc CATSTR <X>,YmmSrcSuffix

	YmmTmpSuffix SUBSTR <YmmTmp>,2
	XmmTmp CATSTR <X>,YmmTmpSuffix

	vextracti128 XmmTmp,YmmSrc,1
	vpminub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,8
	vpminub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,4
	vpminub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,2
	vpminub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,1
	vpminub	XmmSrc,XmmSrc,XmmTmp

	vpextrb	GprDest,XmmSrc,0
endm
_YmmVPEXTRMAXUB macro GprDest,YmmSrc,YmmTmp
.erridn	<YmmSrc>,<YmmTmp>,<Invalid registers>
	
	YmmSrcSuffix SUBSTR <YmmSrc>,2
	XmmSrc CATSTR <X>,YmmSrcSuffix

	YmmTmpSuffix SUBSTR <YmmTmp>,2
	XmmTmp CATSTR <X>,YmmTmpSuffix

	vextracti128 XmmTmp,YmmSrc,1
	vpmaxub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,8
	vpmaxub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,4
	vpmaxub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,2
	vpmaxub	XmmSrc,XmmSrc,XmmTmp

	vpsrldq	XmmTmp,XmmSrc,1
	vpmaxub	XmmSrc,XmmSrc,XmmTmp

	vpextrb	GprDest,XmmSrc,0
endm
ConstVals segment readonly align(32) 'const'
InitialPminVal	db 32 dup(0ffh)
InitialPmaxVal	db 32 dup(00h)
ConstVals ends
AVX2CalcRGBMinMax_ proc frame ; (uint8_t *rgb[3], size_t num_pixels, uint8_t min_vals[3], uint8_t max_vals[3]) -> bool
	push	rbp
	.pushreg rbp
	push	r12
	.pushreg r12
	sub		rsp,38h ; 30h + 08h-pad
	.allocstack 38h
	lea		rbp,[rsp+30h]
	vmovdqa	xmmword ptr[rbp-30h],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-20h],xmm7
	.savexmm128 xmm7,10h
	vmovdqa	xmmword ptr[rbp-10h],xmm8
	.savexmm128 xmm8,20h
	.endprolog

	test	rdx,rdx
	jz		RETURN
	test	rdx,1fh
	jnz		RETURN
	mov		r10,[rcx]
	test	r10,1fh
	jnz		RETURN
	mov		r11,[rcx+08h]
	test	r11,1fh
	jnz		RETURN
	mov		r12,[rcx+10h]
	test	r12,1fh
	jnz		RETURN

	vmovdqa	ymm3,ymmword ptr[InitialPminVal]
	vmovdqa	ymm4,ymm3
	vmovdqa	ymm5,ymm3
	vmovdqa	ymm6,ymmword ptr[InitialPmaxVal]
	vmovdqa	ymm7,ymm6
	vmovdqa	ymm8,ymm6
	xor		rax,rax
	xor		rcx,rcx

	align 16
@@:
	vmovdqa	ymm0,ymmword ptr[r10+rcx]
	vmovdqa	ymm1,ymmword ptr[r11+rcx]
	vmovdqa	ymm2,ymmword ptr[r12+rcx]

	vpminub	ymm3,ymm3,ymm0
	vpminub	ymm4,ymm4,ymm1
	vpminub	ymm5,ymm5,ymm2

	vpmaxub	ymm6,ymm6,ymm0
	vpmaxub	ymm7,ymm7,ymm1
	vpmaxub	ymm8,ymm8,ymm2

	add		rcx,32
	sub		rdx,32
	jnz		@B

	_YmmVPEXTRMINUB rax,ymm3,ymm0
	mov		byte ptr[r8],al
	_YmmVPEXTRMINUB rax,ymm4,ymm0
	mov		byte ptr[r8+1],al
	_YmmVPEXTRMINUB rax,ymm5,ymm0
	mov		byte ptr[r8+2],al

	_YmmVPEXTRMAXUB rax,ymm6,ymm1
	mov		byte ptr[r9],al
	_YmmVPEXTRMAXUB rax,ymm7,ymm1
	mov		byte ptr[r9+1],al
	_YmmVPEXTRMAXUB rax,ymm8,ymm1
	mov		byte ptr[r9+2],al

	mov		eax,1
RETURN:
	vzeroupper
	vmovdqa	xmm6,xmmword ptr[rbp-30h]
	vmovdqa	xmm7,xmmword ptr[rbp-20h]
	vmovdqa	xmm8,xmmword ptr[rbp-10h]
	lea		rsp,[rbp+08h]
	pop		r12
	pop		rbp
	ret
AVX2CalcRGBMinMax_ endp

	.const
GsMask	dword 0ffffffffh, 0, 0, 0, 0ffffffffh, 0, 0, 0
r4_0_5	real4 0.5	
r4_255	real4 255.0

extern c_NumPixelsMin:DWORD
extern c_NumPixelsMax:DWORD
	.code
AVX2ConvertRGBToGS_ proc frame ; (const RGBA32* pb_rba, uint32_t num_pixels, uint8_t *pb_gs, const float coef[4]) -> bool
_CreateFrame macro
	push	rbp
	.pushreg rbp
	sub		rsp,70h
	.allocstack 70h
	lea		rbp,[rsp+70h]
	vmovdqa	xmmword ptr[rbp-70h],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-60h],xmm7
	.savexmm128 xmm7,10h
	vmovdqa	xmmword ptr[rbp-50h],xmm11
	.savexmm128 xmm11,20h
	vmovdqa	xmmword ptr[rbp-40h],xmm12
	.savexmm128 xmm12,30h
	vmovdqa	xmmword ptr[rbp-30h],xmm13
	.savexmm128 xmm13,40h
	vmovdqa	xmmword ptr[rbp-20h],xmm14
	.savexmm128 xmm14,50h
	vmovdqa	xmmword ptr[rbp-10h],xmm15
	.savexmm128 xmm15,60h
	.endprolog
endm
	_CreateFrame

	xor		eax,eax
	cmp		edx,[c_NumPixelsMax]
	jg		RETURN
	cmp		edx,[c_NumPixelsMin]
	jl		RETURN
	test	edx,07h ; 4channel, 8pixels = 32
	jnz		RETURN

	test	rcx,1fh
	jnz		RETURN
	test	r8,1fh
	jnz		RETURN

	vbroadcastss ymm11, real4 ptr[r4_255]
	vbroadcastss ymm12, real4 ptr[r4_0_5]

	vpxor	ymm13,ymm13,ymm13

	vmovups	xmm0,xmmword ptr[r9]
	vperm2f128 ymm14,ymm0,ymm0,00000000b

	vmovups	ymm15,ymmword ptr[GsMask]

	align 16
@@:
	vmovdqa	ymm0,ymmword ptr[rcx]

	vpunpcklbw ymm1,ymm0,ymm13
	vpunpckhbw ymm2,ymm0,ymm13
	vpunpcklwd ymm3,ymm1,ymm13
	vpunpckhwd ymm4,ymm1,ymm13
	vpunpcklwd ymm5,ymm2,ymm13
	vpunpckhwd ymm6,ymm2,ymm13

	vcvtdq2ps ymm0,ymm3
	vcvtdq2ps ymm1,ymm4
	vcvtdq2ps ymm2,ymm5
	vcvtdq2ps ymm3,ymm6

	vmulps	ymm0,ymm0,ymm14
	vmulps	ymm1,ymm1,ymm14
	vmulps	ymm2,ymm2,ymm14
	vmulps	ymm3,ymm3,ymm14

	vhaddps	ymm4,ymm0,ymm0
	vhaddps	ymm4,ymm4,ymm4
	vhaddps	ymm5,ymm1,ymm1
	vhaddps	ymm5,ymm5,ymm5
	vhaddps	ymm6,ymm2,ymm2
	vhaddps	ymm6,ymm6,ymm6
	vhaddps	ymm7,ymm3,ymm3
	vhaddps	ymm7,ymm7,ymm7

	vandps	ymm4,ymm4,ymm15
	vandps	ymm5,ymm5,ymm15
	vandps	ymm6,ymm6,ymm15
	vandps	ymm7,ymm7,ymm15
	vpslldq	ymm5,ymm5,4
	vpslldq	ymm6,ymm6,8
	vpslldq	ymm7,ymm7,12
	vorps	ymm0,ymm4,ymm5
	vorps	ymm1,ymm6,ymm7
	vorps	ymm2,ymm0,ymm1

	vaddps	ymm2,ymm2,ymm12
	vminps	ymm3,ymm2,ymm11
	vmaxps	ymm4,ymm3,ymm13

	vcvtps2dq ymm3,ymm2
	vpackusdw ymm4,ymm3,ymm13
	vpackuswb ymm5,ymm4,ymm13

	vperm2i128 ymm6,ymm13,ymm5,3

	vmovd	dword ptr[r8],xmm5
	vmovd	dword ptr[r8+4],xmm6
	
	add		rcx,20h
	add		r8,08h
	sub		edx,08h
	jnz		@B

	mov		eax,1
RETURN:
_DeleteFrame macro
	vzeroupper
	vmovdqa	xmm6 ,xmmword ptr[rbp-70h]
	vmovdqa	xmm7 ,xmmword ptr[rbp-60h]
	vmovdqa	xmm11,xmmword ptr[rbp-50h]
	vmovdqa	xmm12,xmmword ptr[rbp-40h]
	vmovdqa	xmm13,xmmword ptr[rbp-30h]
	vmovdqa	xmm14,xmmword ptr[rbp-20h]
	vmovdqa	xmm15,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
endm
	_DeleteFrame
	ret
AVX2ConvertRGBToGS_ endp
	END