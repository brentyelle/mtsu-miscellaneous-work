; FILENAME: yelle2.asm
; AUTHOR: Brent Yelle
; CSCI 3160, Homework 2
; DATE: Feb 3, 2023
; PURPOSE: Verify the answers to these addition problems:
;	0x08 + 0x2A = 0x32
;	0x1B + 0x4B = 0x66
;       0x01F1 + 0x7BBB = 0x7DAC
;	0x2CA9 + 0x0001 = 0x2CAA

section .data		; initialized data
	num1 db 0x08	; hex 8, decimal 8
	num2 db 0x2A	; hex 2A, decimal 42
	num3 db 1Bh	; hex 1B, decimal 27
	num4 db 4Bh	; hex 4B, decimal 75
	num5 dw 0x01F1	; hex 1F1, decimal 497
	num6 dw 0x7BBB	; hex 7BBB, decimal 31675
	num7 dw 2CA9h	; hex 2CA9, decimal 11433
	num8 dw 0001h	; hex 1, decimal 1

section .bss		; uninitialized data
	ans1 resb 1	; reserve 1 byte for addition1
	ans2 resb 1	; reserve 1 byte for addition2
	ans3 resw 1	; reserve 2 bytes for addition3
	ans4 resw 1	; reserve 2 bytes for addition4

global _start

section .text		; begin code proper
_start:
	mov al, [num1]	; copy value at num1 into AL register
	add al, [num2]  ; add value at num2 to AL register (= num1 value)
	mov [ans1], al	; copy AL register's value into ans1
	
	mov bl, [num3]	; copy value at num3 into BL register
	add bl, [num4]  ; add value at num4 to BL register (= num3 value)
	mov [ans2], bl	; copy BL register's value into ans2
	
	mov cx, [num5]	; copy value at num5 into CX register
	add cx, [num6]  ; add value at num6 to CX register (= num5 value)
	mov [ans3], cx	; copy CX register's value into ans3
	
	mov dx, [num7]	; copy value at num7 into DX register
	add dx, [num8]  ; add value at num8 to DX register (= num7 value)
	mov [ans4], dx	; copy DX register's value into ans4

	mov rax, 60	; syscall ID for sys_exit
	mov rdi, 0	; sys_exit code 0 for success
	syscall		; execute sys_exit with code 0
