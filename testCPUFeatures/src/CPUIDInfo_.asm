CPUIDRegs struct
	RegEAX  dword ?
	RegEBX  dword ?
	RegECX  dword ?
	RegEDX  dword ?
CPUIDRegs ends
 .code

;void     Xgetbv_ (uint32_t r_ecx, uint32_t *r_eax, uint32_t  *r_edx)
Xgetbv_ proc

	mov		r9, rdx
	xgetbv

	mov		dword ptr[r9],eax
	mov		dword ptr[r8],edx
	ret
Xgetbv_ endp

;uint32_t CPUID_  (uint32_t r_eax, uint32_t  r_ecx, CPUIDRegs *r_out)
;returns 0 | 1
CPUID_ proc frame
	push	rbx
	.pushreg rbx
	.endprolog

; Load eax, ecx
	mov		eax,ecx
	mov		ecx,edx
; Get CPUID info & save results
	CPUID
	mov		dword ptr[r8 + CPUIDRegs.RegEAX], eax
	mov		dword ptr[r8 + CPUIDRegs.RegEBX], ebx
	mov		dword ptr[r8 + CPUIDRegs.RegECX], ecx
	mov		dword ptr[r8 + CPUIDRegs.RegEDX], edx

; Test for unsupported CPUID leaf
	or		eax,ebx
	or		ecx,edx
	or		eax,ecx

	pop		rbx
	ret
CPUID_ endp

	END