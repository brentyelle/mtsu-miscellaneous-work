; FILENAME: homework4.asm
; AUTHOR: Brent Yelle
; CSCI 3160, Homework 4
; DATE: Feb 16, 2023
; PURPOSE: Verify the answers to handwritten assembly code and hexadecimal arithmetic done in part 1 of Homework 4.

section .text		; begin code proper
global _start
_start:
q1:			; expected yield CL 0xad, DL 0xcd, CF 1, OF 1
	mov cl, 0x7a
	mov dl, 0xcd
	sub cl, dl	; CL = 0x7a - 0xcd = 122 - (-51), or = 122 - 205
q2:			; expected yield EDX 0x8000, EAX 0x0000, CF 1
	mov eax, 0x40000000
	mov ebx, 0x20000
	mul ebx		; EDX:EAX = 0x40000000 * 0x00020000 = 0x00008 0000 0000 0000
q3:			; expected yield AH 0xff, AL 0xc4, CF 0
	mov al, 10
	mov bl, -6
	imul bl		; AH:AL = 10 * -6 = -60 = 0xFFC4
q4:			; expected yield DX 0x0000, AX 0x0320, CF 0
	mov ax, 20
	mov bx, 40
	imul bx		; DX:AL = 20 * 40 = 800 = 0x0320
q5:			; expected yield AH 0x02, AL 0x2c
	mov ah, 0	
	mov al, -34	; hex 0xDE, which makes AX = 0x00DE
	mov bl, 5
	idiv bl		; AL = 0x00DE / 0x0005 = 44, AH = remainder 2
q6:			; expected yield AH 0xfc, AL 0xfa
	mov ax, -34	; hex 0xFFDE
	mov bl, 5
	idiv bl		; AL = -34 / 5 = -6 = 0xFA, AH = remainder -4 = 0xFC
q7:			; expected yield AH 0xfc, AL 0xfa
	mov al, -34	; hex 0xDE
	cbw		; sign-extend AH:AL to 0xFF:DE
	mov bl, 5
	idiv bl		; AL = -34 / 5 = -6 = 0xFA, AH = remainder -4 = 0xFC
q8:			; expected yield DX 0xfffc, AX 0xfffa
	mov ax, -34	; hex 0xFFDE
	cwd		; sign-extend DX:AX to 0xFFFF:FFDE
	mov bx, 5	
	idiv bx		; AX = -34 / 5 = -6 = 0xFFFA, DX = remainder -4 = 0xFFFC
q9:			; expected yield EDX 0xfffffffc, EAX 0x00000006
	mov eax, -34	; hex 0xFFFFFFDE
	cdq		; sign-extend EDX:EAX to 0xFFFFFFFF:FFFFFFDE
	mov ebx, -5
	idiv ebx	; EAX = -34 / -5 = 6 = 0x00000006, RDX = remainder -4 = 0xFFFFFFFC
q10:			; expected yield RDX 0x0000000000000004, RAX 0xfffffffffffffffa
	mov rax, 34	; RAX = 34 = 0x0000000000000022
	cqo		; sign-extend RDX:RAX to 0x0000000000000000:0000000000000022
	mov rbx, -5	
	idiv rbx	; RAX = 34 / -5 = -6 = 0xFFFF...FFFA, RDX = remainder +4 = 0x0000...0004
exit:			; expected yield CL 0xAD, DL 0xCD, CF 1, OF 1
	mov rax, 60	; syscall ID for sys_exit
	mov rdi, 0	; sys_exit code 0 for success
	syscall		; execute sys_exit with code 0
