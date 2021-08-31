; For x64-bit system

	.data

	.code

Add_ PROC ; calculates (a + b), start of procedure
	
	mov		eax, ecx
	add		eax, edx

	ret ; return value is stored in eax
Add_ ENDP ; end of procedure

Sub_ PROC ; calculates (a - b)
	
	mov		eax, ecx
	sub		eax, edx

	ret
Sub_ ENDP

Mul_ PROC ; calculates (a * b) with sign
	
	mov		eax, ecx
	imul	eax, edx

	ret
Mul_ ENDP

Div_ PROC ; calculates (a / b) with sign on integer
	
	mov		r10d, edx  ; b
	mov 	eax, ecx   ; a
	cdq ; edx:eax cantains 64bit dividend
	idiv	r10d       ; eax/r10d -> eax = quotient, edx = remainder 

	ret
Div_ ENDP

END ; end for this assembly object