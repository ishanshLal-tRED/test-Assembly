include <MacrosX86-64-AVX.asmh>

extern g_MinValInit:real4
extern g_MaxValInit:real4

extern LsEpsilon:real8

	.const
	align 16
AbsMaskF64	qword 7fffffffffffffffh, 7fffffffffffffffh ; mask for DPFP absolute value


	.code
AVXPackedSqrtsF32Array_ proc ; (float*, float*, uint32_t) -> bool
							 ;    rcx ,  rdx  ,     r8d   -> al
	xor		al,al
	test	rcx, 0Fh ; jmp if src is not aligned
	jnz		RETURN
	test	rdx, 0Fh ; jmp if src is not aligned
	jnz		RETURN
	
; Calculate packed square roots

@@:
	test	r8d, r8d
	jz		RETURN
	setnz	al
	cmp		r8d,4
	jb		FinalVals
	
	vsqrtps	xmm0, xmmword ptr[rcx] ; vsqrtpd for double, everything else is same
	vmovaps	xmmword ptr[rdx],xmm0  ; vmovapd for double

	add		rcx,16 ; shift by xmmword
	add		rdx,16 ; shift by xmmword
	sub		r8d,4
	jmp		@B

FinalVals:
@@:
	vsqrtss	xmm0, xmm0, real4 ptr[rcx] ; vsqrtss for double
	vmovss	real4 ptr[rdx],xmm0        ; vmovsd for double

	sub		r8d,1
	add		rcx,4 ; shift by xmmword
	add		rdx,4 ; shift by xmmword
	test	r8d, r8d
	jnz		@B

RETURN:
	ret
AVXPackedSqrtsF32Array_ endp

AVXMinMaxFromPackedF32Array_ proc ; (const float *arr, float &, float &, size_t n) -> bool
								  ;              rcx ,   rdx  ,   r8   ,     r9d   -> al
	xor		al,al

	test	rcx, 0Fh ; jmp if src is not aligned
	jnz		RETURN

	vbroadcastss xmm4,real4 ptr[g_MinValInit]
	vbroadcastss xmm5,real4 ptr[g_MaxValInit]
	
; Calculate packed square roots
	test	r9d, r9d
	jz		RETURN
	setnz	al
@@:
	cmp		r9d,4
	jb		SemiFinalVals
	
	vmovaps	xmm0, xmmword ptr[rcx]
	vmaxps	xmm4,xmm4,xmm0
	vminps	xmm5,xmm5,xmm0

	add		rcx,16 ; shift by xmmword
	sub		r9d,4
	jmp		@B

SemiFinalVals:
	test	r9d, r9d
	jz		FinalVals

	vmovss	xmm0, real4 ptr[rcx] 
	vmaxss	xmm4, xmm4, xmm0
	vminss	xmm5, xmm5, xmm0
	dec		r9d
	add		rcx,4
	
	test	r9d, r9d
	jz		FinalVals
	
	vmovss	xmm0, real4 ptr[rcx] 
	vmaxss	xmm4, xmm4, xmm0
	vminss	xmm5, xmm5, xmm0
	dec		r9d
	add		rcx,4
	test	r9d, r9d
	jz		FinalVals
	
	vmovss	xmm0, real4 ptr[rcx] 
	vmaxss	xmm4, xmm4, xmm0
	vminss	xmm5, xmm5, xmm0
	;dec		r9d
	;add		rcx,4
	;test	r9d, r9d
	;jz		FinalVals

FinalVals:
	vshufps	xmm0,xmm4,xmm4,00001110b ; xmm0[63:0] = xmm4[128:64] ; Packed Interleave Shuffle Single-Precision Floating-Point Values
	; This instruction uses the bit values of its immediate operand as indices for selecting elements to copy.
	; going from back bit[1:0] == 10b -> 2 => #0 in reg_xmm0 = #2 of reg_xmm4,
	; similarly bit[3:2] == 11b -> 3 => #1 in reg_xmm0 = #3 of reg_xmm4,
	; also bit[5:4] & [7:6] == 00b -> 0 => #2 & #3 in reg_xmm0 = #0 of reg_xmm4

	vmaxps	xmm1,xmm0,xmm4           ; xmm0[63:0] = final 2 vals
	vshufps	xmm2,xmm1,xmm1,00000001b ; xmm2[31:0] = xmm4[63:32]
	vmaxss	xmm3,xmm2,xmm1           ; xmm3[31:0] = final max
	vmovss	real4 ptr[r8],xmm3

	vshufps	xmm0,xmm5,xmm5,00001110b ; xmm0[63:0] = xmm4[128:64]
	vminps	xmm1,xmm0,xmm5           ; xmm0[63:0] = final 2 vals
	vshufps	xmm2,xmm1,xmm1,00000001b ; xmm2[31:0] = xmm4[63:32]
	vminss	xmm3,xmm2,xmm1           ; xmm3[31:0] = final max
	vmovss	real4 ptr[rdx],xmm3

RETURN:
	ret
AVXMinMaxFromPackedF32Array_ endp

AVXLeastSquaresFromPackedF64Array_ proc frame ; (const double *x, const double *y, int32_t n, double *m, double *b) -> bool
	
	_CreateFrame LS_,0,48,rbx
	_SaveXmmRegs xmm6,xmm7,xmm8
	_EndProlog

; Validate arguments
	xor		eax,eax
	cmp		r8d,2
	jl		RETURN
	test	rcx,0Fh
	jnz		RETURN
	test	rdx,0Fh
	jnz		RETURN

; Initialize
	vcvtsi2sd xmm3,xmm3,r8d
	mov		eax,r8d
	and		r8d,0FFFFFFFEh  ; r8d = (n / 2)*2 , or just dropping the last bit
	and		eax,1			; eax = eax % 2

	vxorpd	xmm4,xmm4,xmm4
	vxorpd	xmm5,xmm5,xmm5
	vxorpd	xmm6,xmm6,xmm6
	vxorpd	xmm7,xmm7,xmm7
	
	xor		ebx,ebx
	mov		r10,[rbp+LS_OffsetStackArgs]

; Calculate sum variables. Note that 2 values are processed each iteration.
@@:
	vmovapd	xmm0,xmmword ptr[rcx+rbx]   ; load next 2 x values
	vmovapd	xmm1,xmmword ptr[rdx+rbx]   ; load next 2 y values

	vaddpd	xmm4,xmm4,xmm0              ; update sum_x
	vaddpd	xmm5,xmm5,xmm1              ; update sum_y

	vmulpd	xmm2,xmm0,xmm0              ; calc x * x
	vaddpd	xmm6,xmm6,xmm2              ; update sum_xx

	vmulpd	xmm2,xmm0,xmm1              ; calc x * y
	vaddpd	xmm7,xmm7,xmm2              ; update sum_xy

	add		rbx,16                      ; rbx = next offset
	sub		r8d,2                       ; adjust counter
	jnz		@B                          ; repeat until Done

; Update sum variables with the final x, y values if 'n' is odd
	or		eax,eax
	jz		CalcFinalSums               ; jump if n is even
	vmovsd	xmm0,real8 ptr[rcx+rbx]     ; load final x
	vmovsd	xmm1,real8 ptr[rdx+rbx]     ; load final x

	vaddsd	xmm4,xmm4,xmm0              ; update sum_x
	vaddsd	xmm5,xmm5,xmm1              ; update sum_y

	vmulsd	xmm2,xmm0,xmm0              ; calc x * x
	vaddsd	xmm6,xmm6,xmm2              ; update sum_xx

	vmulsd	xmm2,xmm0,xmm1              ; calc x * y
	vaddsd	xmm7,xmm7,xmm2              ; update sum_xy

; Calculate final sum_x, sum_y, sum_xx, sum_xy
CalcFinalSums:
	vhaddpd	xmm4,xmm4,xmm4              ; xmm4[63:0] = final sum_x
	vhaddpd	xmm5,xmm5,xmm5              ; xmm4[63:0] = final sum_y
	vhaddpd	xmm6,xmm6,xmm6              ; xmm4[63:0] = final sum_xx
	vhaddpd	xmm7,xmm7,xmm7              ; xmm4[63:0] = final sum_xy
	
; Compute denomintor and make sure it's valid
; denom = n * sum_xx - sum_x * sum_x
	vmulsd	xmm0,xmm3,xmm6              ; n* sum_xx
	vmulsd	xmm1,xmm4,xmm4              ; sum_x*sum_x
	vsubsd	xmm2,xmm0,xmm1              ; denom
	vandpd	xmm8,xmm2,xmmword ptr[AbsMaskF64] ; fabs(denom)
	vcomisd	xmm8,real8 ptr[LsEpsilon]
	jb		BadDenom                    ; jump if denom < fabs(denom)

; Compute and save slope
; slope = (n * sum_xy - sum_x * sum_y) / denom
	vmulsd	xmm0,xmm3,xmm7              ; n * sum_xy
	vmulsd	xmm1,xmm4,xmm5              ; sum_x * sum_y
	vsubsd	xmm2,xmm0,xmm1              ; slope numerator
	vdivsd	xmm3,xmm2,xmm8              ; final slope
	vmovsd	real8 ptr[r9],xmm3          ; save slope

; Compute and save intercept
; intercept = (sum_xx * sum_y - sum_x * sum_xy) / denom
	vmulsd	xmm0,xmm6,xmm5              ; sum_xx * sum_y
	vmulsd	xmm1,xmm4,xmm7              ; sum_x * sum_xy
	vsubsd	xmm2,xmm0,xmm1              ; intercept numerator
	vdivsd	xmm3,xmm2,xmm8              ; final intercept
	vmovsd	real8 ptr[r10],xmm3         ; save intercept

	mov		al,1
	jmp		RETURN

; Bad denominator detected, set m and b to zero
BadDenom:
	vxorpd	xmm0,xmm0,xmm0
	vmovsd	real8 ptr[r9],xmm0
	vmovsd	real8 ptr[r10],xmm0
	xor		eax,eax

RETURN:
	_RestoreXmmRegs xmm6,xmm7,xmm8
	_DeleteFrame rbx
	ret

	ret
AVXLeastSquaresFromPackedF64Array_ endp
	END