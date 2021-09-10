; For x64-bit system

; For visual studio, 1st four floating point vals(both single-double precision)
; falls in register xmm0 to xmm3 (there are total 16 vector registers from xmm(0 to 15))
; also the return values of type float (both float and double) is to be stored in xmm0

	.const
r4_5by9  real4  0.55555556 ; 5 / 9
r4_9by5  real4  1.8 ; 9 / 5
r4_32    real4  32.0

r8_PI    real8  3.14159265358979323846
r8_3     real8  3.0
r8_4     real8  4.0
r8_0     real8  0.0
	.data
	.code

ConvertFtoC_ proc ; (float in) -> float
				  ; xmm0[0:31] -> xmm0[0:31]
	vmovss	xmm1, [r4_32] ; vector operation move single(individual) single-precision floating point
	vsubss	xmm2, xmm0, xmm1 ; vector operation subtract single(individual) single-precision floating point

	vmovss	xmm1, real4 ptr [r4_5by9] ; Note we don't need to provide ptr type as instruction will already treat it as float32
	vmulss	xmm0, xmm2, xmm1 ; vector operation multiply single(individual) single-precision floating point
	
	ret
ConvertFtoC_ endp
	
ConvertCtoF_ proc ; (float in) -> float
				  ; xmm0[0:31] -> xmm0[0:31]
	vmulss	xmm2, xmm0, [r4_9by5]
	vaddss	xmm0, xmm2, [r4_32] ; vector operation addition single(individual) single-precision floating point
	
	ret
ConvertCtoF_ endp


CalcSphereAreaAndVol_ proc ; (double, double*, double*) -> bool
						   ;    xmm0,     rdx,      r8  -> bool
	xor		al,al;

	vcomisd	xmm0, [r8_0]; check x86 instruction refrence
	jp 		InvalidArg ; PF = 1 i.e NaN condn check
	jbe		InvalidArg ; below equal, CF = 1(below), ZF = 1(equal)

; Surface_Area = 4*PI* r*r
	vmulsd	xmm1, xmm0, xmm0 ; r*r
	vmulsd	xmm2, xmm1, [r8_PI] ; r*r*PI
	vmulsd	xmm1, xmm2, [r8_4] ; r*r*PI*4
	
	vmovsd	real8 ptr[rdx], xmm1 ; save Surface Area

; Volume = Surface_Area * r / 3
	vmulsd	xmm3, xmm1, xmm0 ; 4*PI*r*r*r
	vdivsd	xmm2, xmm3, [r8_3] ; 4*PI*r*r*r

	vmovsd	real8 ptr[r8], xmm2;
	
	mov		al, 1 ; set success

InvalidArg:
	ret
CalcSphereAreaAndVol_ endp
	

CalcDist_ proc ; ( double, double, double, double, double, double) -> double
			   ;    xmm0 ,  xmm1 ,  xmm2 ,  xmm3 ,[rsp+40],[rsp+48]->  xmm0
	vmovsd	xmm4, real8 ptr[rsp+40]
	vmovsd	xmm5, real8 ptr[rsp+48]

	vsubsd	xmm0, xmm3, xmm0 ; x0 = x2 - x1
	vsubsd	xmm1, xmm4, xmm1 ; y0 = y2 - y1
	vsubsd	xmm2, xmm5, xmm2 ; z0 = z2 - z1

	vmulsd	xmm0,xmm0,xmm0
	vmulsd	xmm1,xmm1,xmm1
	vmulsd	xmm2,xmm2,xmm2

	vaddsd	xmm1, xmm0, xmm1
	vaddsd	xmm1, xmm1, xmm2

	vsqrtsd	xmm0, xmm0, xmm1 ; ymm0[255:0] = 0[255:128] + xmm0[127:64] + sqrt(xmm1[63:0])
	ret
CalcDist_ endp 

CompareVCOMISS_ proc ; (float a, float b, bool *results) -> void
					 ;    xmm0 ,   xmm1 ,    r8
	vcomiss	xmm0,xmm1
	setp	byte ptr[r8] ; set unordered
	jnp		NotUnoredered ; jmp if RFLAGS.PF = 0 i.e none is NaN and we are good to go

	xor		al, al ; one of them is NaN, so camparing is absolite
	mov		[r8+1],al
	mov		[r8+2],al
	mov		[r8+3],al
	mov		[r8+4],al
	mov		[r8+5],al
	mov		[r8+6],al
	jmp		RETURN;
NotUnoredered:
	setb	byte ptr[r8+1] ; CF = 1
	setbe	byte ptr[r8+2] ; ZF = 1 || CF = 1
	sete	byte ptr[r8+3] ; ZF = 1
	setne	byte ptr[r8+4] ; ZF = 0
	seta	byte ptr[r8+5] ; ZF = 0 && CF = 0
	setae	byte ptr[r8+6] ; CF = 0
RETURN:
	ret
CompareVCOMISS_ endp

CompareVCOMISD_ proc ; (double a, double b, bool *results) -> void
					 ;     xmm0 ,    xmm1 ,  r8
	vcomisd	xmm0,xmm1
	setp	byte ptr[r8]
	jnp		NotUnoredered ; jmp if RFLAGS.PF = 0 i.e none is NaN and we are good to go

	xor		al, al ; one of them is NaN, so camparing is absolite
	mov		[r8+1],al
	mov		[r8+2],al
	mov		[r8+3],al
	mov		[r8+4],al
	mov		[r8+5],al
	mov		[r8+6],al
	jmp		RETURN;
NotUnoredered:
	setb	byte ptr[r8+1] ; CF = 1
	setbe	byte ptr[r8+2] ; ZF = 1 || CF = 1
	sete	byte ptr[r8+3] ; ZF = 1
	setne	byte ptr[r8+4] ; ZF = 0
	seta	byte ptr[r8+5] ; ZF = 0 && CF = 0
	setae	byte ptr[r8+6] ; CF = 0
RETURN:
	ret
CompareVCOMISD_ endp

	END