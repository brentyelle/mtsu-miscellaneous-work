; FILENAME:   convert.asm
; AUTHOR:     Brent Yelle
; COURSE:     CSCI 3160
; ASSIGNMENT: Exam 2
; PURPOSE:    Convert a number from numeric form into a base-4 representation in ASCII.

global convert

section .text

; ==================================================================
; convert
; PARAM1 (RDI) -- integer value to convert (assume 32-bit)
; PARAM2 (RSI) -- address of string (16 characters) where base-4 representation will be stored
; PARAM3 (RDX) -- address of counter for # of '0' characters in the base-4 representation
; 
; ==================================================================
convert:
	push rbx			; save rbx
	add rsi, 16		; go to the rightmost character position
	mov rcx, 16			; for (i=16; i>0; i--)
convert_loopstart:
	mov ebx, edi			; move the number to lower 32 bits of rbx
	and bl, 00000011b		; get remainder of that number mod 4
	or  bl, 00110000b		; convert the remainder to ASCII number (effectively, add 0x30)
	mov [rsi], bl			; store that ASCII number in memory
	cmp bl, '0'				; if the stored digit wasn't '0'...
	jnz convert_loop_else		; ...then don't increment the zero counter...
convert_loop_is0:
	inc QWORD [rdx]			; ...otherwise increment the zero counter
convert_loop_else:
	ror edi, 2			; then, divide the original number by 4
    dec rsi
	loop convert_loopstart		; repeat 16 times (once for each digit in RSI's string)
convert_return:
	pop rbx 			; restore rbx
	ret
