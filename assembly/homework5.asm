; FILENAME:	homework5.asm
; AUTHOR:	Brent Yelle
; CLASSC:	CSCI 3160, Homework 5
; DUE DATE:	Feb 21, 2023
; PURPOSE:	Verify answers to Parts I and II from Homework 5.

section .data
	Flags db 0xf0	; 11110000b

section .text		; begin code proper
global _start
_start:
	nop		; do nothing; allows me to label q1_1 properly
q1_1:
	mov ax, 0xaf75
	mov bx, 0x00ff
	and ax, bx	; should yield AX=0x0075, SF=0
q1_2:
	mov bx, 0xaf75
	mov cx, 0x0ff0
	or bx, cx	; should yield BX=0xAFF5, SF=1
q1_3:
	mov cx, 0xaf75
	mov dx, 0x0f00
	xor cx, dx	; should yield CX=0xA075, SF=1
q1_4:
	or BYTE [Flags], 00010010b	; [Flags] should be 0xF2
q1_5:
	and BYTE [Flags], 11011011b	; [Flags] should be 0xD2
q1_6:
	xor BYTE [Flags], 01001000b	; [Flags] should be 0x9A
q1_7:
	mov al, 0x43		; ASCII 'C'
	or al, 00100000b	; should yield 'c'
q1_8:
	mov bl, 0x65		; ASCII 'e'
	and bl, 11011111b	; should yield 'E'
q1_9:
	mov cl, 0x47		; ASCII 'G'
	xor cl, 00100000b	; should yield 'g'
q1_10:
	mov dx, 541		; hex 0x021D
	and dx, 0x003F		; should yield 0x01D
q1_11:
	mov ch, 4		; hex 0x04
	or ch, 0x30		; should yield 0x34 : ASCII '4'
q2_1:
	mov di, 0xaf75		
	shl di, 1		; should yield DI=0x5EEA, CF=1
q2_2:
	mov si, 0xaf75
	shr si, 1		; should yield SI=0x57BA, CF=1
q2_3:
	mov r8w, 0xaf75
	sar r8w, 4		; should yield R8W=FAF7, CF=0
q2_4:
	mov r9w, 0xaf75
	rol r9w, 1		; should yield R9W=0x5EEB, CF=1
q2_5:
	mov r15w, 0xaf75
	ror r15w, 1		; should yield R15W=0xD7BA, CF=1
q2_6:
	mov eax, -5		; hex 0xFFFFFFFB
	sal eax, 5		; should yield 0xFFFFFF60
q2_7:
	mov ebx, -160		; hex 0xFFFFFF60
	sar ebx, 5		; should yield 0xFFFFFFFB
q2_8:
	mov ecx, -2		; hex 0xFFFFFFFB := x
	mov ebx, ecx		; EBX = x
	sal ecx, 5		; ECX = 32*x
	add ecx, ebx		; ECX = 32*x + x = 33*x = -66 = 0xFFFFFFBE
q2_9:
	mov edx, -2		; hex 0xFFFFFFFB := y
	mov ebx, edx		; EBX = y
	sal edx, 6		; EDX = 64*y
	sub edx, ebx		; EDX = 64*y - y = 63*y = -126 = 0xFFFFFF82
exit:
	mov rax, 60		; syscall ID for sys_exit
	mov rdi, 0		; sys_exit code 0 for success
	syscall			; execute sys_exit with code 0
