	
	include <cmp_equ.asmh>

MxcsrRcMask  equ 9FFFh ; bit pattern for MXCSR.RC
MxcsrRcShift equ 13    ; shift count for MXCSR.RC

	.const
AbsMaskF32	dword	7fffffffh, 7fffffffh, 7fffffffh, 7fffffffh
AbsMaskF64	qword	7fffffffffffffffh, 7fffffffffffffffh

	.code

AVXPackedAddU16_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
	vmovdqu	xmm0,xmmword ptr[rcx]
	vmovdqu	xmm1,xmmword ptr[rdx]
	
	vpaddw	xmm2,xmm0,xmm1
	vpaddusw xmm3,xmm0,xmm1

	vmovdqu	xmmword ptr[r8],xmm2
	vmovdqu	xmmword ptr[r8+16],xmm3
	ret
AVXPackedAddU16_ endp
AVXPackedSubU16_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
	vmovdqu	xmm0,xmmword ptr[rcx]
	vmovdqu	xmm1,xmmword ptr[rdx]
	
	vpsubw	xmm2,xmm0,xmm1
	vpsubusw xmm3,xmm0,xmm1
	
	vmovdqu	xmmword ptr[r8],xmm2
	vmovdqu	xmmword ptr[r8+16],xmm3
	ret
AVXPackedSubU16_ endp
AVXPackedAddI16_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
	vmovdqa	xmm0,xmmword ptr[rcx]
	vmovdqa	xmm1,xmmword ptr[rdx]
	
	vpaddw	xmm2,xmm0,xmm1
	vpaddsw xmm3,xmm0,xmm1
	
	vmovdqa	xmmword ptr[r8],xmm2
	vmovdqa	xmmword ptr[r8+16],xmm3
	ret
AVXPackedAddI16_ endp
AVXPackedSubI16_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
	vmovdqa	xmm0,xmmword ptr[rcx]
	vmovdqa	xmm1,xmmword ptr[rdx]
	
	vpsubw	xmm2,xmm0,xmm1
	vpsubsw xmm3,xmm0,xmm1
	
	vmovdqa	xmmword ptr[r8],xmm2
	vmovdqa	xmmword ptr[r8+16],xmm3
	ret
AVXPackedSubI16_ endp
AVXPackedMulI16_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
	vmovdqa	xmm0,xmmword ptr[rcx]
	vmovdqa	xmm1,xmmword ptr[rdx]

	vpmullw xmm2,xmm0,xmm1 ;xmm2 = packed a * b low result
	vpmulhw xmm3,xmm0,xmm1 ;xmm3 = packed a * b high result
	
	vpunpcklwd xmm4,xmm2,xmm3 ;merge low and high results
	vpunpckhwd xmm5,xmm2,xmm3 ;into final signed dwords
	
	vmovdqa xmmword ptr[r8],xmm4 ;save final results
	vmovdqa xmmword ptr[r8+16],xmm5
	ret
AVXPackedMulI16_ endp
AVXPackedMulI32A_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
	vmovdqa	xmm0,xmmword ptr[rcx]
	vmovdqa	xmm1,xmmword ptr[rdx]
	vpmuldq xmm2,xmm0,xmm1

; shift source operand right by 4-bytes
	vpsrldq xmm0,xmm0, 4 ; this is different from vpsrld, this shifts in bytes the whole register instead of just elements inside (dq = double-word quad = 128bits)
	vpsrldq xmm1,xmm1, 4 ; this is different from vpsrld, this shifts in bytes the whole register instead of just elements inside
	vpmuldq xmm3,xmm0,xmm1
	
	vpextrq	qword ptr[r8],xmm2,0 ; vector packed extract [byte | word | double-word | quad-word], 1st operand should be memory location or a general purpose location, 3rd is index
	vpextrq	qword ptr[r8+8],xmm3,0
	vpextrq	qword ptr[r8+16],xmm2,1
	vpextrq	qword ptr[r8+24],xmm3,1
	ret
AVXPackedMulI32A_ endp
AVXPackedMulI32B_ proc ; (const XmmVal&, const XmmVal&, XmmVal&)
	vmovdqa	xmm0,xmmword ptr[rcx]
	vpmulld	xmm1,xmm0,xmmword ptr[rdx]
	vmovdqa xmmword ptr[r8],xmm1
	ret
AVXPackedMulI32B_ endp
AVXPackedIntShift_ proc ; (const XmmVal &, const uint32_t count, ShiftOp, XmmVal &) -> bool
	
	movsxd	r8,r8d
	cmp		r8,TotalShiftOps
	jae		ERROR
	
	vmovdqa	xmm0,xmmword ptr[rcx]
	movsx	rdx,dl
	vmovq	xmm1,rdx
	mov		al,1
	jmp		[ShiftOpMap+r8*8]

U16_LL:
	vpsllw	xmm2,xmm0,xmm1
	vmovdqa	xmmword ptr[r9],xmm2
	ret
U16_RL:
	vpsrlw	xmm2,xmm0,xmm1
	vmovdqa	xmmword ptr[r9],xmm2
	ret
U16_RA:
	vpsraw	xmm2,xmm0,xmm1
	vmovdqa	xmmword ptr[r9],xmm2
	ret
U32_LL:
	vpslld	xmm2,xmm0,xmm1
	vmovdqa	xmmword ptr[r9],xmm2
	ret
U32_RL:
	vpsrld	xmm2,xmm0,xmm1
	vmovdqa	xmmword ptr[r9],xmm2
	ret
U32_RA:
	vpsrad	xmm2,xmm0,xmm1
	vmovdqa	xmmword ptr[r9],xmm2
	ret
	align 8
ShiftOpMap equ $
	qword U16_LL
	qword U16_RL
	qword U16_RA
	qword U32_LL
	qword U32_RL
	qword U32_RA
TotalShiftOps equ ($ - ShiftOpMap) / sizeof qword

ERROR:
	xor		al,al
	vpxor	xmm0,xmm0,xmm0
	vmovdqu	xmmword ptr[r9],xmm0 ; unaligned, vmovdqa(aligned) is more efficient but requires data to be alignas(16).
	ret
AVXPackedIntShift_ endp
	END