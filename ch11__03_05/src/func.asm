	.code
GprMulx_ proc ; (uint32_t a, uint32_t b, uint64_t flags[2]) -> uint64_t

	pushfq
	pop		rax ; pop the pushed EFLAGS register to rax
	mov		qword ptr[r8],rax ; copy it to ptr

	mulx	r11d, r10d,ecx ; note edx is one of the oprands that is multiplied with ecx, not r11d or r10d
	; low order result gor=es in r10d, high order result goes in r11d => ecx*edx = val[64:0] => r10d = val[31:0], r11d = val[63:32]
	
	pushfq
	pop		rax ; pop the pushed EFLAGS register to rax
	mov		qword ptr[r8+8],rax ; copy it to ptr

	mov		eax,r10d
	shl		r11,32
	or		rax,r11
	ret
GprMulx_ endp

GprShiftx_ proc ; (uint32_t x, uint32_t count, uint32_t results[3], uint64_t flags[4])
	
	pushfq
	pop		rax ; pop the pushed EFLAGS register to rax
	mov		qword ptr[r9],rax ; copy it to ptr

	sarx	eax,ecx,edx
	mov		dword ptr[r8],eax
	pushfq
	pop		rax
	mov		qword ptr[r9+8],rax
	

	shlx	eax,ecx,edx
	mov		dword ptr[r8+4],eax
	pushfq
	pop		rax
	mov		qword ptr[r9+10h],rax
	

	shrx	eax,ecx,edx
	mov		dword ptr[r8+8],eax
	pushfq
	pop		rax
	mov		qword ptr[r9+18h],rax


	mov		eax,r10d
	shl		r11,32
	or		rax,r11
	ret
GprShiftx_ endp

GprCountZeroBits_ proc ; (uint32_t x, uint32_t *lzcnt, uint32_t *tzcnt)
	
	lzcnt	eax,ecx
	mov		dword ptr[rdx],eax

	tzcnt	eax,ecx
	mov		dword ptr[r8],eax

	ret
GprCountZeroBits_ endp
GprBextr_ proc ; (uint32_t x, uint8_t start, uint8_t length) ->  uint32_t
	
	mov		al,r8b
	mov		ah,al		; ah = length
	mov		al,dl		; al = sart
	bextr	eax,ecx,eax

	ret
GprBextr_ endp
GprAndNot_ proc ; (uint32_t x, uint32_t y) -> uint32_t
	
	andn	eax,ecx,edx
	ret
GprAndNot_ endp

SingleToHalfPricision proc ; (float x_sp[8], uint16_t x_hp[8], int rc)
	vmovups	ymm0,ymmword ptr[rcx] ; Note atthe time of writing, i was using intel i3 5005u, i think that didn't support different rounding methods for half-floats Round-nearest

	cmp		r8d,0
	jne		@F
	vcvtps2ph xmm1,ymm0,0
	jmp		SaveResult

@@:
	cmp		r8d,1
	jne		@F
	vcvtps2ph xmm1,ymm0,1
	jmp		SaveResult

@@:
	cmp		r8d,2
	jne		@F
	vcvtps2ph xmm1,ymm0,2
	jmp		SaveResult
	
@@:
	cmp		r8d,3
	jne		@F
	vcvtps2ph xmm1,ymm0,3
	jmp		SaveResult

@@:
	vcvtps2ph xmm1,ymm0,4
	
SaveResult:
	vmovdqu xmmword ptr[rdx],xmm1
	vzeroupper
	ret
SingleToHalfPricision endp
HalfToSinglePricision proc ; (uint16_t x_hp[8], float x_sp[8])
	
	vcvtph2ps ymm0,xmmword ptr[rcx]
	vmovups	ymmword ptr[rdx],ymm0
	vzeroupper
	ret
HalfToSinglePricision endp
END