	.code

_MACRO4x4TransposeF64_ macro
; in
; ymm0 = a3 a2 a1 a0
; ymm1 = b3 b2 b1 b0
; ymm2 = c3 c2 c1 c0
; ymm3 = d3 d2 d1 d0
	vunpcklpd ymm4,ymm0,ymm1	  ; ymm4 = a0 b0 a2 b2 
	vunpckhpd ymm5,ymm0,ymm1	  ; ymm5 = a1 b1 a3 b3 
	vunpcklpd ymm6,ymm2,ymm3	  ; ymm6 = c0 d0 c2 d2 
	vunpckhpd ymm7,ymm2,ymm3	  ; ymm7 = c1 d1 c3 d3 

	vperm2f128 ymm0,ymm4,ymm6,20h ; ymm0 = a0 b0 c0 d0 ; IMM8 is 1-byte special configration 
	vperm2f128 ymm1,ymm5,ymm7,20h ; ymm1 = a1 b1 c1 d1 ; IMM8 is 1-byte special configration 
	vperm2f128 ymm2,ymm4,ymm6,31h ; ymm2 = a2 b2 c2 d2 ; IMM8 is 1-byte special configration 
	vperm2f128 ymm3,ymm5,ymm7,31h ; ymm3 = a3 b3 c3 d3 ; IMM8 is 1-byte special configration 
endm
AVXMat4x4TransposeF64_ proc frame; (double *src_mat_ptr, double *dest_mat_ptr)
	
	push	rbp
	.pushreg rbp
	sub		rsp,20h
	.allocstack 20h
	lea		rbp,[rsp+20h]
	vmovdqa	xmmword ptr[rbp-20h],xmm6
	.savexmm128 xmm6,00h
	vmovdqa	xmmword ptr[rbp-10h],xmm7
	.savexmm128 xmm7,10h
	.endprolog

	vmovapd	ymm0,ymmword ptr[rcx+00h] ; don't use ymmword ptr (not sure why its not working)
	vmovapd	ymm1,ymmword ptr[rcx+20h]
	vmovapd	ymm2,ymmword ptr[rcx+40h]
	vmovapd	ymm3,ymmword ptr[rcx+60h]

	_MACRO4x4TransposeF64_

	vmovapd	ymmword ptr[rdx+00h],ymm0
	vmovapd	ymmword ptr[rdx+20h],ymm1
	vmovapd	ymmword ptr[rdx+40h],ymm2
	vmovapd	ymmword ptr[rdx+60h],ymm3
RETURN:
	vzeroupper
	vmovdqa	xmm6,xmmword ptr[rbp-20h]
	vmovdqa	xmm7,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
	ret	
AVXMat4x4TransposeF64_ endp
_MACRO4x4MulCalcRowF64_ macro disp,Src1,Dest
; in
; ymm0 = Src2.row0
; ymm1 = Src2.row1
; ymm2 = Src2.row2
; ymm3 = Src2.row3
	vbroadcastsd ymm4,real8 ptr[Src1+disp]	   ; ymm4 = {Src1[i][0]...}
	vbroadcastsd ymm5,real8 ptr[Src1+disp+08h] ; ymm5 = {Src1[i][1]...}
	vbroadcastsd ymm6,real8 ptr[Src1+disp+10h] ; ymm6 = {Src1[i][2]...}
	vbroadcastsd ymm7,real8 ptr[Src1+disp+18h] ; ymm7 = {Src1[i][3]...}

	vmulpd	ymm4,ymm4,ymm0
	vmulpd	ymm5,ymm5,ymm1
	vmulpd	ymm6,ymm6,ymm2
	vmulpd	ymm7,ymm7,ymm3

	vaddpd	ymm4,ymm4,ymm5
	vaddpd	ymm6,ymm6,ymm7
	vaddpd	ymm4,ymm4,ymm6

	vmovapd ymmword ptr[Dest+disp],ymm4
endm
AVXMat4x4MultiplyF64_ proc frame ; (double *src1_mat_ptr, double *src2_mat_ptr, double *dest_mat_ptr)
	
	push	rbp
	.pushreg rbp
	sub		rsp,20h
	.allocstack 20h
	lea		rbp,[rsp+20h]
	vmovdqa	xmmword ptr[rbp-20h],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-10h],xmm7
	.savexmm128 xmm7,10h
	.endprolog

	vmovapd	ymm0,[rdx+00h]
	vmovapd	ymm1,[rdx+20h]
	vmovapd	ymm2,[rdx+40h]
	vmovapd	ymm3,[rdx+60h]

	_MACRO4x4MulCalcRowF64_ 00h,rcx,r8
	_MACRO4x4MulCalcRowF64_ 20h,rcx,r8
	_MACRO4x4MulCalcRowF64_ 40h,rcx,r8
	_MACRO4x4MulCalcRowF64_ 60h,rcx,r8

RETURN:
	vzeroupper
	vmovdqa	xmm6,xmmword ptr[rbp-20h]
	vmovdqa	xmm7,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
	ret	
AVXMat4x4MultiplyF64_ endp
	.const
ConstVals segment readonly align(32) 'const'
Mat4x4I	real8 1.0, 0.0, 0.0, 0.0
		real8 0.0, 1.0, 0.0, 0.0
		real8 0.0, 0.0, 1.0, 0.0
		real8 0.0, 0.0, 0.0, 1.0
r8_SignedBitMask qword 4 dup(8000000000000000h)
r8_AbsMask       qword 4 dup(7FFFFFFFFFFFFFFFh)

r8_1      real8  1.0
r8_N1	  real8 -1.0
r8_N0_5	  real8 -0.5
r8_N0_33  real8 -0.3333333333333333
r8_N0_25  real8  0.25
ConstVals ends
	.code
_Mat4x4TraceF64_ macro
	vblendpd ymm0,ymm0,ymm1,00000010b   ; ymm0[127:0] = row 1,0 diag vals
	vblendpd ymm1,ymm2,ymm3,00001000b	; ymm1[255:128] = row 3,2 diag vals
	vperm2f128 ymm2,ymm1,ymm1,00000001b	; ymm0[127:0] = row 3,2 diag vals
	vaddpd	ymm3,ymm0,ymm2
	vhaddpd	ymm0,ymm3,ymm3				; ymm0[63:0] = trace
endm
AVX2Mat4x4TraceF64_ proc ; (double*) -> float
	vmovapd	ymm0,[rcx]	   ; ymm0 = src1.row_0
	vmovapd	ymm1,[rcx+20h] ; ymm1 = src1.row_0
	vmovapd	ymm2,[rcx+40h] ; ymm2 = src1.row_0
	vmovapd	ymm3,[rcx+60h] ; ymm3 = src1.row_0

	_Mat4x4TraceF64_
	vzeroupper
	ret
AVX2Mat4x4TraceF64_ endp
_Mat4x4MulCalcRowF64_ macro sreg,dreg,disp
	vbroadcastsd ymm4,real8 ptr[sreg+disp]
	vbroadcastsd ymm5,real8 ptr[sreg+disp+08h]
	vbroadcastsd ymm6,real8 ptr[sreg+disp+10h]
	vbroadcastsd ymm7,real8 ptr[sreg+disp+18h]

	vmulpd	ymm4,ymm4,ymm0
	vmulpd	ymm5,ymm5,ymm1
	vmulpd	ymm6,ymm6,ymm2
	vmulpd	ymm7,ymm7,ymm3

	vaddpd	ymm4,ymm4,ymm5
	vaddpd	ymm6,ymm6,ymm7
	vaddpd	ymm4,ymm4,ymm6

	vmovapd	[dreg+disp],ymm4
endm
AVX2Mat4x4MultiplyF64_ proc frame
	
	push	rbp
	.pushreg rbp
	sub		rsp,20h
	.allocstack 20h
	lea		rbp,[rsp+20h]
	vmovdqa	xmmword ptr[rbp-20h],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-10h],xmm7
	.savexmm128 xmm7,10h
	.endprolog

	vmovapd	ymm0,[rdx+00h]
	vmovapd	ymm1,[rdx+20h]
	vmovapd	ymm2,[rdx+40h]
	vmovapd	ymm3,[rdx+60h]

	_Mat4x4MulCalcRowF64_ rcx,r8,00h
	_Mat4x4MulCalcRowF64_ rcx,r8,20h
	_Mat4x4MulCalcRowF64_ rcx,r8,40h
	_Mat4x4MulCalcRowF64_ rcx,r8,60h

RETURN:
	vzeroupper
	vmovdqa	xmm6,xmmword ptr[rbp-20h]
	vmovdqa	xmm7,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
	ret
AVX2Mat4x4MultiplyF64_ endp
AVX2Mat4x4InvertF64_ proc frame ; (double *src_mat_ptr, double *dest_mat_ptr, const double epsilon, bool& isSingular) -> bool
	push	rbp
	.pushreg rbp
	sub		rsp,0A0h
	.allocstack 0A0h
	lea		rbp,[rsp+0A0h]
	vmovdqa	xmmword ptr[rbp-0A0h],xmm6
	.savexmm128 xmm6,0
	vmovdqa	xmmword ptr[rbp-90h],xmm7
	.savexmm128 xmm7,10h
	vmovdqa	xmmword ptr[rbp-80h],xmm8
	.savexmm128 xmm8,20h
	vmovdqa	xmmword ptr[rbp-70h],xmm9
	.savexmm128 xmm9,30h
	vmovdqa	xmmword ptr[rbp-60h],xmm10
	.savexmm128 xmm10,40h
	vmovdqa	xmmword ptr[rbp-50h],xmm11
	.savexmm128 xmm11,50h
	vmovdqa	xmmword ptr[rbp-40h],xmm12
	.savexmm128 xmm12,60h
	vmovdqa	xmmword ptr[rbp-30h],xmm13
	.savexmm128 xmm13,70h
	vmovdqa	xmmword ptr[rbp-20h],xmm14
	.savexmm128 xmm14,80h
	vmovdqa	xmmword ptr[rbp-10h],xmm15
	.savexmm128 xmm15,90h
	.endprolog
OffsetM2 equ 32
OffsetM3 equ 160
OffsetM4 equ 288
	
	mov		qword ptr[rbp+10h],rcx ; mov to RCX_HOME
	mov		qword ptr[rbp+18h],rdx ; mov to RdX_HOME
	vmovsd	real8 ptr[rbp+20h],xmm2; mov to R8_HOME
	mov		qword ptr[rbp+28h],r9  ; mov to R9_HOME

; Allocate	384 bytes of stack space for temp matrices + 32 bytes for function calls
	and		rsp,0ffffffe0h ; align rsp to 32byte boundry
	sub		rsp,416 ; extra for offset alignment

; Calculate m2
	mov		rdx,rcx
	lea		r8,[rsp+OffsetM2]
	call	AVX2Mat4x4MultiplyF64_
	
; Calculate m3
	lea		rcx,[rsp+OffsetM2]
	mov		rdx,qword ptr[rbp+10h]
	lea		r8,[rsp+OffsetM3]
	call	AVX2Mat4x4MultiplyF64_
	
; Calculate m4
	lea		rcx,[rsp+OffsetM3]
	mov		rdx,qword ptr[rbp+10h]
	lea		r8,[rsp+OffsetM4]
	call	AVX2Mat4x4MultiplyF64_

; Calculate trace of m,m2,m3 and m4
	mov		rcx,qword ptr[rbp+10h]
	call	AVX2Mat4x4TraceF64_
	vmovsd	xmm8,xmm8,xmm0

	lea		rcx,[rsp+OffsetM2]
	call	AVX2Mat4x4TraceF64_
	vmovsd	xmm9,xmm9,xmm0

	lea		rcx,[rsp+OffsetM3]
	call	AVX2Mat4x4TraceF64_
	vmovsd	xmm10,xmm10,xmm0
	
	lea		rcx,[rsp+OffsetM4]
	call	AVX2Mat4x4TraceF64_
	vmovsd	xmm11,xmm11,xmm0

	vxorpd	xmm12,xmm8,real8 ptr[r8_SignedBitMask]

	vmulsd	xmm13,xmm12,xmm8
	vaddsd	xmm13,xmm13,xmm9
	vmulsd	xmm13,xmm13,[r8_N0_5]
	
	vmulsd	xmm14,xmm13,xmm8
	vmulsd	xmm0,xmm12,xmm9
	vaddsd	xmm14,xmm14,xmm0
	vaddsd	xmm14,xmm14,xmm10
	vmulsd	xmm14,xmm14,[r8_N0_33]

	vmulsd	xmm15,xmm14,xmm8
	vmulsd	xmm0,xmm13,xmm9
	vmulsd	xmm1,xmm12,xmm10
	vaddsd	xmm2,xmm0,xmm1
	vaddsd	xmm15,xmm15,xmm2
	vaddsd	xmm15,xmm15,xmm11
	vmulsd	xmm15,xmm15,[r8_N0_25]

	vandpd	xmm0,xmm15,[r8_AbsMask]
	vmovsd	xmm1,real8 ptr[rbp+20h] ; r8_home
	vcomisd	xmm0,xmm1
	setp	al
	setb	ah
	or		al,ah
	mov		rcx,[rbp+28h]
	mov		[rcx],al
	jnz		ERROR

	vbroadcastsd ymm14,xmm14
	lea		rcx,[Mat4x4I]
	vmulpd	ymm0,ymm14,ymmword ptr[rcx]
	vmulpd	ymm1,ymm14,ymmword ptr[rcx+20h]
	vmulpd	ymm2,ymm14,ymmword ptr[rcx+40h]
	vmulpd	ymm3,ymm14,ymmword ptr[rcx+60h]

	vbroadcastsd ymm13,xmm13
	mov		rcx,[rbp+10h]
	vmulpd	ymm4,ymm13,ymmword ptr[rcx]
	vmulpd	ymm5,ymm13,ymmword ptr[rcx+20h]
	vmulpd	ymm6,ymm13,ymmword ptr[rcx+40h]
	vmulpd	ymm7,ymm13,ymmword ptr[rcx+60h]

	vaddpd	ymm0,ymm0,ymm4
	vaddpd	ymm1,ymm1,ymm5
	vaddpd	ymm2,ymm2,ymm6
	vaddpd	ymm3,ymm3,ymm7

	vbroadcastsd ymm12,xmm12
	lea		rcx,[rsp+OffsetM2]
	vmulpd	ymm4,ymm12,ymmword ptr[rcx]
	vmulpd	ymm5,ymm12,ymmword ptr[rcx+20h]
	vmulpd	ymm6,ymm12,ymmword ptr[rcx+40h]
	vmulpd	ymm7,ymm12,ymmword ptr[rcx+60h]
	vaddpd	ymm0,ymm0,ymm4
	vaddpd	ymm1,ymm1,ymm5
	vaddpd	ymm2,ymm2,ymm6
	vaddpd	ymm3,ymm3,ymm7
	
	lea		rcx,[rsp+OffsetM3]
	vaddpd	ymm0,ymm0,ymmword ptr[rcx]
	vaddpd	ymm1,ymm1,ymmword ptr[rcx+20h]
	vaddpd	ymm2,ymm2,ymmword ptr[rcx+40h]
	vaddpd	ymm3,ymm3,ymmword ptr[rcx+60h]

	vmovsd	xmm4,[r8_N1]
	vdivsd	xmm4,xmm4,xmm15
	vbroadcastsd ymm4,xmm4
	vmulpd	ymm0,ymm0,ymm4
	vmulpd	ymm1,ymm1,ymm4
	vmulpd	ymm2,ymm2,ymm4
	vmulpd	ymm3,ymm3,ymm4

	mov		rcx,[rbp+18h] ; rdx_home
	vmovapd	ymmword ptr[rcx],ymm0
	vmovapd	ymmword ptr[rcx+20h],ymm1
	vmovapd	ymmword ptr[rcx+40h],ymm2
	vmovapd	ymmword ptr[rcx+60h],ymm3
	mov		eax,1
RETURN:
	vzeroupper
	vmovdqa	xmm6 ,xmmword ptr[rbp-160]
	vmovdqa	xmm7 ,xmmword ptr[rbp-90h]
	vmovdqa	xmm8 ,xmmword ptr[rbp-80h]
	vmovdqa	xmm9 ,xmmword ptr[rbp-70h]
	vmovdqa	xmm10,xmmword ptr[rbp-60h]
	vmovdqa	xmm11,xmmword ptr[rbp-50h]
	vmovdqa	xmm12,xmmword ptr[rbp-40h]
	vmovdqa	xmm13,xmmword ptr[rbp-30h]
	vmovdqa	xmm14,xmmword ptr[rbp-20h]
	vmovdqa	xmm15,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
	ret	
ERROR:
	xor		eax,eax
	jmp		RETURN
AVX2Mat4x4InvertF64_ endp
	END