include <cmp_equ.asmh>
	.const
AbsMaskF32	dword 8 dup(7fffffffh)
AbsMaskF64	qword 4 dup(7fffffffffffffffh)
	.code
AvxPackedMathF32_ proc ; bool (const Unified<32>&a, const Unified<32>&b, Unified<32> c[8])
	
; Load
	vmovaps	ymm0,ymmword ptr[rcx]
	vmovaps	ymm1,ymmword ptr[rdx]
; Packed Sp floating-point values
; Addition
	vaddps	ymm2,ymm0,ymm1
	vmovaps	ymmword ptr[r8],ymm2
; Subtraction
	vsubps	ymm2,ymm0,ymm1
	vmovaps	ymmword ptr[r8+32],ymm2
; mutiplication
	vmulps	ymm2,ymm0,ymm1
	vmovaps	ymmword ptr[r8+64],ymm2
; division
	vdivps	ymm2,ymm0,ymm1
	vmovaps	ymmword ptr[r8+96],ymm2
; absolute(b)
	vandps	ymm2,ymm1,ymmword ptr[AbsMaskF32]
	vmovaps	ymmword ptr[r8+128],ymm2
; Sqr-root(a)
	vsqrtps	ymm2,ymm0
	vmovaps	ymmword ptr[r8+160],ymm2
; min
	vminps	ymm2,ymm0,ymm1
	vmovaps	ymmword ptr[r8+192],ymm2
; max
	vmaxps	ymm2,ymm0,ymm1
	vmovaps	ymmword ptr[r8+224],ymm2

	vzeroupper
	mov		al,1
	ret	
AvxPackedMathF32_ endp

AvxPackedMathF64_ proc ; (ITD*) -> bool
; Load
	vmovapd	ymm0,ymmword ptr[rcx]
	vmovapd	ymm1,ymmword ptr[rdx]
; Packed Sp floating-point values
; Addition
	vaddpd	ymm2,ymm0,ymm1
	vmovapd	ymmword ptr[r8],ymm2
; Subtraction
	vsubpd	ymm2,ymm0,ymm1
	vmovapd	ymmword ptr[r8+32],ymm2
; mutiplication
	vmulpd	ymm2,ymm0,ymm1
	vmovapd	ymmword ptr[r8+64],ymm2
; division
	vdivpd	ymm2,ymm0,ymm1
	vmovapd	ymmword ptr[r8+96],ymm2
; absolute(b)
	vandpd	ymm2,ymm1,ymmword ptr[AbsMaskF32]
	vmovapd	ymmword ptr[r8+128],ymm2
; Sqr-root(a)
	vsqrtpd	ymm2,ymm0
	vmovapd	ymmword ptr[r8+160],ymm2
; min
	vminpd	ymm2,ymm0,ymm1
	vmovapd	ymmword ptr[r8+192],ymm2
; max
	vmaxpd	ymm2,ymm0,ymm1
	vmovapd	ymmword ptr[r8+224],ymm2

	vzeroupper
	mov		al,1
	ret	
AvxPackedMathF64_ endp

	.const
r4_3	real4 3.0
r4_4	real4 4.0
extern c_PI_F32:real4
extern c_QNaN_F32:real4

	.code
_UpdateBlockSums macro disp ; disp is param
	vmovdqa	xmm0,xmmword ptr[rdx+disp] ; Load 16 bytes
	vmovdqa	xmm1,xmmword ptr[r8+disp] ; Load 16 mask bytes
	vpand	xmm2,xmm1,xmm8
	vpaddb	xmm6,xmm6,xmm2
	vpand	xmm2,xmm0,xmm1
	vpunpcklbw xmm3,xmm2,xmm9
	vpunpckhbw xmm4,xmm2,xmm9
	vpaddw	xmm4,xmm4,xmm3
	vpaddw	xmm7,xmm7,xmm4 ; update block_sum_mask_pixels
endm
AVXCalcSphereAreaVolume_ proc frame ; (const float *r, const size_t n, float *sa, float *vol)

NUMOFREGS =	1 ; rbx, rsi, rdi
STK_PAD = ((NUMOFREGS AND 1) XOR 1)*8
LOCAL0 = 64 ; 256 * 4bytes
ALLOCATE = LOCAL0 + STK_PAD

; Usage Local variable -> [rbp-LOCAL0 + __variableNo.__0h] like [rbp-LOCAL0] 1st var or [rbp-LOCAL0 + 10h] for 2nd one ...
	push	rbp
	.pushreg rbp

	sub		rsp,ALLOCATE
	.allocstack ALLOCATE
	lea		rbp,[rsp+LOCAL0]

	vmovdqa	xmmword ptr[rbp-LOCAL0],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-LOCAL0+10h],xmm7
	.savexmm128 xmm7,10h
	vmovdqa	xmmword ptr[rbp-LOCAL0+20h],xmm8
	.savexmm128 xmm8,20h
	vmovdqa	xmmword ptr[rbp-LOCAL0+30h],xmm9
	.savexmm128 xmm9,30h
	.endprolog

; Initilize 
	vbroadcastss ymm0,real4 ptr[r4_4]
	vbroadcastss ymm1,real4 ptr[c_PI_F32]
	vmulps	ymm6,ymm0,ymm1
	vbroadcastss ymm7,real4 ptr[r4_3]
	vbroadcastss ymm8,real4 ptr[c_QNaN_F32]
	vxorps	ymm9,ymm9,ymm9

	xor		rax,rax

	cmp		rdx,8
	jb		FinalR
@@:
	vmovdqa	ymm0,ymmword ptr[rcx+rax]
	vmulps	ymm2,ymm6,ymm0
	vmulps	ymm3,ymm2,ymm0

	vcmpps	ymm1,ymm0,ymm9,CMP_LT

	vandps	ymm4,ymm1,ymm8
	vandnps	ymm5,ymm1,ymm3
	vorps	ymm5,ymm5,ymm4
	vmovaps	ymmword ptr[r8+rax],ymm5

	vmulps	ymm2,ymm3,ymm0
	vdivps	ymm3,ymm2,ymm7
	vandps	ymm4,ymm1,ymm8
	vandnps	ymm5,ymm1,ymm3
	vorps	ymm5,ymm4,ymm5
	vmovaps	ymmword ptr[r9+rax],ymm5
	add		rax,32
	sub		rdx,8
	cmp		rdx,8
	jae		@B
FinalR:
	test	rcx,rcx
	jz		RETURN
@@:
	vmovss	xmm0,real4 ptr[rcx+rax]
	vmulss	xmm2,xmm6,xmm0
	vmulss	xmm3,xmm2,xmm0

	vcmpss	xmm1,xmm0,xmm9,CMP_LT

	vandps	xmm4,xmm1,xmm8
	vandnps	xmm5,xmm1,xmm3
	vorps	xmm5,xmm5,xmm4
	vmovss	real4 ptr[r8+rax],xmm5

	vmulss	xmm2,xmm3,xmm0
	vdivss	xmm3,xmm2,xmm7
	vandps	xmm4,xmm1,xmm8
	vandnps	xmm5,xmm1,xmm3
	vorps	xmm5,xmm4,xmm5
	vmovss	real4 ptr[r9+rax],xmm5
	
	add		rax,4
	dec		rdx ; dosen't changes condn-flag
	jnz		@B
RETURN:
	vzeroupper
	vmovdqa	xmm6,xmmword ptr[rbp-LOCAL0]
	vmovdqa	xmm7,xmmword ptr[rbp-LOCAL0+10h]
	vmovdqa	xmm8,xmmword ptr[rbp-LOCAL0+20h]
	vmovdqa	xmm9,xmmword ptr[rbp-LOCAL0+30h]

	lea		rsp,[rbp+STK_PAD] ; as we are restoring rbp anyway ; we can even wrap it in IF(STK_PAD GT 0)...ELSE...ENDIF block for even less overhead
	pop		rbp

	ret	
AVXCalcSphereAreaVolume_ endp
	.const
extern c_NumRowsMax:qword
extern c_NumColsMax:qword
	.code
AVXCalcColumnMeans_ proc ; (const double *x, size_t nrows, size_t ncols, double *col_means) -> bool
	xor		eax,eax
	test	rdx,rdx
	jz		RETURN
	cmp		rdx,[c_NumRowsMax]
	ja		RETURN
	test	r8,r8
	jz		RETURN
	cmp		r8,[c_NumRowsMax]
	ja		RETURN

	vxorpd	xmm0,xmm0,xmm0
@@:
	vmovsd	real8 ptr[r9+rax*8],xmm0
	inc		rax
	cmp		rax,r8
	jb		@B

	vcvtsi2sd xmm2,xmm2,rdx
; Compute the sum of each column in x
LP1:
	mov		r11,r9
	xor		r10,r10
LP2:
	mov		rax,r10
	add		rax,4
	cmp		rax,r8
	ja		@F

; Update col_means using next four columns
	vmovupd	ymm0,ymmword ptr[rcx]
	vaddpd	ymm1,ymm0,ymmword ptr[r11]
	vmovupd	ymmword ptr[r11],ymm1
	add		r10,4
	add		rcx,32
	add		r11,32
	jmp		NextColSet
@@:
	sub		rax,2
	cmp		rax,r8
	ja		@F

	vmovupd	xmm0,xmmword ptr[rcx]
	vaddpd	xmm1,xmm0,xmmword ptr[r11]
	vmovupd	xmmword ptr[r11],xmm1
	add		r10,2
	add		rcx,16
	add		r11,16
	jmp		NextColSet
@@:
	vmovsd	xmm0,real8 ptr[rcx]
	vaddsd	xmm1,xmm0,real8 ptr[r11]
	vmovsd	real8 ptr[r11],xmm1
	inc		r10
	add		rcx,8
NextColSet:
	cmp		r10,r8
	jb		LP2
	dec		rdx
	jnz		LP1

@@:
	vmovsd	xmm0,real8 ptr[r9]
	vdivsd	xmm1,xmm0,xmm2
	vmovsd	real8 ptr[r9],xmm1
	add		r9,8
	dec		r8
	jnz		@B

	mov		eax,1
RETURN:
	vzeroupper
	ret
AVXCalcColumnMeans_ endp

AVXCalcCorrCoef_ proc frame ; (const double *x, const double *y, size_t n, double sum[5], double epsilon, double *rho) -> bool
	
	push	rbp
	.pushreg rbp
	sub		rsp,20h
	.allocstack 20h
	lea		rbp,[rsp+20h]
	vmovdqa	xmmword ptr[rbp-20h],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-10h],xmm7 ; -20h + 10h
	.savexmm128 xmm7,10h
	.endprolog

	or		r8,r8
	jz		BAD_ARG
	test	rcx,1fh
	jnz		BAD_ARG
	test	rdx,1fh
	jnz		BAD_ARG

	vxorpd	ymm3,ymm3,ymm3	; for packed sum_x
	vxorpd	ymm4,ymm4,ymm4	; for packed sum_y
	vxorpd	ymm5,ymm5,ymm5	; for packed sum_xx
	vxorpd	ymm6,ymm6,ymm6	; for packed sum_yy
	vxorpd	ymm7,ymm7,ymm7  ; for packed sum_xy
	mov		r10,r8 ; save n

	cmp		r8,4
	jb		LP2
LP1:
	vmovapd	ymm0,ymmword ptr[rcx] ; x
	vmovapd	ymm1,ymmword ptr[rdx] ; y

	vaddpd	ymm3,ymm3,ymm0
	vaddpd	ymm4,ymm4,ymm1

	vmulpd	ymm2,ymm0,ymm0 ; x*x
	vaddpd	ymm5,ymm5,ymm2
	vmulpd	ymm2,ymm1,ymm1 ; y*y
	vaddpd	ymm6,ymm6,ymm2
	vmulpd	ymm2,ymm0,ymm1 ; x*y
	vaddpd	ymm7,ymm7,ymm2

	add		rcx,32
	add		rdx,32
	sub		r8,4
	cmp		r8,4
	jnb		LP1

	test	r8,r8
	jz		FinalEval
LP2:
	vmovsd	xmm0,real8 ptr[rcx] ; x
	vmovsd	xmm1,real8 ptr[rdx] ; y

	vaddpd	ymm3,ymm3,ymm0
	vaddpd	ymm4,ymm4,ymm1

	vmulpd	ymm2,ymm0,ymm0 ; x*x
	vaddpd	ymm5,ymm5,ymm2
	vmulpd	ymm2,ymm1,ymm1 ; y*y
	vaddpd	ymm6,ymm6,ymm2
	vmulpd	ymm2,ymm0,ymm1 ; x*y
	vaddpd	ymm7,ymm7,ymm2

	add		rcx,8
	add		rdx,8
	dec 	r8
	jnz		LP2
FinalEval:
	vextractf128 xmm0,ymm3,1 ; xmm0 = ymm3[255:128]
	vextractf128 xmm1,ymm4,1 ; xmm1 = ymm4[255:128]
	vaddpd	xmm3,xmm0,xmm3
	vaddpd	xmm4,xmm1,xmm4

	vextractf128 xmm0,ymm5,1 ; xmm0 = ymm3[255:128]
	vaddpd	xmm5,xmm0,xmm5

	vextractf128 xmm0,ymm6,1 ; xmm0 = ymm3[255:128]
	vextractf128 xmm1,ymm7,1 ; xmm1 = ymm4[255:128]
	vaddpd	xmm6,xmm0,xmm6
	vaddpd	xmm7,xmm1,xmm7

	vhaddpd	xmm3,xmm3,xmm3
	vhaddpd	xmm4,xmm4,xmm4
	vhaddpd	xmm5,xmm5,xmm5
	vhaddpd	xmm6,xmm6,xmm6
	vhaddpd	xmm7,xmm7,xmm7

	vmovsd	real8 ptr[r9],xmm3    ; sum_x 
	vmovsd	real8 ptr[r9+8],xmm4  ; sum_y
	vmovsd	real8 ptr[r9+16],xmm5 ; sum_xx
	vmovsd	real8 ptr[r9+24],xmm6 ; sum_yy
	vmovsd	real8 ptr[r9+32],xmm7 ; sum_xy

; Calc rho = rho_num/rho_denom
; rho_num = n * sum_xy - sum_x * sum_y
	vcvtsi2sd xmm2,xmm2,r10
	vmulsd	xmm0,xmm7,xmm2
	vmulsd	xmm1,xmm3,xmm4
	vsubsd	xmm7,xmm0,xmm1
; rho_denom = t1 * t2
; t1 = sqrt(n * sum_xx - sum_x * sum_x)
; t2 = sqrt(n * sum_yy - sum_y * sum_y)
	vmulsd	xmm3,xmm3,xmm3 ; sum_x * sum_x
	vmulsd	xmm4,xmm4,xmm4 ; sum_y * sum_y
	vmulsd	xmm5,xmm2,xmm5 ; n * sum_xx
	vmulsd	xmm6,xmm2,xmm6 ; n * sum_yy
	vsubsd	xmm0,xmm5,xmm3 ; 
	vsubsd	xmm1,xmm6,xmm4

	vsqrtsd	xmm0,xmm0,xmm0
	vsqrtsd	xmm1,xmm1,xmm1

	vmulpd	xmm3,xmm1,xmm0

	xor		al,al
	vcomisd	xmm3,real8 ptr[rbp+48]
	setae	al
	jl		BAD_DENOM

	vdivpd	xmm5,xmm7,xmm3

	mov		rdx,qword ptr[rbp+56]
	vmovsd	real8 ptr[rdx],xmm5
RETURN:
	vmovdqa	xmm6,xmmword ptr[rbp-20h]
	vmovdqa	xmm7,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
	ret
BAD_ARG:
	xor		al,al
	jmp		RETURN
BAD_DENOM:
	vpxor	xmm5,xmm5,xmm5
	vmovsd	real8 ptr[rbp+56],xmm5
	jmp		RETURN
AVXCalcCorrCoef_ endp
	END