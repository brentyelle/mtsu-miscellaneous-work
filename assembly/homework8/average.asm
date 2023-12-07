; ==================================================================
; computeAvg
; PARAM1 (RDI) -- address of array (pass by reference)- input parameter
; PARAM2 (RSI) -- array size (pass by value)- input parameter
; RETURN (RAX) -- average of the array (by value), or 0 if the array is size 0

; This function assumes the array pointed to by RDI contains quadword-length integers.
; ==================================================================

global computeAvg
section .text
computeAvg:
	mov rax, 0							; RAX will hold the average of the array
	cmp rsi, 0							; compare array size to 0
	jne computeAvg_valid				; so long as it's not 0, we're good
	jmp computeAvg_return				; otherwise, exit the function (and return 0)
computeAvg_valid:
	mov rcx, rsi						; array size in loop counter
computeAvg_looptop:
	add rax, [rdi]						; cumulative sum of all elements
	add rdi, 8							; array[i] --> array[i+1]  (elements are size 8)
	loop computeAvg_looptop				; for each element in the loop
computeAvg_postloop:
    cqo                                 ; sign-extend RAX into RDX:RAX
	idiv rsi						    ; divide accumulated sum by # of elements, storing the quotient (the average) in RAX
computeAvg_return:
	ret