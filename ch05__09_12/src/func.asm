

	.const
TestVal db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
r8_pi	real8 3.14159265358979323846
r8_3	real8 3.0
	.code
ComputeSum_ proc frame ; (uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t) -> uint64_t

	push	rbp
	.pushreg rbp

	sub		rsp, 16 ; allocate stack
	.allocstack 16

	mov		rbp, rsp ; setrame poiter
	.setframe rbp, 0

RSP_LAO = 24 ; RegisterStackPointer Last address offset = Allocated_stack + saves[rbp]
	.endprolog

	mov		[rsp+RSP_LAO+8] , rcx ; save in home
	mov		[rsp+RSP_LAO+16], rdx ; save in home
	mov		[rsp+RSP_LAO+24], r8  ; save in home
	mov		[rsp+RSP_LAO+32], r9  ; save in home

	movsxd	rcx,ecx
	movsxd	rdx,edx
	movsxd	r8,r8d
	movsxd	r9,r9d

	xor		rax,rax
	mov		qword ptr[rsp],rax ; make 0
	mov		rax,qword ptr[rsp]

	add		r9,rcx
	add		r9,rdx
	add		r9,r8
	add		qword ptr[rbp],r9

	mov		rax,qword ptr[rsp]
	
	movsxd	rcx, dword ptr[rbp+RSP_LAO+40]
	movsxd	rdx, dword ptr[rbp+RSP_LAO+48]
	movsxd	r8, dword ptr[rbp+RSP_LAO+56]
	movsxd	r9, dword ptr[rbp+RSP_LAO+64]
	
	add		qword ptr[rbp],rcx
	add		qword ptr[rbp],rdx
	add		qword ptr[rbp],r8
	add		qword ptr[rbp],r9

	mov		rax,[rsp]
; Done
	add		rsp,16
	pop		rbp
	ret
ComputeSum_ endp

ComputeSumPdt_ proc frame ;  (int64_t*, int64_t*, int64_t, int64_t*, int64_t*, int64_t*, int64_t*) -> bool
						  ;       rcx ,     rdx ,    r8  ,     r9  ,[i_rsp+40],[i_rsp+48],[i_rsp+56] -> al
; Named expressions for constant values:
;
; NUM_PUSHREG = number of prolog non-volatile register pushes
; STK_LOCAL1 = size in bytes of STK_LOCAL1 area (see figure in text)
; STK_LOCAL2 = size in bytes of STK_LOCAL2 area (see figure in text)
; STK_PAD = extra bytes (0 or 8) needed to 16-byte align RSP
; STK_TOTAL = total size in bytes of local stack
; RBP_RA = number of bytes between RBP and ret addr on stack

NUM_PUSHREG = 4
STK_LOCAL1  = 32
STK_LOCAL2  = 32
STK_PAD	    = ((NUM_PUSHREG AND 1) XOR 1) * 8
STK_TOTAL   = STK_LOCAL1 + STK_LOCAL2 + STK_PAD
RBP_RA      = NUM_PUSHREG * 8 + STK_LOCAL1 + STK_PAD
	
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx
	push	r12
	.pushreg r12
	push	r13
	.pushreg r13

	sub		rsp, STK_TOTAL
	.allocstack STK_TOTAL

	lea		rbp, [rsp+STK_LOCAL2] ; stack frame
	.setframe rbp, STK_LOCAL2
	.endprolog

; Initialize local variables on the stack (dummy local varables, for demonstration only)
	vmovdqu	xmm5, xmmword ptr[TestVal]
	vmovdqa	xmmword ptr[rbp-16],xmm5  ; save xmm5 to LocalVar2A/2B
	mov		qword ptr [rbp],0aah       ; save 0xAA to LocalVar1A
	mov		qword ptr [rbp+8],0bbh     ; save 0xBB to LocalVar1B
	mov		qword ptr [rbp+16],0cch    ; save 0xCC to LocalVar1C
	mov		qword ptr [rbp+24],0ddh    ; save 0xDD to LocalVar1D

; Save argument values to home area (optional)
	mov		qword ptr [rbp+RBP_RA+8] ,rcx
	mov		qword ptr [rbp+RBP_RA+16],rdx
	mov		qword ptr [rbp+RBP_RA+24],r8
	mov		qword ptr [rbp+RBP_RA+32],r9

; Perform required initializations for processing loop
	test	r8d, r8d             ; is arr_length <=0
	jle		InvalidArg;

	xor		rbx,rbx
	xor		r10,r10
	xor		r11,r11
	xor		r12,1
	xor		r13,1

; Compute the sum's and pdt's
@@:
	mov		rax,[rcx+rbx]        ; rax = a[i]
	add		r10,rax
	imul	r12,rax
	mov 	rax,[rdx+rbx]        ; rax = b[i]
	add		r11,rax
	imul	r13,rax
	
	add		rbx, 8              ; next element
	dec		r8d
	jnz		@B                  ; NOTE this

; Save
	mov		[r9],r10
	mov		rax,[rbp+RBP_RA+40]
	mov		[rax],r11
	mov		rax,[rbp+RBP_RA+48]
	mov		[rax],r12
	mov		rax,[rbp+RBP_RA+56]
	mov		[rax],r13
	mov		al,1

Done:
	lea		rsp, [rbp+STK_LOCAL1+STK_PAD]   ; restore rsp
	pop		r13
	pop		r12
	pop		rbx
	pop		rbp
	ret

InvalidArg:
	xor		al,al
	jmp		Done

ComputeSumPdt_ endp

ComputeConesSAandVol proc frame ; (const double *, const double *, int32_t, double *, double *) -> bool
								;        rcx     ,       rdx     ,    r8d ,    r9   ,[rsp+RSP_RA+40]->al
NUM_PUSHREG = 7
STK_LOCAL1  = 16
STK_LOCAL2  = 64
STK_PAD	    = ((NUM_PUSHREG AND 1) XOR 1) * 8
STK_TOTAL   = STK_LOCAL1 + STK_LOCAL2 + STK_PAD
RBP_RA      = NUM_PUSHREG * 8 + STK_LOCAL1 + STK_PAD

; Save
	push	rbp
	.pushreg rbp
	push	rbx
	.pushreg rbx
	push	rsi
	.pushreg rsi
	push	r12
	.pushreg r12
	push	r13
	.pushreg r13
	push	r14
	.pushreg r14
	push	r15
	.pushreg r15

; Allocate stk
	sub		rsp,STK_TOTAL
	.allocstack STK_TOTAL
	lea		rbp,[rsp+STK_LOCAL2]
	.setframe rbp,STK_LOCAL2

; Using stk_Local2 (64bytes) for storing xmm12 - xmm15 orignal values
	vmovdqa	xmmword ptr[rbp-STK_LOCAL2],xmm12 ; vector move double quad-word aligned
	.savexmm128 xmm12,0
	vmovdqa	xmmword ptr[rbp-STK_LOCAL2+16],xmm13 ; vector move double quad-word aligned
	.savexmm128 xmm13,16
	vmovdqa	xmmword ptr[rbp-STK_LOCAL2+32],xmm14 ; vector move double quad-word aligned
	.savexmm128 xmm14,32
	vmovdqa	xmmword ptr[rbp-STK_LOCAL2+48],xmm15 ; vector move double quad-word aligned
	.savexmm128 xmm15,48
	.endprolog

; Demonstrating use of STK_local1 (16bytes) for local variables
	mov		qword ptr[rbp],-1
	mov		qword ptr[rbp+8],-2

; register initialization below 

; Initialize the processing loop variables
	mov		esi,r8d
	test	esi,esi
	jg		@F

	xor		al,al
	jmp		Done

; Overuse of registers
@@:
	xor		rbx,rbx
	mov		r12,rcx
	mov		r13,rdx
	mov		r14,r9
	mov		r15,[rbp+RBP_RA+40]
	vmovsd	xmm14, real8 ptr[r8_pi]
	vmovsd	xmm15, real8 ptr[r8_3]

; SA = pi*r*(r + sqrt(r*r + h*h))
; VOL= pi * r*r * h/3.0
@@:
	vmovsd	xmm0, real8 ptr [r12+rbx]
	vmovsd	xmm1, real8 ptr [r13+rbx]
	vmovsd	xmm12,xmm12,xmm0
	vmovsd	xmm13,xmm13,xmm1

	vmulsd	xmm0,xmm0,xmm0
	vmulsd	xmm1,xmm1,xmm1
	vaddsd	xmm0,xmm0,xmm1

	vsqrtsd	xmm0,xmm0,xmm0
	vaddsd	xmm0,xmm0,xmm12
	vmulsd	xmm0,xmm0,xmm12
	vmulsd	xmm0,xmm0,xmm14

	vmulsd	xmm12,xmm12,xmm12
	vmulsd	xmm13,xmm13,xmm14
	vmulsd	xmm13,xmm13,xmm12
	vdivsd	xmm13,xmm13,xmm15

	vmovsd	real8 ptr[r14+rbx],xmm0	 ; save
	vmovsd	real8 ptr[r15+rbx],xmm13 ; save

	add		rbx,8
	dec		esi
	jnz		@B

	mov		al,1

; Epilog/Restore-registers
Done:
	vmovdqa	xmm12,xmmword ptr[rbp-STK_LOCAL2]
	vmovdqa	xmm15,xmmword ptr[rbp-STK_LOCAL2+16]
	vmovdqa	xmm15,xmmword ptr[rbp-STK_LOCAL2+32]
	vmovdqa	xmm15,xmmword ptr[rbp-STK_LOCAL2+48]

	lea		rsp,[rbp+STK_LOCAL1+STK_PAD]
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rsi
	pop		rbx
	pop		rbp
	ret
ComputeConesSAandVol endp
	END