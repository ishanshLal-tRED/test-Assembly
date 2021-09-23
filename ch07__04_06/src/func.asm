include <MacrosX86-64-AVX.asmh>
include <cmp_equ.asmh>
	.const
	align 16
QW_MaxVal	qword 0ffffffffffffffffh
			qword 0ffffffffffffffffh
QW_MinVal	qword 00000000000000000h
			qword 00000000000000000h

Uint8ToFloat real4 255.0,255.0,255.0,255.0
FloatToUint8Min real4 0.0,0.0,0.0,0.0
FloatToUint8Max real4 1.0,1.0,1.0,1.0
FloatToUint8Scale real4 255.0,255.0,255.0,255.0
	.code
AVXCalcMinMaxU8_ proc ; (const uint8_t* data, size_t n, uint8_t& x_min, uint8_t& x_max) -> bool
	
	xor		eax,eax
	or		rdx,rdx
	jz		RETURN

	test	rdx,3fh ; is multiple of 64, as loop processes 64 bytes of data in each iteration
	jnz		RETURN

	test	rcx,0fh ; is aligned form of data
	jnz		RETURN

; Initialize
	vmovdqa	xmm2,xmmword ptr[QW_MaxVal]
	vmovdqa	xmm3,xmm2
	
	vmovdqa	xmm4,xmmword ptr[QW_MinVal]
	vmovdqa	xmm5,xmm4

@@:
	vmovdqa	xmm0,xmmword ptr[rcx]         ; xmm0 = x[i+15] : x[i]
	vmovdqa	xmm1,xmmword ptr[rcx+16]      ; xmm0 = x[i+31] : x[i+16]
	
	vpminub	xmm2,xmm0,xmm2
	vpminub	xmm3,xmm1,xmm3
	
	vpmaxub	xmm4,xmm0,xmm4
	vpmaxub	xmm5,xmm1,xmm5

	vmovdqa	xmm0,xmmword ptr[rcx+32]      ; xmm0 = x[i+47] : x[i+32]
	vmovdqa	xmm1,xmmword ptr[rcx+48]      ; xmm0 = x[i+63] : x[i+48]
	
	vpminub	xmm2,xmm0,xmm2
	vpminub	xmm3,xmm1,xmm3
	
	vpmaxub	xmm4,xmm0,xmm4
	vpmaxub	xmm5,xmm1,xmm5

	add		rcx,64
	sub		rdx,64
	jnz		@B

	vpminub	xmm2,xmm2,xmm3
	vpsrldq	xmm0,xmm2,8
	vpminub	xmm2,xmm2,xmm0
	vpsrldq	xmm0,xmm2,4
	vpminub	xmm2,xmm2,xmm0
	vpsrldq	xmm0,xmm2,2
	vpminub	xmm2,xmm2,xmm0
	
	vpmaxub	xmm4,xmm4,xmm5
	vpsrldq	xmm0,xmm4,8 ; shift register by 8 bytes
	vpmaxub	xmm4,xmm4,xmm0
	vpsrldq	xmm0,xmm4,4
	vpmaxub	xmm4,xmm4,xmm0
	vpsrldq	xmm0,xmm4,2
	vpmaxub	xmm4,xmm4,xmm0

	vpextrb	byte ptr[r8],xmm2, 0
	vpextrb	byte ptr[r9],xmm4, 0
	mov		al,1
RETURN:
	ret
AVXCalcMinMaxU8_ endp
AVXCalcMeanU8_ proc frame ; (const uint8_t* data, size_t n, uint64_t& x_sum, double& x_mean) -> bool

NUM_OF_REG_PUSHED = 1 ; rbp
NUM_OF_XMMREG_SAVED = 4
STK_PAD = ((NUM_OF_REG_PUSHED AND 1) XOR 1) * 8
STK_REGS = NUM_OF_REG_PUSHED*8 + STK_PAD
STK_XMMREGS = NUM_OF_XMMREG_SAVED*16

STK_ALLOC_TOTAL = STK_XMMREGS + STK_PAD
_STK_TOTAL = STK_REGS + STK_XMMREGS
STACK_ARGS = STK_REGS + 40

	push        rbp
	.pushreg rbp
	sub         rsp,STK_ALLOC_TOTAL
	lea         rbp,[rsp+STK_XMMREGS]
	vmovdqa     xmmword ptr [rbp-STK_XMMREGS],xmm6  
	.savexmm128 xmm6,0
	vmovdqa     xmmword ptr [rbp-STK_XMMREGS+10h],xmm7  
	.savexmm128 xmm6,10h
	vmovdqa     xmmword ptr [rbp-STK_XMMREGS+20h],xmm8  
	.savexmm128 xmm6,20h
	vmovdqa     xmmword ptr [rbp-STK_XMMREGS+30h],xmm9  
	.savexmm128 xmm6,30h
	.endprolog

	xor		eax,eax
	or		rdx, rdx
	jz		RETURN
	test	rdx, 3fh ; 64 byte chunks are processed
	jnz		RETURN
	test	rcx, 0fh
	jnz		RETURN
; Initializations
	mov		r10,rdx ; for later use
	add		rdx,rcx ; end of array
	vpxor	xmm8,xmm8,xmm8
	vpxor	xmm9,xmm9,xmm9
	
@@:
	vmovdqa	xmm0,xmmword ptr[rcx]	 ; LOAD
	vmovdqa	xmm1,xmmword ptr[rcx+16] ; LOAD
	
	vpunpcklbw xmm2,xmm0,xmm9
	vpunpckhbw xmm3,xmm0,xmm9
	vpunpcklbw xmm4,xmm1,xmm9
	vpunpckhbw xmm5,xmm1,xmm9

	vpaddw	xmm0,xmm2,xmm3
	vpaddw	xmm1,xmm4,xmm5
	vpaddw	xmm6,xmm0,xmm1

	vmovdqa	xmm0,xmmword ptr[rcx+32] ; LOAD
	vmovdqa	xmm1,xmmword ptr[rcx+48] ; LOAD
	
	vpunpcklbw xmm2,xmm0,xmm9
	vpunpckhbw xmm3,xmm0,xmm9
	vpunpcklbw xmm4,xmm1,xmm9
	vpunpckhbw xmm5,xmm1,xmm9

	vpaddw	xmm0,xmm2,xmm3
	vpaddw	xmm1,xmm4,xmm5
	vpaddw	xmm7,xmm0,xmm1

	vpaddw	xmm0,xmm6,xmm7

	vpunpcklwd xmm1,xmm0,xmm9
	vpunpckhwd xmm2,xmm0,xmm9

	vpaddd	xmm8,xmm1,xmm8 ; double words should be enough to hold atleast 2^24 or 4048*4048 uint8_t and there are 4 of them here
	vpaddd	xmm8,xmm2,xmm8
	
	add		rcx,64
	cmp 	rcx,rdx
	jne		@B
	
	vpunpckldq xmm0,xmm8,xmm9
	vpunpckhdq xmm1,xmm8,xmm9
	vpaddq	xmm0,xmm0,xmm1
	vpextrq	rcx,xmm0,0
	vpextrq	rdx,xmm0,1
	add		rcx,rdx
	mov		[r8],rcx

	vcvtsi2sd xmm0,xmm0,rcx
	vcvtsi2sd xmm1,xmm1,r10 ; vcvtusi2sd is avx512 instruction
	vdivsd	xmm0,xmm0,xmm1
	vmovsd	real8 ptr[r9],xmm0
RETURN:
	vmovdqa     xmm6,xmmword ptr [rbp-STK_XMMREGS]  
	vmovdqa     xmm7,xmmword ptr [rbp-STK_XMMREGS+10h]  
	vmovdqa     xmm8,xmmword ptr [rbp-STK_XMMREGS+20h]  
	vmovdqa     xmm9,xmmword ptr [rbp-STK_XMMREGS+30h]
IF (STK_PAD GT 0)
	lea         rsp,[rbp+STK_PAD]
ELSE
	mov         rsp,rbp
ENDIF
	pop         rbp  
	ret
AVXCalcMeanU8_ endp
ConvertImgU8ToF32_ proc frame; (const uint8_t *src, float *des, uint32_t num_pixels);
	_CreateFrame U2F_,0,160
	_SaveXmmRegs xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
	_EndProlog

	xor		eax,eax
	or		r8d,r8d
	jz		RETURN
	test	r8d,1fh
	jnz		RETURN
	test	rcx,0fh
	jnz		RETURN
	test	rdx,0fh
	jnz		RETURN
; Initialize
	shr		r8d,5 ; 32byte chunks
	vmovaps	xmm6,xmmword ptr[Uint8ToFloat]
	vpxor	xmm7,xmm7,xmm7

@@:
	vmovdqa	xmm0,xmmword ptr[rcx]
	vmovdqa	xmm1,xmmword ptr[rcx+16]

	vpunpcklbw xmm2,xmm0,xmm7
	vpunpckhbw xmm3,xmm0,xmm7
	
	vpunpcklwd xmm8,xmm2,xmm7
	vpunpckhwd xmm9,xmm2,xmm7
	vpunpcklwd xmm10,xmm3,xmm7
	vpunpckhwd xmm11,xmm3,xmm7

	vpunpcklbw xmm2,xmm1,xmm7
	vpunpckhbw xmm3,xmm1,xmm7
	
	vpunpcklwd xmm12,xmm2,xmm7
	vpunpckhwd xmm13,xmm2,xmm7
	vpunpcklwd xmm14,xmm3,xmm7
	vpunpckhwd xmm15,xmm3,xmm7

	vcvtdq2ps xmm8,xmm8
	vcvtdq2ps xmm9,xmm9
	vcvtdq2ps xmm10,xmm10
	vcvtdq2ps xmm11,xmm11
	vcvtdq2ps xmm12,xmm12
	vcvtdq2ps xmm13,xmm13
	vcvtdq2ps xmm14,xmm14
	vcvtdq2ps xmm15,xmm15

	vdivps	xmm8 ,xmm8 ,xmm6
	vmovaps	xmmword ptr[rdx],xmm8 
	vdivps	xmm9 ,xmm9 ,xmm6
	vmovaps	xmmword ptr[rdx+16],xmm9 
	vdivps	xmm10,xmm10,xmm6
	vmovaps	xmmword ptr[rdx+32],xmm10
	vdivps	xmm11,xmm11,xmm6
	vmovaps	xmmword ptr[rdx+48],xmm11
	vdivps	xmm12,xmm12,xmm6
	vmovaps	xmmword ptr[rdx+64],xmm12
	vdivps	xmm13,xmm13,xmm6
	vmovaps	xmmword ptr[rdx+80],xmm13
	vdivps	xmm14,xmm14,xmm6
	vmovaps	xmmword ptr[rdx+96],xmm14
	vdivps	xmm15,xmm15,xmm6
	vmovaps	xmmword ptr[rdx+112],xmm15

	add		rcx, 32
	add		rdx, 128
	sub		r8d, 1 ; we could've used DEC too
	jnz		@B
	mov		al,1
RETURN:
	_RestoreXmmRegs xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15
	_DeleteFrame
	ret
ConvertImgU8ToF32_ endp
ConvertImgF32ToU8_ proc frame ; (const float *src, uint8_t *des, uint32_t num_pixels);
	_CreateFrame F2U_,0,96
	_SaveXmmRegs xmm6,xmm7,xmm12,xmm13,xmm14,xmm15
	_EndProlog

	xor		al,al
	or		r8d,r8d
	jz		RETURN
	test	r8d,1fh 
	jnz		RETURN
	test	rcx,0fh 
	jnz		RETURN
	test	rdx,0fh 
	jnz		RETURN

	movaps	xmm13,xmmword ptr[FloatToUint8Scale]
	movaps	xmm14,xmmword ptr[FloatToUint8Min]
	movaps	xmm15,xmmword ptr[FloatToUint8Max]

	shr		r8d,4 ; 16 byte chunks
LP1:
	mov		r9d,4
LP2:
	vmovaps	xmm0,xmmword ptr[rcx]
	vcmpps	xmm1,xmm0,xmm14,CMP_LT
	vandnps	xmm2,xmm1,xmm0

	vcmpps	xmm3,xmm2,xmm15,CMP_GT
	vandps	xmm4,xmm3,xmm15
	vandnps	xmm5,xmm3,xmm2
	vorps	xmm6,xmm5,xmm4
	vmulps	xmm7,xmm6,xmm13

	vcvtps2dq xmm0,xmm7
	vpackusdw xmm1,xmm0,xmm0
	vpackuswb xmm2,xmm1,xmm1

	vpextrd	eax,xmm2,0
	vpsrldq	xmm12,xmm12,4
	vpinsrd	xmm12,xmm12,eax,3

	add		rcx,16
	sub		r9d,1
	jnz		LP2

	vmovdqa	xmmword ptr[rdx],xmm12
	add		rdx,16
	sub		r8d,1
	jnz		LP1

	mov		al,1
RETURN:
	_RestoreXmmRegs xmm6,xmm7,xmm12,xmm13,xmm14,xmm15
	_DeleteFrame
	ret
ConvertImgF32ToU8_ endp
	END