; FILENAME: yelle-part.asm
; AUTHOR: Brent Yelle
; COURSE: CSCI 3160
; ASSIGNMENT: Homework 8
; PURPOSE: File to store various I/O functions.

;========================================================================
; TEXT section, containing the actual program code
;	RCX: loop count (number of elements in array)
;	RBX: Address of array element
;========================================================================
global getInput
global stoi
global itos
section .text

; ==================================================================
; getInput
; PARAM1 (RDI) -- # of characters in prompt string
; PARAM1 (RSI) -- pointer to prompt string (will be read from)
; PARAM1 (RDX) -- pointer to input string (will be written to)
; PARAM1 (RCX) -- maximum # of characters to read into input string
; RETURN (RAX) -- actual # number of characters read
; ==================================================================
getInput:
	push rdx ; save register (pointer to inputString)
	mov rax, 1 ; syscall number: 1 for sys_write
	mov rdx, rdi ; number of characters to be written
	mov rdi, 1 ; file descriptor: 1 for STDOUT
	syscall
	mov rax, 0 ; syscall number: 0 for sys_read
	mov rdi, 0 ; file descriptor: 0 for STDIN
	pop rsi ; pop address of the input string from stack
	mov rdx, rcx ; max number of characters to be read
	syscall
	ret

; ==================================================================
; stoi
; PARAM1 (RDI) -- # of digits in string
; PARAM2 (RSI) -- ptr to string to convert (will be read from)
; RETURN (RAX) -- final converted number
;
; NOTE: The input string should not contain an integer outside of the qword range.
; ==================================================================
stoi:
	push rbx ; save rbx
	xor rbx, rbx ; clear rbx (Initialize integer value to zero)
	mov rcx, rdi ; loop counter in rcx
mulAddLoop:
	movzx rax, byte [rsi]; copy the ASCII to rax (al)
	sub al,'0' ; convert from ASCII to number/digit
	imul rbx,10 ; Multiply current integer value by 10
	add rbx, rax ; update integer: rbx = rbx*10 + rax
	inc rsi ; to get the next character
	loop mulAddLoop ; decrement rcx and repeat until rcx = zero
	mov rax,rbx ; store the return value in RAX
	pop rbx ; restore rbx
	ret

; ==================================================================
; itos
; PARAM1 (RDI) -- integer value to convert
; PARAM2 (RSI) -- ptr to string to store the ascii-converted number
; RETURN (RAX) -- pointer to address of the first character
; 
; NOTE: This assumes that the output string is can hold up to 10 digits.
; ==================================================================
itos:
	push rbx ; save rbx
	add rsi, 9 ; go to the rightmost character position
	mov byte [rsi], 0 ; NULL character at the end of string
	mov rbx, 10 ; divisor in rbx
	mov rax, rdi ; dividend in rax
divLoop:
	xor rdx, rdx ; Clear edx prior to dividing rdx:rax by rbx
	div rbx ; rax / 10
	add dl,'0' ; Convert the remainder to ASCII
	dec rsi ; move pointer to left (store characters in reverse order)
	mov [rsi], dl ; store ASCII in memory
	test rax, rax ; check whether quotient is zero
	jnz divLoop ; Repeat until quotient becomes zero
	mov rax, rsi ; return value: address of the first character
	pop rbx ; restore rbx
	ret	
