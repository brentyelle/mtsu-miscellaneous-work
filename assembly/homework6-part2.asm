; FILENAME: homework6-part2.asm
; AUTHOR: Brent Yelle
; COURSE: CSCI 3160
; ASSIGNMENT: Homework 6
; PURPOSE: Create an assembly program to solve four simple math problems as dictated in Homework, Part II.

; preset data for storing the parameters
section .data
	x db 1			; for function 1
	y db 2			; for function 1
	z db 3			; for function 1
	a dw 45			; for function 2
	b dw 18			; for function 2
	limit dd 500000000		; for function 3
	n dd 10			; for function 4
	k dd 6			; for function 4
   
; uninitialized data for storing the answers
section .bss
	maximum_xyz resb 1	; for function 1, will hold the maximum of {x, y, z}
	minimum_xyz resb 1	; for function 1, will hold the minimum of {x, y, z}
	gcd_ab resw 1		; for function 2, will hold the GCD of {a, b}
	m resd 1		; for function 3, will hold the greatest integer m such that m! <= limit
	factorial resd 1	; for function 3, will hold m! (where m is as above)
	binomial resd 1		; for function 4, will hold the binomial coefficient C(n,k)

global _start

section .text
_start:
	nop

; FUNCTION 1 STARTS HERE
function1:
	mov ah, [x]		;AH will store the maximum, [x] by default
	mov al, ah		;AL will store the minimum, [x] by default
f1test_ygx:
	cmp [y], ah
	jng f1test_ylx		; if [y] > [x]
	mov ah, [y]		; then potential max = [y], else try if it's minimum
f1test_ylx:
	cmp [y], al		
	jnl f1test_zgxy		; if [y] < [x] 
	mov al, [y]		; then potential min = [y]; else skip and start testing [z]
f1test_zgxy:
	cmp [z], ah
	jng f1test_zlxy		; if [z] > current max
	mov ah, [z]		; then it's the true max
	jmp func1end		; and skip checking if it's the minimum
f1test_zlxy:
	cmp [z], al
	jnl func1end		; if [z] < current min
	mov al, [z]		; then it's the true min
func1end:
	mov [maximum_xyz], ah	; copy the true maximum to memory
	mov [minimum_xyz], al	; copy the true minimum to memory

; FUNCTION 2 STARTS HERE
function2:
	mov r8w, [a]		; to hold dividend
	mov r9w, [b]		; to hold divisor
	mov r10w, 0		; to hold remainder
f2start_dowhile:		; do {...
	mov ax, r8w		;	 prepare for integer division
	cwd
	idiv r9w		;	now AX holds useless data, DX stores new remainder (dividend % divisor)
	mov r10w, dx		; 	remainder = dividend % divisor
	mov r8w, r9w		; 	dividend = divisor
	mov r9w, r10w		; 	divisor = remainder;
	test r10w, r10w
	jnz f2start_dowhile	; ...} while (remainder != 0)
	mov [gcd_ab], r8w	; the gcd is the final dividend value, whereas the divisor(R9W) and remainder(R10W) values are now both 0

; FUNCTION 3 STARTS HERE
function3:
	mov ecx, 1		; to hold counter 1, 2, ...
	mov eax, 1		; to hold cumulative product 1, 2, 6, 24, 120, ...
f3while_testcase:
	inc ecx			; ++i;
	mov ebx, eax		; temp(EBX) = product
	imul ebx, ecx		; temp = product*(new i)
	cmp ebx, [limit]
	jnl func3end		; while (temp < limit) {
f3while_body:
	mov eax, ebx		; 	product = temp, which was product*(new i)
	jmp f3while_testcase	; }
func3end:
	dec ecx			; get the last successful i (since we did "inc ecx" earlier)
	mov [m], ecx		; [m] <-- the last successful i
	mov [factorial], eax	; [factorial] <-- the last product

; FUNCTION 4 STARTS HERE	; N.B. to self: "loop LABEL" does "dec ecx" then "jnz LABEL"
function4:
	mov r8d, [n]		; R8D has n, will hold n!
	mov r9d, [k]		; R9D has k, will hold k!
	mov r10d, r8d	
	sub r10d, r9d		; R10D has n-k, will hold (n-k)!
f4nfact_setup:
	mov ecx, r8d		; first, we're going to do n!, so we're going to count down rcx = n, n-1, ..., 2, 1
	mov eax, 1		; start with cumulative product = 1 by default
f4nfact_top:			; do {...
	mul ecx			; 	cumulative_product *= rcx (n, n-1, ..., 2, 1)
	loop f4nfact_top	; ...} while (--rcx != 0);   <-- this will exit the loop before multiplying by 0
	mov r8d, eax		; EAX now holds n!, copy it back to R8D
f4kfact_setup:
	mov ecx, r9d		; next, we're going to do k!, so we're going to count down rcx = k, k-1, ..., 2, 1
	mov eax, 1		; start with cumulative product = 1 by default
f4kfact_top:			; do {...
	mul ecx			; 	cumulative_product *= rcx (k, k-1, ..., 2, 1)
	loop f4kfact_top	; ...} while (--rcx != 0);   <-- this will exit the loop before multiplying by 0
	mov r9d, eax		; EAX now holds k!, copy it back to R9D
f4nkfact_setup:
	mov ecx, r10d		; last, we're going to do (n-k)!, counting down as usual
	mov eax, 1		; start with cumulative product = 1 by default
f4nkfact_top:			; do {...
	mul ecx			; 	cumulative_product *= rcx (n-k, n-k-1, ..., 2, 1)
	loop f4nkfact_top	; ...} while (--rcx != 0);   <-- this will exit the loop before multiplying by 0
	mov r10d, eax		; EAX now holds (n-k)!, copy it back to R10D
f4makefraction:
	mul r9d			; EAX already has (n-k)!, so multiply that by k! that's in R9D
	mov ebx, eax		; EBX = (n-k)! * k!
	mov eax, r8d		; EAX = n!
	mov edx, 0		; extend properly into EDX:EAX for division
	div ebx			; EAX = n! / ((n-k)! * k!), and EDX holds the useless remainder
	mov [binomial], eax	; store the quotient in memory
	
exit:
	mov rax, 60		; syscall ID for sys_exit
	mov rdi, 0		; sys_exit code 0 for success
	syscall			; execute sys_exit with code 0
	
