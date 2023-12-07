; FILENAME: homework7-part1.asm
; AUTHOR: Brent Yelle
; COURSE: CSCI 3160
; ASSIGNMENT: Homework 7
; PURPOSE: Reverse the elements of an array, implemented for Homework 7 Part I.

;========================================================================
; DATA section for storing initialized data
;========================================================================
section .data
	numbers	dq	2, 3, 5, 7, 11		;the first 5 prime numbers in an array
	len	dq	5

;========================================================================
; TEXT section, containing the actual program code
;	RCX: loop count (number of elements in array)
;	RBX: Address of array element
;========================================================================
global _start
section .text
_start:
	mov rcx, qword [len]	; loop counter in RCX, one step for each element of the list
	mov rbx, numbers	; address of numbers[i], where i=0 initially
pushloop:
	push qword [rbx]	; push numbers[i] onto stack
	add rbx, 8		; i++ (each element of numbers[] is 8 bytes)
	loop pushloop		; repeat 5 times (until RCX=0)
afterpushes:			; now, the top of the stack goes numbers[4], numbers[3], numbers[2], ...
	mov rcx, qword [len]	; new loop counter in RCX, again one step for each element in list
	mov rbx, numbers	; address of numbers[i], where i=0 initially
poploop:
	pop qword [rbx]		; store top of stack (numbers[4-i]) in numbers[i]) <-- the actual reversing!
	add rbx, 8		; i++ (each element of numbers[] is 8 bytes)
	loop poploop		; repeat 5 times (until RCX=0)
exit:				; now, the stack is "empty", and numbers[] has been reversed
	mov rax, 60		; syscall ID for sys_exit
	mov rdi, 0		; sys_exit code 0 for success
	syscall			; execute sys_exit with code 0
	
