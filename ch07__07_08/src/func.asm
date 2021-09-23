
ITD struct
	PbSrc			QWORD ?
	PbMask			QWORD ?
	NumPixels		DWORD ?
	NumMaskedPixels	DWORD ?
	SumMaskedPixels	DWORD ?
	Threshold		BYTE  ?
	PAD				BYTE 3 dup(?)
	MeanMaskedPixels real8 ?
ITD ends
	
	.const
	align 16
PixelScale	byte 16 dup(80h)
CountPixelsMask	byte 16 dup(01h)
r8_MinusOne	real8 -1.0
	
	.code
	extern IsValid:proc
AVXBuildImageHistogram_ proc frame ; (const uint8_t* pixels, const size_t, uint32_t* histogram, uint32_t& max_ht)

NUMOFREGS = 4 ; rbx, rsi, rdi
STK_PAD = ((NUMOFREGS AND 1) XOR 1)*8
LOCAL0 = 1024 ; 256 * 4bytes
ALLOCATE = LOCAL0 + STK_PAD

; Usage Local variable -> [rbp-LOCAL0 + __variableNo.__0h] like [rbp-LOCAL0] 1st var or [rbp-LOCAL0 + 10h] for 2nd one ...
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx
	push	rsi
	.pushreg rsi
	push	rdi
	.pushreg rdi

	sub		rsp,ALLOCATE
	.allocstack ALLOCATE
	lea		rbp,[rsp+LOCAL0]
	.endprolog

	xor		eax,eax
	test	rdx,rdx
	jz		RETURN
	test	rdx,1fh
	jnz		RETURN

; Make sure hstogram & pixel_buff are aligned ; (const uint8_t* pixels, const size_t, uint32_t* histogram, uint32_t& max_ht)
	mov		rsi,rcx
	test	rsi,0fh
	jnz		RETURN
	test	r8,0fh
	jnz		RETURN


	xor		rax,rax ; TODO: check if i really want it or not
	mov		rdi,r8  ; histogram
	mov		rcx,128 ; copying qword not dword
	rep		stosq   ; repeat until (rcx counter reaches zero) {qword rax -> rdi; rdi += sizeof qword}
	
	mov		rdi,rbp ; Local0 vars
	sub		rdi,LOCAL0
	mov 	rcx,128
	rep		stosq
	mov		rcx,rdx

; rsi = &pixarr, rdi = &LOCAL0, rcx = pixarr_counter, r8 = &histogram, r9 = &max_ht
	mov		rdi,rbp
	sub		rdi,LOCAL0
	shr		rcx,5     ; div by 32 as we are processing in 32byte chunks

	align 16
@@:
	vmovdqa	xmm0,xmmword ptr[rsi]	 ; pixel block
	vmovdqa	xmm1,xmmword ptr[rsi+16] ; pixel block 

	vpextrb	rax,xmm0,0
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm0,1
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm0,2
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm0,3
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm0,4
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm0,5
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm0,6
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm0,7
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm0,8
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm0,9
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm0,10
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm0,11
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm0,12
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm0,13
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm0,14
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm0,15
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm1,0
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm1,1
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm1,2
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm1,3
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm1,4
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm1,5
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm1,6
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm1,7
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm1,8
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm1,9
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm1,10
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm1,11
	add		dword ptr[rdi+r11*4],1

	vpextrb	rax,xmm1,12
	add		dword ptr[rdi+rax*4],1
	vpextrb	rbx,xmm1,13
	add		dword ptr[rdi+rbx*4],1
	vpextrb	r10,xmm1,14
	add		dword ptr[rdi+r10*4],1
	vpextrb	r11,xmm1,15
	add		dword ptr[rdi+r11*4],1

	add		rsi,32
	sub		rcx,1
	jnz		@B

	mov		eax,1
	mov		rcx,64 ; 64*4-dword = 256
	mov		rsi,rbp
	sub		rsi,LOCAL0
	vpxor	xmm1,xmm1,xmm1
@@:
	vmovdqa	xmm0,xmmword ptr[rsi]
	vmovdqa	xmmword ptr[r8],xmm0
	vpmaxsd	xmm1,xmm0,xmm1
	
	add		rsi,16
	add		r8,16
	dec		rcx
	jnz		@B

	vmovdqa	xmm2,xmm1
	vpsrldq	xmm3,xmm2,8
	vpmaxsd	xmm4,xmm1,xmm3
	vpextrd	rcx,xmm4,0
	vpextrd	rdx,xmm4,1
	cmp		rcx,rdx
	cmovb	rcx,rdx
	mov		[r9],ecx
RETURN:
	;lea		rbp,[rsp-LOCAL0]
	;add		rsp,ALLOCATE
	;; OR
	lea		rsp,[rbp+STK_PAD] ; as we are restoring rbp anyway ; we can even wrap it in IF(STK_PAD GT 0)...ELSE...ENDIF block for even less overhead
	pop		rdi
	pop		rsi
	pop		rbx
	pop		rbp

	ret	
AVXBuildImageHistogram_ endp

AVXThresholdImage_  proc frame ; (ITD*) -> bool

NUMOFREGS = 2 ; rbx
STK_PAD = ((NUMOFREGS AND 1) XOR 1)*8
ALLOCATE = STK_PAD

; Usage Local variable -> [rbp-LOCAL0 + __variableNo.__0h] like [rbp-LOCAL0] 1st var or [rbp-LOCAL0 + 10h] for 2nd one ...
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx

	sub		rsp,ALLOCATE
	.allocstack ALLOCATE
	mov		rbp, rsp
	.endprolog

	mov		rbx,rcx
	mov 	ecx,[rbx+ITD.NumPixels]
	mov 	rdx,[rbx+ITD.PbSrc]
	mov 	r8,[rbx+ITD.PbMask]
	sub		rsp,32 ; Allocate home area for IsValid
	call	IsValid; (uint32_t num_pixels, const uint8_t *pb_src, const uint8_t *pb_mask)
	or		al,al
	jz		RETURN

	mov		ecx,[rbx+ITD.NumPixels]
	shr		ecx,6 ; process in 64byte chunks
	mov		rdx,[rbx+ITD.PbSrc]
	mov		r8,[rbx+ITD.PbMask]

	movzx	r9d,byte ptr[rbx+ITD.Threshold]
	vmovd	xmm1,r9d
	vpxor	xmm0,xmm0,xmm0
	vpshufb	xmm1,xmm1,xmm0

	vmovdqa	xmm4,xmmword ptr[PixelScale]
	vpsubb	xmm5,xmm1,xmm4

@@:
	vmovdqa	xmm0,xmmword ptr[rdx]
	vpsubb	xmm1,xmm0,xmm4
	vpcmpgtb xmm2,xmm1,xmm5
	vmovdqa	xmmword ptr[r8],xmm2
	
	vmovdqa	xmm0,xmmword ptr[rdx+16]
	vpsubb	xmm1,xmm0,xmm4
	vpcmpgtb xmm2,xmm1,xmm5
	vmovdqa	xmmword ptr[r8+16],xmm2

	vmovdqa	xmm0,xmmword ptr[rdx+32]
	vpsubb	xmm1,xmm0,xmm4
	vpcmpgtb xmm2,xmm1,xmm5
	vmovdqa	xmmword ptr[r8+32],xmm2

	vmovdqa	xmm0,xmmword ptr[rdx+48]
	vpsubb	xmm1,xmm0,xmm4
	vpcmpgtb xmm2,xmm1,xmm5
	vmovdqa	xmmword ptr[r8+48],xmm2

	add		rdx,64
	add		r8,64
	sub		ecx,1
	jnz		@B

	mov		al,1

RETURN:
	lea		rsp,[rbp+STK_PAD]
	pop		rbx
	pop		rbp

	ret	
AVXThresholdImage_  endp

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
AVXCalcImageMean_   proc frame ; (ITD* itd) -> bool

NUMOFREGS = 2 ; rbx, rsi, rdi
STK_PAD = ((NUMOFREGS AND 1) XOR 1)*8
LOCAL0 = 64 ; 256 * 4bytes
ALLOCATE = LOCAL0 + STK_PAD

; Usage Local variable -> [rbp-LOCAL0 + __variableNo.__0h] like [rbp-LOCAL0] 1st var or [rbp-LOCAL0 + 10h] for 2nd one ...
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx

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

	mov		rbx,rcx
	mov 	ecx,[rbx+ITD.NumPixels]
	mov 	rdx,[rbx+ITD.PbSrc]
	mov 	r8 ,[rbx+ITD.PbMask]
	sub		rsp,32 ; Allocate home area for IsValid
	call	IsValid; (uint32_t num_pixels, const uint8_t *pb_src, const uint8_t *pb_mask)
	or		al ,al
	jz		RETURN
;Setup for loop
	mov		ecx,[rbx+ITD.NumPixels]
	shr		ecx,6 ; 64bytes chunks
	mov		rdx,[rbx+ITD.PbSrc]
	mov		r8 ,[rbx+ITD.PbMask]

	vmovdqa	xmm8,xmmword ptr[CountPixelsMask]
	vpxor	xmm9,xmm9,xmm9

	xor		r10d,r10d
	vpxor	xmm5,xmm5,xmm5

LP1:
	vpxor	xmm6,xmm6,xmm6
	vpxor	xmm7,xmm7,xmm7

	_UpdateBlockSums 0
	_UpdateBlockSums 16
	_UpdateBlockSums 32
	_UpdateBlockSums 48

	vpsrldq	xmm0,xmm6,8
	vpaddb	xmm6,xmm6,xmm0
	vpsrldq	xmm0,xmm6,4
	vpaddb	xmm6,xmm6,xmm0
	vpsrldq	xmm0,xmm6,2
	vpaddb	xmm6,xmm6,xmm0
	vpsrldq	xmm0,xmm6,1
	vpaddb	xmm6,xmm6,xmm0
	vpextrb	eax,xmm6,0
	add 	r10d,eax

; Update sum_masked_pixels
	vpunpcklwd xmm0,xmm7,xmm9
	vpunpckhwd xmm1,xmm7,xmm9
	vpaddd	xmm5,xmm5,xmm0
	vpaddd	xmm5,xmm5,xmm1

	add		rdx,64
	add		r8,64
	sub		rcx,1
	jnz		LP1

; Compute mean
	vphaddd	xmm0,xmm5,xmm5
	vphaddd	xmm1,xmm0,xmm0
	vmovd	eax,xmm1

	test	r10d,r10d
	jz		NoMean
	vcvtsi2sd xmm0,xmm0,eax
	vcvtsi2sd xmm1,xmm1,r10d
	vdivsd	xmm2,xmm0,xmm1
	jmp		@F
;ITD struct
;	PbSrc			QWORD ?
;	PbMask			QWORD ?
;	NumPixels		DWORD ?
;	NumMaskedPixels	DWORD ?
;	SumMaskedPixels	DWORD ?
;	Threshold		BYTE  ?
;	PAD				BYTE 3 dup(?)
;	MeanMaskedPixels real8 ?

NoMean:
	vmovsd	xmm2,[r8_MinusOne]
@@:
	mov		[rbx+ITD.SumMaskedPixels],eax
	mov		[rbx+ITD.NumMaskedPixels],r10d
	vmovsd	[rbx+ITD.MeanMaskedPixels],xmm2
	mov		eax,1

RETURN:
	vmovdqa	xmm6,xmmword ptr[rbp-LOCAL0]
	vmovdqa	xmm7,xmmword ptr[rbp-LOCAL0+10h]
	vmovdqa	xmm8,xmmword ptr[rbp-LOCAL0+20h]
	vmovdqa	xmm9,xmmword ptr[rbp-LOCAL0+30h]

	lea		rsp,[rbp+STK_PAD] ; as we are restoring rbp anyway ; we can even wrap it in IF(STK_PAD GT 0)...ELSE...ENDIF block for even less overhead
	pop		rbx
	pop		rbp

	ret	
AVXCalcImageMean_  endp
	END