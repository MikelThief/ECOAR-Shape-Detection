%macro  prologue 1 
        push    ebp 
        mov     ebp,esp 
        sub     esp,%1 
%endmacro

global FindShape

; symbolic adressess and variables
%define     imageDataArray         [ebp+8]
%define     row_bytes			   edi
%define     black_counter   	   edx
%define     frame_start			   eax


FindShape:
    ; creating the frame
    prologue 0

    ; pushing used registers
    push    esi
	push	ecx
	push	edi
	push	edx

	; the address of image to esi 
    mov     esi, imageDataArray	
	mov		ecx, 1

	;length of row in bytes
    mov     row_bytes, 960

	; looking for black
LookForBlack:  
	cmp		BYTE [esi], 0 
	je		blackPixelFound
	cmp		ecx, 76800
	je		NoShape
	add		esi, 3
	inc		ecx		
	jmp		LookForBlack

blackPixelFound:
	mov		frame_start, esi
	mov		ecx, 1
findWidthOfFrame:
	cmp		BYTE [esi], 0 
	jne		StartProcess
	add		esi, 3
	inc		ecx
	jmp		findWidthOfFrame
StartProcess:
	sub		ecx,1
	mov		black_counter,ecx
	mov		esi, frame_start
	add		esi, row_bytes
	mov		ecx,1
LookForWhite:
	cmp		ecx,black_counter
	je		switchNextRow
	cmp		BYTE [esi], 0 
	jne		GoBack
	add		esi,3
	inc		ecx
	jmp		LookForWhite

switchNextRow:
	mov		ecx,1
	mov		esi, frame_start
	add		esi, row_bytes
	mov		frame_start, esi
	jmp		LookForWhite

GoBack:
	sub		esi,3
ShapeChoose:
	cmp		BYTE [esi], 0 
	jne		Shape2
	add		esi, 3
	cmp		BYTE [esi], 0 
	je		Shape1
	sub		esi, 3
	add		esi, row_bytes
	jmp		ShapeChoose

Shape1:
	mov		eax, 1
	jmp		Exit
Shape2:
	mov		eax, 2
	jmp		Exit
NoShape:
	mov		eax, 0
	


Exit:
    ; ściągnięcie rejestrów ze stosu
	pop		edx
	pop		edi
	pop		ecx
    pop     esi
	
    ; powrót z procedury         
    mov     esp, ebp
    pop     ebp
    ret