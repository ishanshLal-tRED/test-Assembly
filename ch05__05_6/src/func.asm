; For x64-bit system
include <cmp_equ.asmh>

MxcsrRcMask  equ 9FFFh ; bit pattern for MXCSR.RC
MxcsrRcShift equ 13    ; shift count for MXCSR.RC
	.code
CompareVCMPSD_ proc ; (double, double, bool*) -> void
					;    xmm0,   xmm1,   r8

	vcmpsd	xmm2, xmm0, xmm1, CMP_UNORD
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8 ; bool = 1 byte

	vcmpsd	xmm2, xmm0, xmm1, CMP_ORD
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8
	
	vcmpsd	xmm2, xmm0, xmm1, CMP_LT
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpsd	xmm2, xmm0, xmm1, CMP_LE
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpsd	xmm2, xmm0, xmm1, CMP_EQ
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpsd	xmm2, xmm0, xmm1, CMP_NEQ
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpsd	xmm2, xmm0, xmm1, CMP_GT
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpsd	xmm2, xmm0, xmm1, CMP_GE
	vmovq	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	;inc		r8
RETURN:
	ret
CompareVCMPSD_ endp


CompareVCMPSS_ proc ; ( float,  float, bool*) -> void
					;    xmm0,   xmm1,   r8

	vcmpss	xmm2, xmm0, xmm1, CMP_UNORD
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8 ; bool = 1 byte

	vcmpss	xmm2, xmm0, xmm1, CMP_ORD
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8
	
	vcmpss	xmm2, xmm0, xmm1, CMP_LT
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpss	xmm2, xmm0, xmm1, CMP_LE
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpss	xmm2, xmm0, xmm1, CMP_EQ
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpss	xmm2, xmm0, xmm1, CMP_NEQ
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpss	xmm2, xmm0, xmm1, CMP_GT
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	inc		r8

	vcmpss	xmm2, xmm0, xmm1, CMP_GE
	vmovd	rax, xmm2
	and		al, 1
	mov		byte ptr[r8], al
	;inc		r8
RETURN:
	ret
CompareVCMPSS_ endp


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

ConvertScaler_ proc frame; (64bit_data *, uint8_t, 64bit_data *, uint8_t, uint32_t) -> void
						 ;       rcx    ,   dl   ,      r8     ,    r9b , [rsp+56]
	push	rdi
	.pushreg rdi
	push	rsi
	.pushreg rsi
	.endprolog

	mov		eax, dword ptr[rsp+56]	
	test	eax, eax

	je		RETURN

	mov		rsi, rcx
	mov		rdi, r8
	movsx	r10, dl
	movsx	r11, r9b
	mov		ecx, eax 

	shl 	r10,4 ; multiply by 16
	shl 	r11,4 ; multiply by 16
           ; rax, xmm0 will store converted vals of src
           ; src -> rax && xmm0 -> rax || xmm0 ->  dest
@@:        ; registers: rdi,rsi,r10,r11, eax,xmm0
	
	jmp		[JmpMAP+r10]
SRC_I32:
	mov		rax, qword ptr[rsi]
	movsxd	rax,eax
	vcvtsi2sd xmm0,xmm0,eax
	jmp		[JmpMAP+r11+8]
SRC_I64:
	mov		rax, qword ptr[rsi]
	vcvtsi2sd xmm0,xmm0,rax
	jmp		[JmpMAP+r11+8]
SRC_F32:
	vmovss	xmm0,real4 ptr[rsi]
	vcvtss2si rax,xmm0
	vcvtss2sd xmm0,xmm0,xmm0
	jmp		[JmpMAP+r11+8]
SRC_F64:
	vmovsd	xmm0,real8 ptr[rsi]
	vcvtsd2si rax,xmm0
	jmp		[JmpMAP+r11+8]
; SRC_DONE
DEST_I32:
	mov		dword ptr[rdi], eax
	jmp DEST_DONE
DEST_I64:
	mov		qword ptr[rdi], rax
	jmp DEST_DONE
DEST_F32:
	vcvtsd2ss xmm1,xmm1,xmm0
	vmovss	real4 ptr[rdi], xmm1
	jmp DEST_DONE
DEST_F64:
	vmovsd	real8 ptr[rdi], xmm0
DEST_DONE:
	dec		ecx
	add		rsi, 8
	add		rdi, 8
	test	ecx, ecx
	jne		@B

RETURN:
	pop rsi
	pop rdi
	ret

	align 8
JmpMAP equ $
	qword SRC_I32, DEST_I32
	qword SRC_I64, DEST_I64
	qword SRC_F32, DEST_F32
	qword SRC_F64, DEST_F64

ConvertScaler_ endp
	END