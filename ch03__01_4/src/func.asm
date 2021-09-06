; For x64-bit system

TestStruct struct
	val8_t		byte	?
	__pad8_t	byte	?
	ival16_t	word	?
	val32_t		dword	?
	ival64_t	qword	?
TestStruct ends

	.const
MinusOne dword -1
	.data
	.code

SumAndSqrs_ PROC frame ; (int32_t*, int32_t*, int32_t*, int32_t*, int64_t) -> bool ; stack frame directive
					 ;      rcx ,     rdx ,     r8  ,     r9  , [rsp+56] ->  al
	; rdi, rsi are non-volatile registers, which means they may cantain critical data for program to work
	; so save them, them, and at end restore, {Volatile registers are: rax, rcx, rdx, r8, r9, r10, r11}
	push rdi ; push to stack
	.pushreg rdi ; remember rdi is pushed
	push rsi
	.pushreg rsi

	; Since we pushed 2 registers
	; => stack has grown by 16 bytes, => [8(rdi-old), 8(rsi-old), 8(rcx-home), 8(rdx-home), 8(r8-home), 8(r9-home), stack start...] = 48
	; little endian says data starts at +8...0, that's where 56 comes from

	.endprolog ; End of function prolouge; makes me reminder to stories that have a prolouge
; Is valid 
	xor		rax, rax
	cmp		rcx, 0
	je		InvalidParam
	cmp		rdx, 0
	je		InvalidParam
	cmp		r8, 0
	je		InvalidParam
	cmp		r9, 0
	je		InvalidParam
	cmp		qword ptr[rsp+56], 0
	jle		InvalidParam

; Loop
	mov 	rsi, rcx
	mov 	rdi, rdx
	xor		rcx, rcx ; for counter
	mov		rdx, qword ptr[rsp+56]; for limiter
	mov		dword ptr[r8], 0
	mov		dword ptr[r9], 0
@@:
; sqr_arr = rdi, arr = rsi
; sqr_arr[i] = arr[i]*arr[i] 

	mov		eax, dword ptr[rsi + rcx*4] ; 
; [r8] += arr[i]					    ; I think doing		 add		rsi, 4
	add		dword ptr[r8], eax		    ; will be better than
									    ; using counter for [rsi + rcx*4]
	imul	eax, eax				    ; as it is evaluated every time
									    ;
	mov		dword ptr[rdi + rcx*4], eax ;
; [r9] += sqr_arr[i]
	add		dword ptr[r9], eax

	inc		rcx
	cmp		rcx, rdx
	jl		@B

	mov		al,1 ; Sucess

InvalidParam:

	pop		rsi; Note Order
	pop		rdi
	ret

SumAndSqrs_ ENDP

TransposeSqrMat_ PROC; (int32_t* src, int32_t size) -> bool
					 ;         rcx  ,       edx

; isValid
	xor		rax, rax
	cmp		rcx, 0
	je InvalidParam
	cmp		edx, 1
	jle InvalidParam

; r10d => i, r11d => j, r8 => src, ecx => size(size - 1)/2 [counter], edx => size[for campare], free r9, rax, 
	mov		r8, rcx             ; r8 done
	mov		eax, edx
	dec		edx                 ; edx = size - 1
	imul	eax, edx
	shr		eax, 1              ; div by 2
	mov		ecx, eax            ; ecx done
	inc		edx                 ; edx = size
	mov		r10d, 1             ; r10d done
	mov		r11d, 0             ; r11d done
	
; Loop
@@:
; find and vals posn from src in r9 with i(r10d), j(r11d)
; use eax as pass through
	mov 	r9d, r11d
	imul	r9d, edx
	add		r9d, r10d
	movsxd	r9, r9d
	mov		eax, dword ptr[r8 + r9*4]
	xchg	r10d, r11d
; repeat
	
	mov 	r9d, r11d
	imul	r9d, edx
	add		r9d, r10d
	movsxd	r9, r9d
	xchg	dword ptr[r8 + r9*4], eax 
	xchg	r10d, r11d
	
	mov 	r9d, r11d
	imul	r9d, edx
	add		r9d, r10d
	movsxd	r9, r9d
	mov 	dword ptr[r8 + r9*4], eax 

	inc		r10d
	mov		eax, edx
	sub		eax, r11d
	cmp		r10d, edx
	cmove	r10d, eax          ; conditional move if equals
	cmove	r11d, MinusOne
	inc		r11d

	dec		ecx
	cmp		ecx, 0
	jg		@B					; jump backwards at @@

	mov		al, 1
InvalidParam:
	ret
TransposeSqrMat_ ENDP

TestStructureSum_ PROC frame
	
	push	rsi
	.pushreg rsi
	push	rdi
	.pushreg rdi
	.endprolog

	xor		al, al
	cmp 	rcx, 0
	je		InvalidArg
	cmp 	r8, 0
	je		InvalidArg
	cmp 	edx, 0
	je		InvalidArg

	mov		rsi, rcx
	mov		rdi, r8 ; result of sum

	mov		byte ptr [rdi + TestStruct.val8_t], 0
	mov		word ptr [rdi + TestStruct.ival16_t], 0
	mov		dword ptr [rdi + TestStruct.val32_t], 0
	mov		qword ptr [rdi + TestStruct.ival64_t], 0

	xor		ecx, ecx
@@:
	mov		al, byte ptr [rsi + TestStruct.val8_t]
	add		byte ptr [rdi + TestStruct.val8_t], al

	mov		ax, word ptr [rsi + TestStruct.ival16_t]
	add		word ptr [rdi + TestStruct.ival16_t], ax

	mov		eax, dword ptr [rsi + TestStruct.val32_t]
	add		dword ptr [rdi + TestStruct.val32_t], eax

	mov		rax, qword ptr [rsi + TestStruct.ival64_t]
	add		qword ptr [rdi + TestStruct.ival64_t], rax

	add		rsi, sizeof TestStruct

	inc		ecx
	
	cmp 	ecx, edx
	jne		@B

	mov		al, 1

InvalidArg:
	pop		rdi
	pop		rsi
	ret
TestStructureSum_ ENDP

END