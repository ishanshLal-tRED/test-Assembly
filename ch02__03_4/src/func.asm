; For x64-bit system

	.data

	.code

IntegerLeftRightShift_ PROC ; [](int val, uint32_t count, int* a_shl, int* a_shr) -> bool, start of procedure
								;    ecx,           edx,	r8(x64),	r9(x64)
	xor		rax, rax ; empty out rax (64-bit)
	xchg	ecx, edx ; exchange ecx, edx register as counter should be stored in ecx register
	cmp		ecx, 31  ; campare and store result in status register
	ja		ExitFunc ; if status is true in status register goto "ExitFunc" lable

	mov		eax, edx ; store [val] in eax register
	shl		eax, cl  ; shift left requires cl register (x8 ver sion of rcx)
	mov		[r8], eax; Note : r8 cantains a x64 pointer so derefrence and assign

	shr		edx, cl  ; shift right
	mov		[r9], edx; r9 cantains a x64 pointer so derefrence and assign

	mov		al, 1    ; Note : returning its a sucess

ExitFunc: ; lable
	ret ; return value is stored in eax

IntegerLeftRightShift_ ENDP ; end of procedure

IntegerLeftRightShift2_ PROC ; [](int val, uint32_t count, int* a_shl, int* a_shr) -> bool, start of procedure
								;    ecx,           edx,	r8(x64),	r9(x64)
	xor		rax, rax ; empty out rax (64-bit)
	xchg	ecx, edx ; exchange ecx, edx register as counter should be stored in ecx register
	cmp		ecx, 31  ; campare and store result in status register
	ja		ExitFunc2; if status is true in status register goto "ExitFunc" lable

	mov		eax, edx ; store [val] in eax register
	shl		eax, cl  ; shift left requires cl register (x8 ver sion of rcx)
	mov		[r8], eax; Note : r8 cantains a x64 pointer so derefrence and assign

	shr		edx, cl  ; shift right
	mov		[r9], edx; r9 cantains a x64 pointer so derefrence and assign

	mov		al, 1    ; Note : storing it's a sucess

ExitFunc2: ; lable
	mov		rdx, [rsp+40]; store ptr at 40th posn in stack
	mov		[rdx], al; store status at pointing posn

	; how are we calculating it,
	; well, In Our Stack -> {RSP or stack pointer} -> [ 8-Byte(RCX register's home) | 8-Byte(RDX register's home) | 8-Byte(R8 register's home)  | 8-Byte(R9 register's home)] -> 32 Bytes (256 bits) depth
	; since data is stored in little embian format the start is at +8byte(its a pointer) i.e. 40th posn {though this is not a concern as every subsequent param is gonna occupy atleast 64bit, no matter how small}
	
	ret
IntegerLeftRightShift2_ ENDP ; end of procedure	

Add8Elements_ PROC ; [](int a, uint32_t b, int8_t c, uint16_t d, uint32_t e, int8_t f, uint16_t g, int8_t h) -> int64_t, start of procedure
					 ;    ecx,        edx,	r8b(x8),   r9w(x16),   [rsp+40], [rsp+48],   [rsp+56], [rsp+64],
	
	xor		eax, eax ;empty
	xchg	eax, ecx ;eax = a, ecx = 0
	movsx 	ecx, r9w ;ecx = sign_extend(d) 
	add 	edx, ecx ;edx = b + d
	movsx	ecx, r8b
	add		eax, ecx ;eax = a + s_x(c)

	add 	eax, dword ptr [rsp+40]; eax = a + c + e
	movsx	ecx,  byte ptr [rsp+48]; ecx = s_x(f)
	add		edx,  ecx              ; edx = b + d + f
	movsx	ecx,  word ptr [rsp+56]; ecx = s_x(g)
	add		eax,  ecx              ; eax = a + c + e + g
	movsx	ecx,  byte ptr [rsp+64]; ecx = s_x(h)
	add		edx,  ecx              ; edx = b + d + f + h

	movsxd	rcx, eax ; rcx = s_xdword(a + c + e + g)
	movsxd	rdx, edx ; rdx = s_xdword(b + d + f + h)
	add		rcx, rdx ; rcx = a + b + c + d + e + f + g + h
	mov		rax, rcx ; rax = result

	ret
Add8Elements_ ENDP ; end of procedure	

END ; end for this assembly object