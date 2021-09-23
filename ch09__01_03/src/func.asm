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
	END