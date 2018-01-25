%macro  prologue 1 
        push    rbp
        mov     rbp, rsp 
        sub     rsp, %1 
%endmacro

global FindShape

; symbolic adressess and variables
%define     imageDataArray         [rbp+8]
%define     row_bytes			   r10
%define     black_counter   	   r11
%define     frame_start			   r12


FindShape:
    ; creating the frame
    prologue 0

    ; pushing used registers
    push    rdi
	push	rcx

	; the address of image to rdi 
	mov		rcx, 1

	;length of row in bytes
    mov 	rdx, 960
    mov     row_bytes, rdx

	; looking for black
LookForBlack:  
	cmp		BYTE [rdi], 0 
	je		blackPixelFound
	cmp		rcx, 76800
	je		NoShape
	add		rdi, 3
	inc		rcx		
	jmp		LookForBlack

blackPixelFound:
	mov		frame_start, rdi
	mov		rcx, 1
findWidthOfFrame:
	cmp		BYTE [rdi], 0 
	jne		StartProcess
	add		rdi, 3
	inc		rcx
	jmp		findWidthOfFrame
StartProcess:
	sub		rcx, 1
	mov		black_counter,rcx
	mov		rdi, frame_start
	add		rdi, row_bytes
	mov		rcx, 1
LookForWhite:
	cmp		rcx,black_counter
	je		switchNextRow
	cmp		BYTE [rdi], 0 
	jne		GoBack
	add		rdi,3
	inc		rcx
	jmp		LookForWhite

switchNextRow:
	mov		rcx,1
	mov		rdi, frame_start
	add		rdi, row_bytes
	mov		frame_start, rdi
	inc		rdx
	jmp		LookForWhite

GoBack:
	sub		rdi,3
ShapeChoose:
	cmp		BYTE [rdi], 0 
	jne		Shape2
	add		rdi, 3
	cmp		BYTE [rdi], 0 
	je		Shape1
	sub		rdi, 3
	add		rdi, row_bytes
	jmp		ShapeChoose

Shape1:
	mov		eax, 1
	jmp		Exit
Shape2:
	mov		eax, 2
	jmp		Exit
NoShape:
	mov		eax, 0
	;jmp not
Exit:
    ; ściągnięcie rejestrów ze stosu
	pop		rcx
    pop     rdi
	
    ; powrót z procedury         
    mov     rsp, rbp
    pop     rbp
    ret