

LlNode	struct
	ValA	real8 4 dup(?)
	ValB	real8 4 dup(?)
	ValC	real8 4 dup(?)
	ValD	real8 4 dup(?)
	FreeSpace byte 376 dup(?)
	Link	qword ?
LlNode	ends

	.code
_LlTraverse_ macro UsePrefetch
	mov		rax,rcx
	test	rax,rax
	jz		RETURN

	align 16
@@:
	mov		rcx,[rax+LlNode.link]
	vmovapd	ymm0,ymmword ptr[rax+LlNode.ValA]
	vmovapd	ymm1,ymmword ptr[rax+LlNode.ValB]

IFIDN <UsePrefetch>,<Y> ; ~IFIDN
	mov		rdx,rcx
	test	rdx,rdx
	cmovz	rdx,rax
	prefetchnta [rdx]
ENDIF
	
	vmulpd	ymm2,ymm0,ymm0
	vmulpd	ymm3,ymm1,ymm1
	vaddpd	ymm4,ymm2,ymm3
	vsqrtpd	ymm5,ymm4

	vmovntpd ymmword ptr[rax+LlNode.ValC],ymm5
	
	vdivpd	ymm2,ymm0,ymm1
	vdivpd	ymm3,ymm1,ymm0
	vaddpd	ymm4,ymm2,ymm3
	vsqrtpd	ymm5,ymm4

	vmovntpd ymmword ptr[rax+LlNode.ValD],ymm5
	mov		rax,rcx
	test	rax,rax
	jnz		@B

RETURN:
	vzeroupper
	ret
endm

; void LlTraverseA_ (LlNode* p);
LlTraverseA_ PROC
	_LlTraverse_ N
	
LlTraverseA_ ENDP	
; void LlTraverseB_ (LlNode* p);
LlTraverseB_ PROC
	_LlTraverse_ Y
	ret
LlTraverseB_ ENDP

END ; end for this assembly object