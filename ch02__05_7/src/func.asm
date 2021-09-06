; For x64-bit system

	.const ; constant data

FibVals        dword 0, 1, 1, 2, 3, 5, 8, 13
               dword 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597

FibTableSize_  dword ($ - FibVals) / sizeof dword
			   public FibTableSize_
	
	.data

FibValsSum_    dword ?
			   public FibValsSum_

	.code

FibLookup_ PROC ; [](int index, int* val1, int* val2, int* val3, int* val4) -> bool
	
; Is valid
	cmp		ecx, 0
	jl		InvalidParam
	cmp		ecx, [FibTableSize_]
	jge		InvalidParam

; Save
	movsxd	rcx, ecx ;resize
	mov 	[rsp+8], rcx ;save inside rcx home

; Ex. [base-register]
; Load from lookup
	mov		r11, offset FibVals
	shl		rcx, 2; rcx*2^2 (dwor is 4 byte)
	add		r11, rcx
	mov		eax, dword ptr [r11]
	mov		dword ptr [rdx], eax

	mov		rcx, [rsp+8]; load backup
	
; Ex. [base-register + indexregister]
; Load from lookup
	mov		r11, offset FibVals
	shl		rcx, 2;
	mov		eax, dword ptr [r11+rcx]
	mov		dword ptr [r8], eax

	mov		rcx, [rsp+8]; load backup
	
; Ex. [base-register + indexregister*ScaleFactor]
; Load from lookup
	mov		r11, offset FibVals
	mov		eax, dword ptr [r11+rcx*4]
	mov		dword ptr [r9], eax

	mov		rcx, [rsp+8]; load backup
		
; Ex. [base-register + indexregister*ScaleFactor + Offset]
; Load from lookup
	mov		r11, offset FibVals-42
	mov		rax, [rsp+40]
	mov		r11d, dword ptr [r11+rcx*4+42]
	mov		[rax], r11d
	
; Update FibValsSum_
	add		FibValsSum_, r11d

	mov		al, 1; !!Sucess!!

	ret

InvalidParam:
	xor al, al
	ret

FibLookup_ ENDP

;## if-else implimentaton
Min_ PROC; [](int a, int b, int c) -> int
	
	cmp edx, ecx
	jl  @F
	mov edx, ecx
@@:
	cmp r9d, edx 
	jl  @F
	mov r8d, edx
@@:
	mov eax, r8d
	ret
Min_ ENDP
;## if-else implimentaton
Max_ PROC; [](int a, int b, int c) -> int
	
	cmp ecx, edx
	jl  @F
	mov edx, ecx
@@:
	cmp edx, r8d
	jl  @F
	mov r8d, edx
@@:
	mov eax, r8d
	ret
Max_ ENDP

;## ternary operator implimentaton
MinT_ PROC; [](int a, int b, int c) -> int
	
	cmp		edx, ecx
	cmovg	edx, ecx; move if greater
	cmp		r8d, edx
	cmovg	r8d, edx; move if greater
	
	mov		eax, r8d
	
	ret
MinT_ ENDP
;## ternary operator implimentaton
MaxT_ PROC; [](int a, int b, int c) -> int
	
	cmp		edx, ecx
	cmovl	edx, ecx; move if greater
	cmp		r8d, edx
	cmovl	r8d, edx; move if greater
	
	mov		eax, r8d
	
	ret
MaxT_ ENDP

END