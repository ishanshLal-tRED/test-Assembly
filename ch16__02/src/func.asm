
	.code

; (float *c, const float *a, const float *b, const size_t n)
_CalcResult_ macro MovInstr
; Load and validate
	xor		eax,eax
	test	r9,r9
	jz		RETURN
	test	r9,0fh
	jnz		RETURN
	
	test	rcx,1fh
	jnz		RETURN
	test	rdx,1fh
	jnz		RETURN
	test	r8,1fh
	jnz		RETURN

; calculate c[i] = sqrt(a[i]*a[i] + b[i]*b[i])
	align 16
@@:
	vmovaps	ymm0, ymmword ptr[rdx + rax]
	vmovaps	ymm1, ymmword ptr[r8  + rax]
	vmulps	ymm2,ymm0,ymm0
	vmulps	ymm3,ymm1,ymm1
	vaddps	ymm4,ymm2,ymm3
	vsqrtps	ymm5,ymm4
	MovInstr ymmword ptr[rcx+rax],ymm5

	vmovaps	ymm0, ymmword ptr[rdx+rax+32]
	vmovaps	ymm1, ymmword ptr[r8 +rax+32] 
	vmulps	ymm2,ymm0,ymm0
	vmulps	ymm3,ymm1,ymm1
	vaddps	ymm4,ymm2,ymm3
	vsqrtps	ymm5,ymm4
	MovInstr ymmword ptr[rcx+rax+32],ymm5

	add		rax,64
	sub		r9,16
	jnz		@B

	mov		eax,1
RETURN:
	vzeroupper
	ret
endm

CalcResultA_ proc 
	_CalcResult_ vmovaps
CalcResultA_ endp

CalcResultB_ proc 
	_CalcResult_ vmovntps
CalcResultB_ endp
	END