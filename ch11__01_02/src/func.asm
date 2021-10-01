extern	c_NumPtsMin:dword
extern	c_NumPtsMax:dword
extern	c_KernelSizeMin:dword
extern	c_KernelSizeMax:dword
	.code
Convolve1_ proc frame ; (float *y, const float *x, int32_t num_pts, const float *kernel, int kernel_size) -> bool
_CreateFrame1 macro
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx
	push	rsi
	.pushreg rsi
	mov		rbp,rsp
	.endprolog ; no stack allocation
endm
	_CreateFrame1

	xor		eax,eax
	mov		r10d,[rbp+64] ; kernel_size
	test	r10d,1
	jz		RETURN ; is an odd no.
	cmp		r10d,[c_KernelSizeMin]
	jl		RETURN
	cmp		r10d,[c_KernelSizeMax]
	jg		RETURN

	cmp		r8d,[c_NumPtsMin]
	jl		RETURN
	cmp		r8d,[c_NumPtsMax]
	jg		RETURN

	movsxd	r8,r8d
	shr		r10d,1
	lea		rdx,[rdx+r10*4]

LP1:
	vxorps	xmm5,xmm5,xmm5
	mov		r11,r10
	neg		r11 ; -r11
LP2:
	mov		rbx,rax
	sub		rbx,r11
	vmovss	xmm0,real4 ptr[rdx+rbx*4]
	mov		rsi,r11
	add		rsi,r10
	vfmadd231ss xmm5,xmm0,[r9+rsi*4]
	add		r11,1
	cmp		r11,r10
	jle		LP2

	vmovss	real4 ptr[rcx+rax*4],xmm5
	add		rax,1
	cmp		rax,r8
	jl		LP1

	mov		eax,1
RETURN:
_DeleteFrame1 macro
	vzeroupper
	mov		rsp,rbp
	pop		rsi
	pop		rbx
	pop		rbp
endm
	_DeleteFrame1
	ret
Convolve1_ endp
Convolve1Ks5_ proc ;(float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size) -> bool
	xor		rax,rax

	cmp		dword ptr[rsp+40],5 ; hardcoded
	jne		RETURN

	cmp		r8d,[c_NumPtsMin]
	jl		RETURN
	cmp		r8d,[c_NumPtsMax]
	jg		RETURN

	sub		r8d,4 ; hardcoded
	movsxd	r8,r8d
	add		rdx,8 ; start at index 2

@@:
	vxorps	xmm4,xmm4,xmm4
	vxorps	xmm5,xmm5,xmm5
	mov		r11,rax
	add		r11,2

	vmovss	xmm0,real4 ptr[rdx+r11*4]
	vfmadd231ss xmm4,xmm0,[r9]

	vmovss	xmm1,real4 ptr[rdx+r11*4-4]
	vfmadd231ss xmm5,xmm1,[r9+4]

	vmovss	xmm0,real4 ptr[rdx+r11*4-8]
	vfmadd231ss xmm4,xmm0,[r9+8]

	vmovss	xmm1,real4 ptr[rdx+r11*4-12]
	vfmadd231ss xmm5,xmm1,[r9+12]

	vmovss	xmm0,real4 ptr[rdx+r11*4-16]
	vfmadd231ss xmm4,xmm0,[r9+16]

	vaddps	xmm4,xmm4,xmm5
	vmovss	real4 ptr[rcx+rax*4],xmm4

	inc		rax
	cmp		rax,r8
	jl		@B

	mov		eax,1
RETURN:
	vzeroupper
	ret
Convolve1Ks5_ endp

Convolve2_ proc frame ; (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size) -> bool
_CreateFrame2 macro
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx
	sub		rsp,8 ; padding
	.allocstack 8
	mov		rbp,rsp
	.endprolog
endm
	_CreateFrame2

	xor		eax,eax
	mov		r10d,[rbp+64] ; kernel_size
	test	r10d,1
	jz		RETURN ; is an odd no.
	cmp		r10d,[c_KernelSizeMin]
	jl		RETURN
	cmp		r10d,[c_KernelSizeMax]
	jg		RETURN

	cmp		r8d,[c_NumPtsMin]
	jl		RETURN
	cmp		r8d,[c_NumPtsMax]
	jg		RETURN
	test	r8d,7
	jnz		RETURN
	test	rcx,1fh
	jnz		RETURN

	sub		r8d,r10d
	shr		r10d,1
	lea		rdx,[rdx+r10*4]
	xor		rbx,rbx

LP1:
	vxorps	ymm0,ymm0,ymm0
	mov		r11,r10
	neg		r11 ; -r11
LP2:
	mov		rax,rbx
	sub		rax,r11
	vmovups	ymm1,ymmword ptr[rdx+rax*4]
	
	mov		rax,r11
	add		rax,r10
	vbroadcastss ymm2,real4 ptr[r9+rax*4]
	vfmadd231ps ymm0,ymm1,ymm2
	add		r11,1
	cmp		r11,r10
	jle		LP2

	vmovaps	ymmword ptr[rcx+rbx*4],ymm0
	add		rbx,8
	cmp		rbx,r8
	jl		LP1

	mov		eax,1
RETURN:
_DeleteFrame2 macro
	lea		rsp,[rbp+8]
	pop		rbx
	pop		rbp
endm
	_DeleteFrame2
	ret
Convolve2_ endp
Convolve2Ks5_ proc frame; (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size) -> bool
_CreateFrame2 macro
	push	rbp
	.pushreg rbp
	sub		rsp,30h
	.allocstack 30h
	lea		rbp,[rsp+30h]

	vmovapd xmmword ptr[rbp-30h],xmm6
	.savexmm128 xmm6,0
	vmovapd xmmword ptr[rbp-20h],xmm7
	.savexmm128 xmm7,10h
	vmovapd xmmword ptr[rbp-10h],xmm8
	.savexmm128 xmm8,20h
	.endprolog
endm
	_CreateFrame2

	xor		eax,eax

	cmp		dword ptr[rbp+48],5
	jne		RETURN

	cmp		r8d,[c_NumPtsMin]
	jl		RETURN
	cmp		r8d,[c_NumPtsMax]
	jg		RETURN
	test	r8d,7
	jnz		RETURN

	test	rcx,1fh
	jnz		RETURN

	vbroadcastss ymm4,real4 ptr[r9]
	vbroadcastss ymm5,real4 ptr[r9+4]
	vbroadcastss ymm6,real4 ptr[r9+8]
	vbroadcastss ymm7,real4 ptr[r9+12]
	vbroadcastss ymm8,real4 ptr[r9+16]
	mov		r8d,r8d
	add		rdx,8

@@:
	vxorps	ymm2,ymm2,ymm2
	vxorps	ymm3,ymm3,ymm3
	mov		r11,rax
	add		r11,2

	vmovups	ymm0,ymmword ptr[rdx+r11*4]
	vfmadd231ps ymm2,ymm0,ymm4

	vmovups	ymm1,ymmword ptr[rdx+r11*4-4]
	vfmadd231ps ymm3,ymm1,ymm5

	vmovups	ymm0,ymmword ptr[rdx+r11*4-8]
	vfmadd231ps ymm2,ymm0,ymm6

	vmovups	ymm1,ymmword ptr[rdx+r11*4-12]
	vfmadd231ps ymm3,ymm1,ymm7

	vmovups	ymm0,ymmword ptr[rdx+r11*4-16]
	vfmadd231ps ymm2,ymm0,ymm8

	vaddps	ymm0,ymm2,ymm3
	vmovaps	ymmword ptr[rcx+rax*4],ymm0

	add		rax,8
	cmp		rax,r8
	jl  	@B

	mov		eax,1
RETURN:
_DeleteFrame2 macro
	vzeroupper
	vmovapd xmm6,xmmword ptr[rbp-30h]
	vmovapd xmm7,xmmword ptr[rbp-20h]
	vmovapd xmm8,xmmword ptr[rbp-10h]
	mov		rsp,rbp
	pop		rbp
endm
	_DeleteFrame2
	ret
Convolve2Ks5_ endp
;Convolve2Ks5Test_ proc ; (float *y, const float *x, int32_t num_pts, const float *kernel, int32_t kernel_size) -> bool
;	ret
;Convolve2Ks5Test_ endp
END