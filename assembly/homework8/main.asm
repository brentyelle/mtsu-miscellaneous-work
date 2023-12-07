global _start
extern getInput
extern stoi
extern itos
extern maxMin
extern computeAvg

section .data
	prompt				db		"Enter a value, or 0 to quit: "		; 29 characters
	prompt_len			equ		$-prompt							; length of above string
	printSize			db		10, "Array size:    "
	printAverage		db		10, "Average value: "
	printMaximum		db		10, "Maximum value: "
	printMinimum		db		10, "Minimum value: "
	printNewline		db		11
	printLengths		equ		16         							; the size of all these print statements (all the same length)
	arraylen_str		db	    "                    "				; the length of myarray, printable, length 20
	maxvalue_str		db	    "                    "				; the largest value of myarray, printable, length 20
	minvalue_str		db	    "                    "				; the smallest value of myarray, printable, length 20
	avgvalue_str		db   	"                    "	      		; the average value of myarray, printable, length 20
section .bss
	myarray_maxlen		equ		25					; maximum allowed length of myarray (see .bss)
	myarray				resq	myarray_maxlen		; the array myarray (up to myarray_maxlen elements, 64-bit each)
	num_ascii_maxlen	equ		10					; maximum allowed length of num_ascii (see .bss)
	num_ascii			resb	num_ascii_maxlen	; number to import into myarray, ascii (max 64 chars)
	arraylen			resq	1					; the length of myarray
	maxvalue			resq	1					; the largest value in myarray
	minvalue			resq	1					; the smallest value in myarray
	avgvalue			resq	1					; the average of all the values in myarray
	arraylen_strstart		resq	1				; the printable start of arraylen_str (will print 10 characters, including invisible spaces)
	maxvalue_strstart		resq	1				; the printable start of maxvalue_str (will print 10 characters, including invisible spaces)
	minvalue_strstart		resq	1				; the printable start of minvalue_str (will print 10 characters, including invisible spaces)
	avgvalue_strstart		resq	1				; the printable start of avgvalue_str (will print 10 characters, including invisible spaces)
section .text
_start:
	mov r13, 0						; R13 will hold the size of myarray (to be stored in myarray_len)
	mov r12, myarray				; R12 = &(myarray[i]), initially i=0
main_readLoop:
	mov rdi, prompt_len	 		    ; PARAM1: number of chars to print
	mov rsi, prompt					; PARAM2: ptr to array of chars to print
	mov rdx, num_ascii				; PARAM3: ptr to array to hold chars to read
	mov rcx, num_ascii_maxlen		; PARAM4: max number of chars to read into num_ascii
	call getInput					; RAX will return with # of characters read
	dec rax							; decrement to not count the \n
main_convertNum:
	mov rdi, rax					; PARAM1: number of characters to convert
	mov rsi, num_ascii				; PARAM2: ptr to array of chars to convert
	call stoi						; RAX will return the converted number
	cmp rax, 0						; if converted number=0, the user wants to quit
	je main_breakLoop				; so break the loop
	mov [r12], rax					; otherwise, copy the number as myarray[i]
	add r12, 8						; increment R12 by 8 (64 bits for size of element)
	inc r13							; update size of array
	cmp r13, myarray_maxlen			; if # of elements has reached max, we can't store more
	jge main_breakLoop					; so break the loop
	jmp main_readLoop					; otherwise repeat (until user enters 0 or we reach maximum length)
main_breakLoop:						; at this point, myarray now holds #R13 elements, all converted
	mov [arraylen], r13				; store the array's length for posterity
main_getAvg:
	mov rdi, myarray				; PARAM1 (RDI) -- address of array (pass by reference)- input parameter
	mov rsi, [arraylen]				; PARAM2 (RSI) -- array size (pass by value)- input parameter
	call computeAvg					; RETURN (RAX) -- average of the array (by value), or 0 if the array is size 0
	mov [avgvalue], rax				; store the average in memory
main_getMaxMin:
	mov rdi, maxvalue				; PARAM1 (RDI) -- maximum of an array (pass by reference)- output parameter
	mov rsi, minvalue				; PARAM2 (RSI) -- minimum of an array (pass by reference)- output parameter
	mov rdx, myarray				; PARAM3 (RDX) -- address of array (pass by reference)- input parameter
	mov rcx, [arraylen]				; PARAM4 (RCX) -- array size (pass by value)- input parameter
	call maxMin						; RETURN (RAX) -- returns 0 if successful, 1 if invalid array size
; ==================================================================
; itos
; PARAM1 (RDI) -- integer value to convert
; PARAM2 (RSI) -- ptr to string to store the ascii-converted number
; RETURN (RAX) -- pointer to ascii-converted number's first element
; ==================================================================
main_convertAnswers:
	; ARRAY LENGTH
	mov rdi, [arraylen]				; PARAM1 (RDI) -- numerical value to convert (pass by value)
	mov rsi, arraylen_str			; PARAM2 (RSI) -- string where converted value will be output
	call itos						; returns the start position of the converted value-->string
	mov [arraylen_strstart], rax	; store for printing later
	; AVERAGE VALUE
	mov rdi, [avgvalue]				; PARAM1 (RDI) -- numerical value to convert (pass by value)
	mov rsi, avgvalue_str			; PARAM2 (RSI) -- string where converted value will be output
	call itos						; returns the start position of the converted value-->string
	mov [avgvalue_strstart], rax	; store for printing later
	; MAXIMUM VALUE
	mov rdi, [maxvalue]				; PARAM1 (RDI) -- numerical value to convert (pass by value)
	mov rsi, maxvalue_str			; PARAM2 (RSI) -- string where converted value will be output
	call itos						; returns the start position of the converted value-->string
	mov [maxvalue_strstart], rax	; store for printing later
	; MINIMUM VALUE
	mov rdi, [minvalue]				; PARAM1 (RDI) -- numerical value to convert (pass by value)
	mov rsi, minvalue_str			; PARAM2 (RSI) -- string where converted value will be output
	call itos						; returns the start position of the converted value-->string
	mov [minvalue_strstart], rax	; store for printing later
main_printArrayLength:
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, printSize				; sys_write param2: address to string to print
	mov rdx, printLengths			; sys_write param3: length of string to print
	syscall
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, [arraylen_strstart]	; sys_write param2: address to string to print
	mov rdx, 10						; sys_write param3: length of string to print
	syscall
main_printArrayAverage:
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, printAverage			; sys_write param2: address to string to print
	mov rdx, printLengths			; sys_write param3: length of string to print
	syscall
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, [avgvalue_strstart]	; sys_write param2: address to string to print
	mov rdx, 10						; sys_write param3: length of string to print
	syscall
main_printArrayMaximum:
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, printMaximum			; sys_write param2: address to string to print
	mov rdx, printLengths			; sys_write param3: length of string to print
	syscall
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, [maxvalue_strstart]	; sys_write param2: address to string to print
	mov rdx, 10						; sys_write param3: length of string to print
	syscall
main_printArrayMinimum:
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, printMinimum			; sys_write param2: address to string to print
	mov rdx, printLengths			; sys_write param3: length of string to print
	syscall
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, [minvalue_strstart]	; sys_write param2: address to string to print
	mov rdx, 10						; sys_write param3: length of string to print
	syscall
main_printNewline:
	mov rax, 1 						; syscall 1 = sys_write
	mov rdi, 1						; sys_write param1: file descriptor 1 for stdout
	mov rsi, printNewline			; sys_write param2: address to string to print
	mov rdx, 1						; sys_write param3: length of string to print
	syscall
main_exit:
	mov rax, 60						; syscall ID for sys_exit
	mov rdi, 0						; sys_exit code 0 for success
	syscall							; execute sys_exit with code 0