	
	include <cmp_equ.asmh>

MxcsrRcMask  equ 9FFFh ; bit pattern for MXCSR.RC
MxcsrRcShift equ 13    ; shift count for MXCSR.RC

	.const
AbsMaskF32	dword	7fffffffh, 7fffffffh, 7fffffffh, 7fffffffh
AbsMaskF64	qword	7fffffffffffffffh, 7fffffffffffffffh

	.code

AVXPackedMathF32_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
					   ;          rcx  ,         rdx  ,  r8     ; Note: refrence is just a pointer
	vmovaps	xmm0, xmmword ptr[rcx] ; vector mov aligned packed single-precision
	vmovaps	xmm1, xmmword ptr[rdx] ; vector mov aligned packed single-precision
	
; Packed SPFP addition
	vaddps	xmm2,xmm0,xmm1
	vmovaps	[r8],xmm2
; Packed SPFP subtraction
	vsubps	xmm2,xmm0,xmm1
	vmovaps	[r8+16],xmm2
; Packed SPFP multiplication
	vmulps	xmm2,xmm0,xmm1
	vmovaps	[r8+32],xmm2
; Packed SPFP division
	vdivps	xmm2,xmm0,xmm1
	vmovaps	[r8+48],xmm2
; Packed SPFP absolute (for b)
	vandps	xmm2,xmm1,xmmword ptr[AbsMaskF32];
	vmovaps	[r8+64],xmm2
; Packed SPFP sqrt (of a)
	vsqrtps	xmm2,xmm0
	vmovaps	[r8+80],xmm2
; Packed SPFP min
	vminps	xmm2,xmm0,xmm1
	vmovaps	[r8+96],xmm2
; Packed SPFP max
	vmaxps	xmm2,xmm0,xmm1
	vmovaps	[r8+112],xmm2
;Done:
	ret
AVXPackedMathF32_ endp
AVXPackedMathF64_ proc ; (const XmmVal&, const XmmVal&, XmmVal*)
					   ;         rcx ,       rdx     ,    r8
	vmovapd	xmm0, xmmword ptr[rcx] ; vector mov aligned packed double-precision
	vmovapd	xmm1, xmmword ptr[rdx] ; vector mov aligned packed double-precision
	
; Packed DPFP addition
	vaddpd	xmm2,xmm0,xmm1
	vmovapd	[r8],xmm2
; Packed DPFP subtraction
	vsubpd	xmm2,xmm0,xmm1
	vmovapd	[r8+16],xmm2
; Packed DPFP multiplication
	vmulpd	xmm2,xmm0,xmm1
	vmovapd	[r8+32],xmm2
; Packed DPFP division
	vdivpd	xmm2,xmm0,xmm1
	vmovapd	[r8+48],xmm2
; Packed DPFP absolute (for b)
	vandpd	xmm2,xmm1,xmmword ptr[AbsMaskF32];
	vmovapd	[r8+64],xmm2
; Packed DPFP sqrt (of a)
	vsqrtpd	xmm2,xmm0
	vmovapd	[r8+80],xmm2
; Packed DPFP min
	vminpd	xmm2,xmm0,xmm1
	vmovapd	[r8+96],xmm2
; Packed DPFP max
	vmaxpd	xmm2,xmm0,xmm1
	vmovapd	[r8+112],xmm2
;Done:
	ret
AVXPackedMathF64_ endp

AvxPackedCampareF32_ proc ; (const XmmVal &, const XmmVal &, XmmVal *)
						  ;        rcx     ,        rdx    ,   r8
	movaps	xmm0, xmmword ptr[rcx]
	movaps	xmm1, xmmword ptr[rdx]

; perform Packed EQUAL campare
	vcmpps	xmm2,xmm0,xmm1,CMP_EQ
	vmovdqa	xmmword ptr[r8],xmm2
; perform Packed NOT EQUAL campare
	vcmpps	xmm2,xmm0,xmm1,CMP_NEQ
	vmovdqa	xmmword ptr[r8+16],xmm2
; perform Packed LESS THAN campare
	vcmpps	xmm2,xmm0,xmm1,CMP_LT
	vmovdqa	xmmword ptr[r8+32],xmm2
; perform Packed LESS THAN OR EQUAL campare
	vcmpps	xmm2,xmm0,xmm1,CMP_LE
	vmovdqa	xmmword ptr[r8+48],xmm2
; perform Packed GREATER THAN campare
	vcmpps	xmm2,xmm0,xmm1,CMP_GT
	vmovdqa	xmmword ptr[r8+64],xmm2
; perform Packed GREATER THAN OR EQUAL campare
	vcmpps	xmm2,xmm0,xmm1,CMP_GE
	vmovdqa	xmmword ptr[r8+80],xmm2
; perform Packed ORDERED campare
	vcmpps	xmm2,xmm0,xmm1,CMP_ORD
	vmovdqa	xmmword ptr[r8+96],xmm2
; perform Packed UNORDERED campare
	vcmpps	xmm2,xmm0,xmm1,CMP_UNORD
	vmovdqa	xmmword ptr[r8+112],xmm2
	ret
AvxPackedCampareF32_ endp
AvxPackedCampareF64_ proc ; (const XmmVal &, const XmmVal &, XmmVal *)
						  ;        rax     ,        rdx    ,   r8
	movapd	xmm0, xmmword ptr[rcx]
	movapd	xmm1, xmmword ptr[rdx]

; perform Packed EQUAL campare
	vcmppd	xmm2,xmm0,xmm1,CMP_EQ
	vmovdqa	xmmword ptr[r8],xmm2

; perform Packed NOT EQUAL campare
	vcmppd	xmm2,xmm0,xmm1,CMP_NEQ
	vmovdqa	xmmword ptr[r8+16],xmm2

; perform Packed LESS THAN campare
	vcmppd	xmm2,xmm0,xmm1,CMP_LT
	vmovdqa	xmmword ptr[r8+32],xmm2

; perform Packed LESS THAN OR EQUAL campare
	vcmppd	xmm2,xmm0,xmm1,CMP_LE
	vmovdqa	xmmword ptr[r8+48],xmm2

; perform Packed GREATER THAN campare
	vcmppd	xmm2,xmm0,xmm1,CMP_GT
	vmovdqa	xmmword ptr[r8+64],xmm2

; perform Packed GREATER THAN OR EQUAL campare
	vcmppd	xmm2,xmm0,xmm1,CMP_GE
	vmovdqa	xmmword ptr[r8+80],xmm2

; perform Packed ORDERED campare
	vcmppd	xmm2,xmm0,xmm1,CMP_ORD
	vmovdqa	xmmword ptr[r8+96],xmm2

; perform Packed UNORDERED campare
	vcmppd	xmm2,xmm0,xmm1,CMP_UNORD
	vmovdqa	xmmword ptr[r8+112],xmm2

	ret
AvxPackedCampareF64_ endp

GetMxcsrRoundingMode_ proc
	vstmxcsr dword ptr [rsp+8] ; save mxcsr register to eax
	mov		eax,[rsp+8]
	shr		eax, MxcsrRcShift  ; so that eax[1:0] = MXCSR.RC bits
	and		eax, 3             ; maskout unwanted bits
	ret
GetMxcsrRoundingMode_ endp

SetMxcsrRoundingMode_ proc
	and		ecx, 3
	shl		ecx, MxcsrRcShift

	vstmxcsr dword ptr [rsp+8] ; save(or set eax) mxcsr register to eax
	mov		eax,[rsp+8]
	and		eax,MxcsrRcMask    ; mask out old MXCSR.RC bits
	or		eax,ecx

	mov		[rsp+8],eax
	vldmxcsr dword ptr [rsp+8] ; load mxcsr register from eax
	ret
SetMxcsrRoundingMode_ endp

ConvertPackedScaler_ proc ; (XmmVal *a, CvtOp a_typ, XmmVal *b, uint32_t arr_length = 1) -> void
						  ;    rcx    ,   dl       ,      r8  ,         r9d
	mov		eax, dword ptr[rsp+56]	
	test	eax, eax

	je		RETURN

	movsx	rax, dl
	mov		rdx, r8

	movsxd	r9,r9d
@@:
	; vmovdqa	xmm0, xmmword ptr[rcx] ; Note: i was wrong, right one is -> vector move doubleword quad aligned
	jmp		[JmpMAP+rax*8]
I32_F32	:
	vmovdqa	xmm0, xmmword ptr[rcx]
	vcvtdq2ps xmm1, xmm0
	vmovaps	xmmword ptr[rdx],xmm1
	jmp		CVT_DONE;
I32_F64_:
	vmovdqa	xmm0, xmmword ptr[rcx]
	vcvtdq2pd xmm1, xmm0
	vmovapd	xmmword ptr[rdx],xmm1
	jmp		CVT_DONE;
F32_I32	:
	vmovaps	xmm0, xmmword ptr[rcx]
	vcvtps2dq xmm1, xmm0
	vmovdqa	xmmword ptr[rdx],xmm1
	jmp		CVT_DONE;
F32_F64_:
	vmovaps	xmm0, xmmword ptr[rcx]
	vcvtps2pd xmm1, xmm0
	vmovapd	xmmword ptr[rdx],xmm1
	jmp		CVT_DONE;
F64_I32	:
	vmovapd	xmm0, xmmword ptr[rcx]
	vcvtpd2dq xmm1, xmm0
	vmovdqa	xmmword ptr[rdx],xmm1
	jmp		CVT_DONE;
F64_F32	:
	vmovapd	xmm0, xmmword ptr[rcx]
	vcvtpd2ps xmm1, xmm0
	vmovaps	xmmword ptr[rdx],xmm1
	;jmp		CVT_DONE;
CVT_DONE:
	dec		r9d
	add		rcx, 16
	add		rdx, 16
	test	r9d, r9d
	jne		@B
RETURN:
	ret

	align 8
JmpMAP equ $
	qword I32_F32
	qword I32_F64_
	qword F32_I32
	qword F32_F64_
	qword F64_I32
	qword F64_F32

ConvertPackedScaler_ endp
	END