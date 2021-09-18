include <MacrosX86-64-AVX.asmh>


_Mat4x4TransposeF32Macro macro
	vunpcklps xmm6,xmm0,xmm1 ; Unpack and Interleave Low Packed Single-Precision Floating-Point Values
	; (Interleave = Ek chhodd kar)
	vunpckhps xmm0,xmm0,xmm1 ; Unpack and Interleave High Packed Single-Precision Floating-Point Values
	vunpcklps xmm7,xmm2,xmm3
	vunpckhps xmm1,xmm2,xmm3

	vmovlhps xmm4,xmm6,xmm7 ; Move Packed Single-Precision Floating-Point Values Low to High
	; 3rd operands lower half is moved to higher half in dest(1st) operand, rest is (dest' s lower half) is filled with 2nd operands lower half
	vmovhlps xmm5,xmm7,xmm6 ; Move Packed Single-Precision Floating-Point Values High to Low
	; 3rd operands higher half is moved to lower half in dest(1st) operand, rest is (dest' s upper half) is filled with 2nd operands higher half
	vmovlhps xmm6,xmm0,xmm1
	vmovhlps xmm7,xmm1,xmm0
endm
	.const
r4_Zero	real4 0.0
	.code
AVXTransposeMat4x4_ proc frame ; (float *)  
							   ;    rcx
	_CreateFrame MT_,0,32
	_SaveXmmRegs xmm6,xmm7
	_Endprolog

	vmovaps	xmm0,[rcx]
	vmovaps	xmm1,[rcx+16]
	vmovaps	xmm2,[rcx+32]
	vmovaps	xmm3,[rcx+48]
	
	_Mat4x4TransposeF32Macro
	
	vmovaps	[rcx]	,xmm4
	vmovaps	[rcx+16],xmm5
	vmovaps	[rcx+32],xmm6
	vmovaps	[rcx+48],xmm7

	_RestoreXmmRegs xmm6,xmm7
	_DeleteFrame
	ret
AVXTransposeMat4x4_ endp

AVXMultiplyMat4x4_ proc frame ; (const float *mat1, const float *mat2, float *result)
							  ;            rcx    ,          rdx     ,       r8
	_CreateFrame MT_,0,32
	_SaveXmmRegs xmm6,xmm7
	_Endprolog

	vmovaps	xmm4,[rdx]
	vmovaps	xmm5,[rdx+16]
	vmovaps	xmm6,[rdx+32]
	vmovaps	xmm7,[rdx+48]
	
	mov		eax,4
@@: ; process each row
	vbroadcastss xmm0,real4 ptr[rcx]
	vbroadcastss xmm1,real4 ptr[rcx+4]
	vbroadcastss xmm2,real4 ptr[rcx+8]
	vbroadcastss xmm3,real4 ptr[rcx+12]
	
	vmulps	xmm0,xmm0,xmm4
	vmulps	xmm1,xmm1,xmm5
	vmulps	xmm2,xmm2,xmm6
	vmulps	xmm3,xmm3,xmm7

	vaddps	xmm0,xmm0,xmm1
	vaddps	xmm0,xmm0,xmm2
	vaddps	xmm0,xmm0,xmm3
	
	vmovaps	[r8],xmm0
	add		rcx,16
	add		r8,16
	dec		eax
	jnz		@B

	_RestoreXmmRegs xmm6,xmm7
	_DeleteFrame
	ret
AVXMultiplyMat4x4_ endp
	END