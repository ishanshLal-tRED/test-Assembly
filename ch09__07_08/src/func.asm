	.code
AVXBlendF32_ proc ; (const Unified<cnt_wid>*src1, const Unified<cnt_wid>*src2, const Unified<cnt_wid>*dest, const Unified<cnt_wid>*idx)
	
	vmovaps	ymm0,ymmword ptr[rcx] ; ymm0 = src1
	vmovaps	ymm1,ymmword ptr[rdx] ; ymm1 = src2
	vmovaps	ymm2,ymmword ptr[r9]  ; ymm2 = idx1

	vblendvps ymm3,ymm0,ymm1,ymm2
	vmovaps	ymmword ptr[r8],ymm3

RETURN:
	vzeroupper
	ret
AVXBlendF32_ endp
AVX2PermuteF32_ proc ; (const Unified<cnt_wid>*src1, const Unified<cnt_wid> *dest1, const Unified<cnt_wid> *idx1, const Unified<cnt_wid> *src2, const Unified<cnt_wid> *dest2, const Unified<cnt_wid> *idx2)
	
; perform vpermps permutation
	vmovaps	ymm0,ymmword ptr[rcx] ; load src1
	vmovdqa	ymm1,ymmword ptr[r8]  ; load idx1
	vpermps	ymm2,ymm1,ymm0
	vmovaps	ymmword ptr[rdx],ymm2 ; save dest1

; perform vpermilps permutation
	mov		rdx,[rsp+40] ; load location of dest2
	mov		r8,[rsp+48] ; load location of idx2

	vmovaps	ymm3,ymmword ptr[r9]  ; load src2
	vmovdqa	ymm4,ymmword ptr[r8]  ; load idx2
	vpermilps ymm5,ymm3,ymm4
	vmovaps	ymmword ptr[rdx],ymm5 ; save dest2

RETURN:
	vzeroupper
	ret
AVX2PermuteF32_ endp

AVX2Gather8xF32_I32_ proc ; (const float *, float *, int32_t* indices, const int32_t* masks);
	
	vmovups	ymm0,ymmword ptr[rdx]
	vmovdqu	ymm1,ymmword ptr[r8]
	vmovdqu	ymm2,ymmword ptr[r9]
	vpslld	ymm2,ymm2,31
	vgatherdps ymm0,[rcx+ymm1*4],ymm2
	vmovups	ymmword ptr[rdx],ymm0

	vzeroupper
	ret
AVX2Gather8xF32_I32_ endp
AVX2Gather8xF32_I64_ proc ; (const float *, float *, int64_t* indices, const int32_t* masks);
	
	vmovups	xmm0,xmmword ptr[rdx]
	vmovdqu	ymm1,ymmword ptr[r8]
	vmovdqu	xmm2,xmmword ptr[r9]
	vpslld	xmm2,xmm2,31
	vgatherqps xmm0,[rcx+ymm1*4],xmm2
	vmovups	xmmword ptr[rdx],xmm0
		
	vmovups	xmm3,xmmword ptr[rdx+10h]
	vmovdqu	ymm1,ymmword ptr[r8+20h]
	vmovdqu	xmm2,xmmword ptr[r9+10h]
	vpslld	xmm2,xmm2,31
	vgatherqps xmm3,[rcx+ymm1*4],xmm2
	vmovups	xmmword ptr[rdx+10h],xmm3

	vzeroupper
	ret
AVX2Gather8xF32_I64_ endp
AVX2Gather8xF64_I32_ proc ; (const double*, double*, int32_t* indices, const int64_t* masks);
	
	vmovupd	ymm0,ymmword ptr[rdx]
	vmovdqu	xmm1,xmmword ptr[r8]
	vmovdqu	ymm2,ymmword ptr[r9]
	vpsllq	ymm2,ymm2,63
	vgatherdpd ymm0,[rcx+xmm1*8],ymm2
	vmovupd	ymmword ptr[rdx],ymm0
		
	vmovupd	ymm3,ymmword ptr[rdx+20h]
	vmovdqu	xmm1,xmmword ptr[r8+10h]
	vmovdqu	ymm2,ymmword ptr[r9+20h]
	vpsllq	ymm2,ymm2,63
	vgatherdpd ymm3,[rcx+xmm1*8],ymm2
	vmovups	ymmword ptr[rdx+20h],ymm3
	
	ret
AVX2Gather8xF64_I32_ endp
AVX2Gather8xF64_I64_ proc ; (const double*, double*, int64_t* indices, const int64_t* masks);
	vmovupd	ymm0,ymmword ptr[rdx]
	vmovdqu	ymm1,ymmword ptr[r8]
	vmovdqu	ymm2,ymmword ptr[r9]
	vpsllq	ymm2,ymm2,63
	vgatherqpd ymm0,[rcx+ymm1*8],ymm2
	vmovupd	ymmword ptr[rdx],ymm0
		
	vmovupd	ymm3,ymmword ptr[rdx+20h]
	vmovdqu	ymm1,ymmword ptr[r8+20h]
	vmovdqu	ymm2,ymmword ptr[r9+20h]
	vpsllq	ymm2,ymm2,63
	vgatherqpd ymm3,[rcx+ymm1*8],ymm2
	vmovups	ymmword ptr[rdx+20h],ymm3

	ret
AVX2Gather8xF64_I64_ endp
	END