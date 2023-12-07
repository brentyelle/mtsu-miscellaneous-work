; ==================================================================
; maxMin
; PARAM1 (RDI) -- maximum of an array (pass by reference)- output parameter
; PARAM2 (RSI) -- minimum of an array (pass by reference)- output parameter
; PARAM3 (RDX) -- address of array (pass by reference)- input parameter
; PARAM4 (RCX) -- array size (pass by value)- input parameter
; RETURN (RAX) -- returns 0 if successful, 1 if invalid array size
; ==================================================================
global maxMin
section .text
maxMin:
	cmp rcx, 0						; compare array size to 0
	jne maxMin_valid				; so long as it's not 0, we're good
	mov rax, 1						; otherwise, set up to return 1
	jmp maxMin_return				; and exit the function without doing anything
maxMin_valid:
	push rcx						; store array size for later
	push rdx						; store array address for later
	mov r9, [rdx]					; R9 will temporarily store the minimum value
	mov r10, [rdx]					; R10 will temporarily store the maximum value
maxMin_loop_checkmax:
	cmp [rdx], r10					; if array[i] isn't > current maximum
	jng maxMin_loop_checkmin		; then we don't need to update the current maximum
	mov r10, [rdx]					; else, update the current maximum to be array[i]
maxMin_loop_checkmin:
	cmp [rdx], r9					; if array[i] isn't < current minimum
	jnl maxMin_loop_condition		; then we don't need to update the current minimum
	mov r9, [rdx]					; else, update the current minimum to be array[i]
maxMin_loop_condition:
	add rdx, 8						; effectively i++
	loop maxMin_loop_checkmax		; loop until we finish the last element
maxMin_postloop:
	pop rdx							; restore the pre-function value (not required, but nice to do)
	pop rcx							; restore the pre-function value (not required, but nice to do)
	mov [rdi], r10					; update the maximum by reference
	mov [rsi], r9					; update the minimum by reference
	mov rax, 0						; return 0, since we succeeded
maxMin_return:
	ret