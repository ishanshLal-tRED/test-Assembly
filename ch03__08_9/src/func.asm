; For x64-bit system

	.const
MinusOne64 qword -1
One64 qword 1
	.data
	.code

CountElements_ PROC frame ; (int32_t*, uint32_t, int32_t) -> uint32_t ; stack frame directive
						  ;      rcx ,     edx ,     r8d  ->  eax
	
	push rsi
	.pushreg rsi

	.endprolog

; Is valid 
	; rsi: src array, rax: string operation load register, ecx: counter, edx: length, r8d: element, r9d: element count, r10b: result of campare
	xor		eax, eax
	cmp		rcx, 0
	je		InvalidArg
	cmp		edx, 0
	je		InvalidArg

	mov 	rsi, rcx
	xor		ecx, ecx ; for counter
	xor		r9d, r9d ; for element counter
	xor		r10d, r10d
@@:
	lodsd ; load string operation of dword

	cmp		eax, r8d
	sete	r10b ; r10b = (eax == r8d ? 1 : 0)
	add		r9d, r10d ; since r10d is initially 0 then we are not touching upper part

	inc		ecx
	cmp		ecx, edx
	jne		@B

	mov		eax, r9d
InvalidArg:
	pop		rsi
	ret

CountElements_ ENDP

CampareArrays_ PROC frame; (int32_t*, int32_t*, uint32_t, int32_t*) -> bool ; stack frame directive
						 ;      rcx ,     rdx ,     r8d ,      r9   ->  al
	push rsi
	.pushreg rsi
	
	push rdi
	.pushreg rdi

	.endprolog
	
	cmp		rcx, 0
	je		InvalidArg
	cmp		rdx, 0
	je		InvalidArg
	cmp		r8d, 0
	je		InvalidArg
	cmp		r9d, 0
	je		InvalidArg

	mov		rdi, rdx ;
	mov		rsi, rcx
	mov		ecx, r8d ;
	mov		eax, r8d
	movsxd	rax, eax
	movsxd	rcx, ecx
	mov		r11, r9 ;
	mov		dword ptr[r11], 0

	repe	cmpsd ; repeat while equakls do cmp SRC strings of letter size dword inside [rsi] & [rdi] ; on every campare its gonna add 1
	
	cmove	rax, One64 ; last cmp result, if equal mov 1
	je		@F ; last cmp result, if equal we're done

	; Else find the diff ; (n + campare_steps) - (n) - 1 = mismatch INDEX
	sub		rax, rcx ; rax = index of mismatch - 1
	dec		rax      ; rax = index of mismatch
	; Note since string Opr requires rax to be 64bit so we are scaling it prev, hoping it not overflows
	mov		dword ptr[r11], eax
	xor		al, al ; not succeeded
@@:
InvalidArg:
	pop rdi
	pop rsi
	ret
CampareArrays_ ENDP

RevertArray_ proc frame ; (int32_t*, int32_t*, uint32_t) -> bool
	
	push rsi
	.pushreg rsi
	
	push rdi
	.pushreg rdi

	.endprolog

; is Valid
	cmp		rcx, 0
	je		InvalidArg
	cmp		rdx, 0
	je		InvalidArg
	test	r8d, r8d ; remember test is and opr. which discards result
	je		InvalidArg

; Initialize registers for string based reversal operation
	xor		eax, eax
	mov		rsi, rcx ; SRC dword string
	mov		rdi, rdx ; DEST dword string
	mov		ecx, r8d ; counter

	lea		rsi,[rsi+rcx*4-4]

; save caller's RFFLAGS.DF, then set it 1
	; NOTE: its direction flag a.k.a dirn of iteration
	pushfq	; save
	std		; set

; repet loop until array reversal complete
@@:
	lodsd ; load nxt element to eax ; NOTE: rsi is being reverse traversed
	mov		[rdi], eax
	add		rdi, 4
	dec		rcx
	jnz		@B

; restore caller's RFFLAGS.DF, and set return code
	popfq
	mov		al, 1 ; success

InvalidArg:
	pop rdi
	pop rsi
	ret
RevertArray_ endp
END