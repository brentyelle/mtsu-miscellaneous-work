; FILENAME: homework3.asm
; AUTHOR: Brent Yelle
; CSCI 3160, Homework 3
; DATE: Feb 9, 2023
; PURPOSE: Verify the answers to handwritten assembly code and hexadecimal arithmetic done on Homework 3.

section .data		; initialized data
	; PROBLEM 1
	numbers1 db 100, -100
	numbers2 dw 100, -100
	number3  dd 100
	number4  dq -100
	; PROBLEM 2
	num1a db 0x64	; decimal 100 (us & s)
	num1b db 0x9C	; decimal 156 (us) or -100 (s)
	num2a dw 0x0064	; decimal 100 (us & s)
	num2b dw 0x009C	; decimal 156 (us & s)
	num3a dd 0x00000064	; decimal 100 (us & s)
	num3b dd 0xFFFFFF9C	; decimal -100 (s), 4294967196 (us)
	num4a dq 0x89abcdef1234567
	num4b dq 0x9abcdef12345678

section .bss		; uninitialized data
	; PROBLEM 2
	ans1 resb 1	; reserve 1 byte for addition1
	ans2 resw 1	; reserve 2 bytes for addition2
	ans3 resd 1	; reserve 4 bytes for addition3
	ans4 resq 1	; reserve 8 bytes for addition4

section .text		; begin code proper
global _start
_start:
PROBLEM2:
	mov al, [num1a]	; copy value of num1a into AL
	add al, [num1b]	; add value of num1b to AL, store in AL
	mov [ans1], al	; copy AL register's value into ans1
	
	mov ax, [num2a]	; copy value of num2a into AX
	add ax, [num2b]	; add value of num2b to AX, store in AX
	mov [ans2], ax	; copy AX register's value into ans2

	mov eax, [num3a]	; copy value of num3a into EAX
	add eax, [num3b]	; add value of num3b to EAX, store in EAX
	mov [ans3], eax		; copy EAX register's value into ans3

	mov rax, [num4a]	; copy value of num4a into RAX
	add rax, [num4b]	; add value of num4b to RAX, store in RAX
	mov [ans4], rax		; copy RAX register's value into ans4
exit:
	mov rax, 60	; syscall ID for sys_exit
	mov rdi, 0	; sys_exit code 0 for success
	syscall		; execute sys_exit with code 0
