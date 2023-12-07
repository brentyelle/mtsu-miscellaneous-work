; FILENAME:   main.asm
; AUTHOR:     Brent Yelle
; COURSE:     CSCI 3160
; ASSIGNMENT: Exam 2
; PURPOSE:    Convert a number from numeric form into a base-4 representation in ASCII.

global _start
extern getInput
extern stoi
extern itos
extern convert

section .data
	; For prompting the user
	prompt			db	"Enter your M number: "
	PROMPTLEN		equ	$-prompt
	; For printing the results
	num_zeroes		dq	0			; # of zeroes in ascii_quat
	num_zeroes_ascii	db	"  "			; ascii decimal version of num_zeroes
	num_zeroes_len		dq	2			; # of digits in num_zeroes_ascii
	num_zeroes_offset	dq	0			; starting place of digits in num_zeroes_ascii
	newlinechar		db	10			; newline character (ASCII)
	; for storing the M-number in its various forms
	m_number		dq	0			; the M-number (numeric form)
	ascii_dec		db	"          "		; ascii decimal version of m_number
	len_dec			dq	0			; # of digits in ascii_dec, excluding ' 's
	MAXLEN_DEC		equ	8			; maximum # of digits in ascii_dec
	ascii_quat		db	"0000000000000000"	; ascii quaternary version of m_number
	LEN_QUAT		equ	16			; # of digits in ascii_quat

; ==============================
; A MACRO FOR PRINTING NEWLINE CHARACTERS
; ==============================

%macro	PrintNewline 0
	mov rax, 1			; SYSCALL 1 - sys_write
	mov rdi, 1			; PARAM1 - file descriptor = 1 for stdout
	mov rsi, newlinechar		; PARAM2 - pointer to string to write ('\n')
	mov rdx, 1			; PARAM3 - # of characters to write (1)
	syscall				; write the character
%endmacro



section .text
_start:
	nop
main_get_m:				; ____SET UP TO CALL getInput____
	mov rdi, PROMPTLEN		; PARAM1 - length of prompt
	mov rsi, prompt			; PARAM2 - pointer to prompt string
	mov rdx, ascii_dec		; PARAM3 - pointer to location to store input string
	mov rcx, MAXLEN_DEC		; PARAM4 - maximum # of characters to read
	call getInput			; RETURN - actual number of characters read (including '\n')
	dec rax				; ignore the final '\n'
	mov [len_dec], rax		; store the length of the string
main_convert_numeric:			; ____SET UP TO CALL stoi____
	mov rdi, rax			; PARAM1 - # of digits in string
	mov rsi, ascii_dec		; PARAM2 - pointer to string to convert
	call stoi			; RETURN - the converted number (numeric form)
	mov [m_number], rax		; store the converted number
main_convert_quat:			; ____SET UPT TO CALL convert____
	mov rdi, rax			; PARAM1 - the number to convert
	mov rsi, ascii_quat		; PARAM2 - pointer to where ascii base-4 form will be stored
	mov rdx, num_zeroes		; PARAM3 - pointer to where # of 0s in ascii_quat will be stored
	call convert			; RETURN - nothing of value
main_zeroes_printable:			; ____SET UP TO CALL itos____
	mov rdi, [num_zeroes]		; PARAM1 - the number to convert
	mov rsi, num_zeroes_ascii	; PARAM2 - pointer to string where ascii base-10 form will be stored
	call itos			; RETURN - address within num_zeroes_ascii where the digits start
	sub rax, num_zeroes_ascii	; determine the offset of num_heroes_ascii's initial digit...
	jz main_print_m_quat		; (...if it's 0, we don't need to do anything more...)
	mov [num_zeroes_offset], rax	; ...store that offset...
	sub [num_zeroes_len], rax	; ...and fix the effective length of the string accordingly.
main_print_m_quat:			; ____SYSCALL TO PRINT ascii_quat____
	mov rax, 1			; SYSCALL 1 - sys_write
	mov rdi, 1			; PARAM1 - file descriptor = 1 for stdout
	mov rsi, ascii_quat		; PARAM2 - pointer to string to write
	mov rdx, LEN_QUAT		; PARAM3 - # of characters to write
	syscall
	PrintNewline			; macro to print a newline character
main_print_num_zeroes:			; ____SYSCALL TO PRINT num_zeroes_ascii _____
	mov rax, 1			; SYSCALL 1 - sys_write
	mov rdi, 1			; PARAM1 - file descriptor = 1 for stdout
	mov rsi, num_zeroes_ascii	; PARAM2 - pointer to string to write
	add rsi, [num_zeroes_offset]	; fix PARAM2 to point to *start* of digits in the string
	mov rdx, [num_zeroes_len]	; PARAM3 - # of characters to write
	syscall
	PrintNewline			; macro to print a newline character
main_exit:
	mov rax, 60			; syscall ID for sys_exit
	mov rdi, 0			; sys_exit code 0 for success
	syscall				; execute sys_exit with code 0
