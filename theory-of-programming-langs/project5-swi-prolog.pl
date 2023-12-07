/*
=================================================
+++++++++++++++++++++++++++++++++++++++++++++++++
AUTHOR: Brent Yelle
DATE:   March 26, 2023
CLASS:	Theory of Programming Languages, Project 5
+++++++++++++++++++++++++++++++++++++++++++++++++
=================================================
*/


/*
* ================================================================
Problem 1: mymember(value, list)
Check if a value is a member of a list.
* ================================================================
*/
mymember(X, [X]).								% BASE CASE: a singlet list's only member is its single element (tautologically).
mymember(X, [First | Tail]) :-					% By the Law of Excluded Middle, for any list containing X,
    X is First;									% ...X must be either the initial element
    mymember(X, Tail).							% ...or X must be a NON-initial element.

%all other configurations of elements and lists are false

/*
* ================================================================
Problem 2: myeven(a_number).
Check if an integer is even.
Here, "even-ness" is defined by checking numbers recursively toward 0.
* ================================================================
*/
myeven(0).										% BASE CASE: 0 is an even number.
myeven(X) :-									% Given an integer X
    X >= 2,										% ...where X is 2 or greater,
    Y is X - 2,	myeven(Y).						% ...then X is even if X-2 is even.
myeven(X) :-									% Given an integer X
    X =< -2,									% ...where X is -2 or less,
    Y is X + 2, myeven(Y).						% ...then X is even if X+2 is even.

% We don't need to worry about 1 or -1, since they're odd and thus automatically not even.

/*
* ================================================================
Problem 3: myevennumber(a_number, list).
Check if number of even values in a list of integers.
* ================================================================
*/

myevennumber(0, []).								% BASE CASE: The empty set contains no elements, and thus 0 even values.
myevennumber(1, [Element]) :- myeven(Element).		% BASE CASE: The singlet set of one even number contains 1 even value.
myevennumber(0, [Element]) :- not(myeven(Element)).	% BASE CASE: The singlet set of one non-even number contains 0 even values.
myevennumber(X, [First | Tail]) :-					% In general, given a list:
    myevennumber(N1, [First]),						% ...then if you add the number of even elements in the list containing its initial value...
    myevennumber(N2, Tail),							% ...to the number of even elements in the list containing its NON-initial values...
    X is N1 + N2.									% ...then you'll get the number of even elements in the WHOLE list.

/*
* ================================================================
Problem 4: myminlist(list, minimum_value).
Check if "minimum_value" is the lowest value that appears in "list."
* ================================================================
*/
myminlist(X, [X]).							% BASE CASE: The minimum value of a singlet set is the sole element.
myminlist(First, [First | Tail]) :-			% If the initial element is the minimum of the list,
    myminlist(Y, Tail),						% ...and if Y is the minimum of the list's non-initial elements,
    First =< Y.								% ...then the initial element must be less than or equal to Y.
myminlist(Minimum, [First | Tail]) :-		% Else, the minimum element of the list is NOT the initial element, so
    myminlist(Minimum, Tail),				% ...it's also the minimum of the list's non-initial elements,
    First >= Minimum.						% ...and the initial element must be greater than or equal to the minimum (since it's NOT the minimum).

/*
* ================================================================
Problem 5: palindrome(list).
Check if the list "list" is a palindrome (the same forwards and backwards).

To accomplish this task more clearly, I have created two helper functions:

trim_ends(List, TrimList):
 	"TrimList" is the list "List" without its first and last elements.

ends_equal(List):
 	Returns true if the first and last elements of the list "List" are equal.
* ================================================================
*/


trim_ends([_ | Tail], TrimList) :-		% Given a list, its trimmed form "TrimList" is the list such that the "Tail" (list of non-initial elements)
    append(TrimList, [_], Tail).		% can be formed by appending some element to the end of "TrimList".

ends_equal([First, Second]) :-			% For a doublet list:
    First is Second.					% ...It has equal ends if its first and second elements are equal
ends_equal([First | [_ | Tail]]) :-		% For a list containing 3 or more elements:
    append(_, [Last], Tail),			% ...Let "Last" be the final element of the list (i.e., that which needs to be appended to some list to get the tail of the list).
    First is Last.						% ...Then the list has equal ends if its first and last elements are equal.

palindrome([]).						% BASE CASE: an empty list is a palindrome by default
palindrome([_]).					% BASE CASE: a singlet list is a palindrome by default
palindrome([X, Y]) :- X is Y.		% SEMI-BASE CASE: a doublet list is a palindrome when its members are equal
palindrome([X, _, Y]) :- X is Y.	% SEMI-BASE CASE: a triplet list is a palindrome when its two ends are equal
palindrome(List) :-
	length(List, N),				% Let N be the length of the list, and without loss of generality,
    N > 3,							% assume N > 3 (since we've already dealt with cases of N = 0, 1, 2, 3);
    trim_ends(List, TrimList),		% in addition, let TrimList be the list without its first and last element.
    ends_equal(List),				% THEN: List is a palindrome if its ends are equal...
    palindrome(TrimList).			%       ...and if TrimList (the List without its two ends) is also a palindrome.

/*
* ================================================================
Problem 6: leafcount(T, N).
Check if the binary tree "T" has "N" leaves.

Binary trees are defined recursively by an atom "nil" representing an empty sub-branch
(the base case) and the term t(X, L, R), where:
 - X denotes the value of the root node
 - L denotes the left sub-tree
 - R denotes the right sub-tree
Where each sub-tree should either be "nil" or another t(_,_,_) term.
* ================================================================
*/

leafcount(T, 1) :- T = t(_, nil, nil).		% BASE CASE: A (sub-)tree consisting of only one node is a single leaf.
leafcount(T, N) :-							% If T is a (sub-)tree of leafcount N,
    T = t(_, nil, R),						% ...and T has only a right sub-tree,
    leafcount(R, NR),						% ...then if NR is the leafcount of the right subtree,
    N is NR.								% ...then N is equal to NR. (That is, all of the leaves of T are within the right subtree.)
leafcount(T, N) :-							% If T is a (sub-)tree of leafcount N,
    T = t(_, L, nil),						% ...and T has only a left subtree,
    leafcount(L, NL),						% ...then if NL is the leafcount of the left subtree,
    N is NL.								% ...then N is equal to NL. (That is, all of the leaves of T are within the left subtree.)
leafcount(T, N) :-							% If T is a (sub-)tree of leafcount N,
    T = t(_, L, R),							% ...and T has both left and right sub-branches,
	leafcount(L, NL),						% ...and NL is the leafcount of the left sub-branch,
    leafcount(R, NR),						% ...and NR is the leafcount of the right sub-branch,
    N is NL + NR.							% ...then N is equal to NL + NR.

/*
* ================================================================
BONUS - Problem 7: solution(Config,MoveList)
Solve the famous wolf-goat-cabbage problem--or as I originally heard it, the fox-chicken-grain problem.
Either way, we're using "wolf", "goat", and "cabbage" here.
 - Config contains the current configuration. (Starting config is [w,w,w,w].)
 - MoveList contains the final set of moves to get from the west to east bank.

Two helper functions are defined for this task:

otherside(A,B):
	returns true if A and B indicate opposite sides of the river.
safe(Config):
	checks if the current configuration is safe
move(Config, Move, NextConfig):
	takes the given move "Move", which changes from one safe configuration ("Config")
    to another one ("NextConfig").
    
Configurations are represented as a list of four elements which are all either w ("west")
or e ("east"), standing for the location of the farmer, wolf, goat, and cabbage on either
bank of the river.

Moves are represented as atoms ("wolf", "goat", "cabbage", "nothing") indicating the entity
which crosses the river with the farmer. The atom "nothing" means the farmer goes alone.
* ================================================================
*/

otherside(e,w).
otherside(w,e).

safe([X,X,X,X]).						% all entities on the same side is always safe
safe([X,_,X,X]).						% if the farmer is with the goat and cabbage, always safe
safe([X,X,X,_]).						% if the farmer is with the wolf and goat, always safe
safe([_,X,G,X]) :- otherside(G,X).		% wolf won't eat the cabbage, so as long as the goat isn't with the wolf or cabbage, we're safe

move([F1,W1,G1,C1], wolf, [F2,W2,G2,C2]) :-			% IF THE MOVE IS "wolf":
    otherside(F1,F2),								% ...the farmer crosses
    otherside(W1,W2),								% ...the wolf crosses
    G1 = G2,										% ...the goat stays
    C1 = C2.										% ...the cabbage stays
move([F1,W1,G1,C1], goat, [F2,W2,G2,C2]) :-			% IF THE MOVE IS "goat":
    otherside(F1,F2),								% ...the farmer crosses
    W1 = W2,										% ...the wolf stays
    otherside(G1,G2),								% ...the goat crosses
    C1 = C2.										% ...the cabbage stays
move([F1,W1,G1,C1], cabbage, [F2,W2,G2,C2]) :-		% IF THE MOVE IS "cabbage":
    otherside(F1,F2),								% ...the farmer crosses
    W1 = W2,										% ...the wolf stays
    G1 = G2,										% ...the goat stays
    otherside(C1,C2).								% ...the cabbage crosses
move([F1,W1,G1,C1], nothing, [F2,W2,G2,C2]) :-		% IF THE MOVE IS "nothing":
    otherside(F1,F2),								% ...the farmer crosses
    W1 = W2,										% ...the wolf stays
    G1 = G2,										% ...the goat stays
    C1 = C2.										% ...the cabbage stays

solution([e,e,e,e], []).							% BASE CASE: If everyone's on the east bank, we're done
solution(Config1, [Move1 | OtherMoves]) :-			% Given a configuration and a list of moves, those moves are correct if:
    move(Config1, Move1, Config2),					% ...the first move is valid
    safe(Config2),									% ...and the first move would give a safe configuration
    solution(Config2, OtherMoves).					% ...and the rest of the moves also do the same as the above.

