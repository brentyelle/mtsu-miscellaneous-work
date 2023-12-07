; FILENAME: homework7-part2.asm
; AUTHOR: Brent Yelle
; COURSE: CSCI 3160
; ASSIGNMENT: Homework 7
; PURPOSE: Get two number strings from user & display the sum of the numbers on screen, as directed in Homework 7 Part II.

;========================================================================
; BSS section for storing uninitialized data
;========================================================================
section .data
	promptString	db	"Enter a number: "	; for prompt (16 chars)
	plusString	db	" + "			; for plus sign (3 chars)
	equalString	db	" = "			; for equals sign (3 chars)
	endString	db	"!", 10			; concluding ! and newline (2 chars)
	numberLength 	dq	20			; maximum length of number strings
section .bss
	numberAString	resb	20			; first number (in chars)
	numberBString	resb	20			; second number (in chars)
	numberCString	resb	20			; third number - sum (in chars)
	numberA_len	resq	1			; # of decimal digits
	numberB_len	resq	1			
	numberC_len	resq	1
	numberA		resq	1			; first number (numeric)
	numberB		resq	1			; second number (numeric)
	numberC		resq	1			; third number - sum (numeric)

;========================================================================
; TEXT section, containing the actual program code
;	RCX: loop count (number of elements in array)
;	RBX: Address of array element
;========================================================================
global _start
section .text
_start:
	nop
promptForA:
	mov rdi, 16		; getInput: length of prompt string (16 chars)
	mov rsi, promptString	; getInput: pointer to prompt string (to prompt user)
	mov rdx, numberAString	; getInput: pointer to input string (to store input)
	mov rcx, [numberLength]	; getInput: maximum size of input string (20 chars)
	call getInput		; returns # of characters read as RAX
	dec rax			; decrement to get rid of newline character
	mov [numberA_len], rax	; store the length of the number string for later
convertA:
	mov rdi, rax		; stoi: # of characters
	mov rsi, numberAString	; stoi: string form of the number
	call stoi		; returns the number in numerical form
	mov [numberA], rax	; copy the number to memory
promptForB:
	mov rdi, 16		; getInput: length of prompt string (16 chars)
	mov rsi, promptString	; getInput: pointer to prompt string (to prompt user)
	mov rdx, numberBString	; getInput: pointer to input string (to store input)
	mov rcx, [numberLength]	; getInput: maximum size of input string (20 chars)
	call getInput		; returns # of characters read as RAX
	dec rax			; decrement to get rid of newline character
	mov [numberB_len], rax	; store the length of the number string for later
convertB:
	mov rdi, rax		; stoi: # of characters
	mov rsi, numberBString	; stoi: string form of the number
	call stoi		; returns the number in numerical form
	mov [numberB], rax	; copy the number to memory
calculate_sum:
	add rax, [numberA]	; get the sum of the two numbers
convert_sum:
	mov rdi, rax		; itos: number for conversion
	mov rsi, numberCString	; itos: pointer to output string (to store converted form)
	call itos		; RAX now holds copy of numberCString, we don't need it
write_numberA:
	mov rax, 1		; syscall: sys_write
	mov rdi, 1		; sys_write: 1 for Standard Output
	mov rsi, numberAString	; sys_write: pointer to output string
	mov rdx, [numberA_len]	; sys_write: number of characters to write
	syscall
write_plus:
	mov rax, 1		; syscall: sys_write
	mov rdi, 1		; sys_write: 1 for Standard Output
	mov rsi, plusString	; sys_write: pointer to output string (" + ")
	mov rdx, 3		; sys_write: number of characters to write (3)
	syscall
write_numberB:
	mov rax, 1		; syscall: sys_write
	mov rdi, 1		; sys_write: 1 for Standard Output
	mov rsi, numberBString	; sys_write: pointer to output string
	mov rdx, [numberB_len]	; sys_write: number of characters to write
	syscall
write_equals:
	mov rax, 1		; syscall: sys_write
	mov rdi, 1		; sys_write: 1 for standard output
	mov rsi, equalString	; sys_write: pointer to output string (" = ")
	mov rdx, 3		; sys_write: number of characters to write (3)
	syscall
write_sum:
	mov rax, 1		; syscall: sys_write
	mov rdi, 1		; sys_write: 1 for Standard Output
	mov rsi, numberCString	; sys_write: pointer to output string
	mov rdx, [numberLength]	; sys_write: number of characters to write (maximum)
	syscall
write_exclamation:
	mov rax, 1		; syscall: sys_write
	mov rdi, 1		; sys_write: 1 for Standard Output
	mov rsi, endString	; sys_write: pointer to output string ("!\n")
	mov rdx, 2		; sys_write: number of characters to write (2)
	syscall
exit:
	mov rax, 60		; syscall ID for sys_exit
	mov rdi, 0		; sys_exit code 0 for success
	syscall			; execute sys_exit with code 0


; Function getInput
; Parameter 1: RDI -- number of characters in promptString (value parameter)
; Parameter 2: RSI -- pointer to promptString (reference parameter)
; Parameter 3: RDX -- pointer to inputString (reference parameter)
; Parameter 4: RCX -- max number of characters to be read (value parameter)
; Return value: RAX -- number of characters read
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

; Function stoi
; Parameter 1: RDI -- number of digits in the string (value parameter)
; Parameter 2: RSI -- pointer to the string to convert (reference parameter)
; Return value: RAX -- integer value
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

; Function itos
; Parameter 1: RDI -- integer value to convert (by value)
; Parameter 2: RSI – address of string to store ASCIIs (by reference)
; Return value: RAX -- pointer to the first character of the generated string
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
