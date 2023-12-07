#lang racket

; CONSTANTS FOR TESTING
(define toCountZeroes '(1 0 2 0 3 0 0 4))
(define toReverse '(1 2 3 4 5))
(define toPalindromeOdd  '(1 2 3  4  3 2 1))
(define toPalindromeEven '(1 2 3 4 4 3 2 1))
(define FirstNames '(Brent John Bill Firstname))
(define LastNames '(Yelle Doe Clinton Lastname))

; ASSIGNMENT: Write a non-recursive Scheme function area(r) that given the radius r of a circle, computes its area as 3.14 * r * r.
(define (area r) (* 3.14 r r))

; ASSIGNMENT: Write a recursive Scheme function power(A, B) that takes two integer parameters, A and B, and returns A raised to the B power. A must be a positive value, but B maybe a negative value.
(define
  (power A B) (                    ; (A & B integers, must have A>0)
               if (= B 0)          ; if B = 0
                  1                ; then return 1  (Base Case)
                  (if (> B 0)      ; otherwise, if B > 0
                      (* (power A (- B 1)) A)    ; then we recursively do:  A^B = A^(B-1) * A (counts B down to 0)
                      (/ (power A (+ B 1)) A)    ; otherwise, B < 0, and so A^B = A^(B+1) / A (counts B up to 0)
                      )
               )
  )

; ASSIGNMENT: Write a recursive Scheme function countZero(list) that returns the number of value zeros in a given simple list of numbers. For example, (countZero ‘(1 0 2 3 0)) should return 2.
(define
  (countZero lst) (
                   if (= 0 (length lst))                 ; if the list is empty,
                      0                                  ; then by default, it contains no zeroes. (Base Case)
                      (if (= (car lst) 0)                ; otherwise, if first element is 0,
                          (+ (countZero (cdr lst)) 1 )   ; then pop the first element and return 1 + the count for the rest of the list
                          (countZero (cdr lst))          ; otherwise, pop the first element and return (0 +) the count for the rest of the list
                          )
                      )
  )

; ASSIGNMENT: Write a recursive Scheme function reverse(list) that returns the reverse of its simple list parameter. For example, (reverse ‘(1 2 3 a b)) should return ‘(b a 3 2 1).
(define (reverse lst) (
                       if (<= (length lst) 1)                   ; if it's a list of 1 or 0 element(s)
                          lst                                   ; then it's already reversed (Base Case)
                          (list*                                ; else, return a new list containing
                           (last lst)                           ; the last element of the list (moved to the front), followed by
                           (reverse (drop-right lst 1) )        ; the reversed form of the rest of the list
                           )
                          )
  )

; ASSIGNMENT: Write a recursive Scheme function palindrome(list) that returns true if the simple list reads the same forward and backward; otherwise returns false. For example, (palindrome ‘(a 1 b 1 a)) returns true, while (palindrome ‘(a b)) returns false.
(define (palindrome lst) (
                          if (<= (length lst) 1)       ; if the list is length 1 or 0
                             true                      ; then it's automatically a palindrome  (Base Case)
                             (and                      ; otherwise, it's a palindrome if both:
                              (= (car lst) (last lst))                ; current first & last elements are the same
                              (palindrome (cdr (drop-right lst 1)))   ; AND everything between them is also a palindrome
                              )
                             )
  )

; ASSIGNMENT: Write a recursive Scheme function merge(firstNameList, lastNamelist) that receives a simple list of first names and a simple list of last names, and merges the two lists into one list consisting of (firstName lastName) pairs. Display the result list. For example, if the inputs are (John Kim Kate George), (Davidson Hunter Johnson Olson), the output should be ( (John Davidson) (Kim Hunter) (Kate Johnson) (George Olson) ).
(define (merge firstNameList lastNameList) (
                                            if ( = (length firstNameList) (length lastNameList) 1)         ; if the first two lists have the same length, and it's 1
                                               (list (list (car firstNameList) (car lastNameList) ))       ; then combine the names into a doublet and put that doublet in a list (Base Case)
                                               (cons                                                       ; otherwise, recursively build a list of:
                                                (list (car firstNameList) (car lastNameList) )             ; the first pair of names...
                                                (merge (cdr firstNameList) (cdr lastNameList) ) )          ; ...followed by the paired rest of the lists.
                                               )
  )
