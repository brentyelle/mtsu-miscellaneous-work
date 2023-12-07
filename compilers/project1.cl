(*
PROGRAMMER:     Brent Yelle
PROGRAM #:      Program 1
DUE DATE:       Monday, 9/11/23
INSTRUCTOR:     Dr. Zhijiang Dong
LANGUAGE:       COOL Programming Language (https://theory.stanford.edu/~aiken/software/cool/cool.html)
DESCRIPTION:
    This project is an implementation of a simple stack machine with addition capabilities. It has five functionalities:
        - Entering an integer will push that integer onto the stack (in string form).
        - Entering + will push a '+' onto the stack.
        - Entering d will display the stack's current contents.
        - Entering e will evaluate the top of the stack: If it is +, then the + and the next two elements are popped, then summed, and then their sum is added to the top of the stack in their place. If the top of the stack is an integer, nothing happens.
        - Entering x will kill the program.
    The stack itself is implemented using a slightly-modified version of the "List" (and underlying "Cons") class defined in list.cl provided by the instructor, copied here and then edited.
    The conversion from string to and from integer is done via the "A2I" class, also provided by the instructor.
*)

(*
=============================================================
   The class A2I provides integer-to-string and string-to-integer
conversion routines.  To use these routines, either inherit them
in the class where needed, have a dummy variable bound to
something of type A2I, or simpl write (new A2I).method(argument).
=============================================================
*)

class A2I {
(* Converts a 1-character string to an integer. Aborts if the string is not "0" through "9" *)
    c2i(char : String) : Int {
        if char = "0" then 0 else
        if char = "1" then 1 else
        if char = "2" then 2 else
        if char = "3" then 3 else
        if char = "4" then 4 else
        if char = "5" then 5 else
        if char = "6" then 6 else
        if char = "7" then 7 else
        if char = "8" then 8 else
        if char = "9" then 9 else
        { abort(); 0; }  -- the 0 is needed to satisfy the typchecker
        fi fi fi fi fi fi fi fi fi fi
    };

(* i2c is the inverse of c2i. *)
    i2c(i : Int) : String {
        if i = 0 then "0" else
        if i = 1 then "1" else
        if i = 2 then "2" else
        if i = 3 then "3" else
        if i = 4 then "4" else
        if i = 5 then "5" else
        if i = 6 then "6" else
        if i = 7 then "7" else
        if i = 8 then "8" else
        if i = 9 then "9" else
        { abort(); ""; }  -- the "" is needed to satisfy the typchecker
        fi fi fi fi fi fi fi fi fi fi
    };

(* Converts an ASCII string into an integer.  The empty string is converted to 0.  Signed and unsigned strings are handled.  The method aborts if the string does not represent an integer.  Very long strings of digits produce strange answers because of arithmetic  overflow. *)
    a2i(s : String) : Int {
        if s.length() = 0 then 0 else
	    if s.substr(0,1) = "-" then ~a2i_aux(s.substr(1,s.length()-1)) else
        if s.substr(0,1) = "+" then a2i_aux(s.substr(1,s.length()-1)) else
           a2i_aux(s)
        fi fi fi
    };

(* Converts the unsigned portion of the string.  As a programming example, this method is written iteratively. *)
    a2i_aux(s : String) : Int {
        (let int : Int <- 0 in
            {
                (let j : Int <- s.length() in
                    (let i : Int <- 0 in
                    while i < j loop {
                            int <- int * 10 + c2i(s.substr(i,1));
                            i <- i + 1;
                    } pool
                    )
                );
                int;
            }
        )
    };

(* Converts an integer to a string.  Positive and negative numbers are handled correctly. *)
    i2a(i : Int) : String {
        if i = 0 then "0" else
            if 0 < i then i2a_aux(i) else
            "-".concat(i2a_aux(i * ~1))
        fi fi
    };

(* i2a_aux is an example using recursion. *)
    i2a_aux(i : Int) : String {
        if i = 0 then "" else
            (let next : Int <- i / 10 in
            i2a_aux(next).concat(i2c(i - next * 10))
            )
        fi
    };

};

(*
=============================================================
Copied from list.cl and then edited to be a list of strings rather than integers, as we were instructed to do in the specifications for this assignment.
=============================================================
*)
class List {
    -- Define operations on empty lists.

    -- All lists are empty by default. This is overridden by the Cons child class.
    isNil() : Bool { true };

    -- Since abort() has return type Object and head() has return type
    -- Int, we need to have an Int as the result of the method body,
    -- even though abort() never returns.
    head()  : String { { abort(); ""; } };

    -- As for head(), the self is just to make sure the return type of
    -- tail() is correct.
    tail()  : List { { abort(); self; } };

    -- When we cons and element onto the empty list we get a non-empty
    -- list. The (new Cons) expression creates a new list cell of class
    -- Cons, which is initialized by a dispatch to init().
    -- The result of init() is an element of class Cons, but it
    -- conforms to the return type List, because Cons is a subclass of
    -- List.
    cons(i : String) : List {
        (new Cons).init(i, self)
    };
};


(*
 *  Cons inherits all operations from List. We can reuse only the cons
 *  method though, because adding an element to the front of an emtpy
 *  list is the same as adding it to the front of a non empty
 *  list. All other methods have to be redefined, since the behaviour
 *  for them is different from the empty list.
 *
 *  Cons needs two attributes to hold the integer of this list
 *  cell and to hold the rest of the list.
 *
 *  The init() method is used by the cons() method to initialize the
 *  cell.
 *)

class Cons inherits List {

    car : String;	-- The element in this list cell
    cdr : List;	-- The rest of the list

    isNil() : Bool { false };

    head()  : String { car };

    tail()  : List { cdr };

    init(i : String, rest : List) : List {{
        car <- i;
        cdr <- rest;
        self;
    }};
};


(*
=============================================================
My solution
=============================================================
*)

class Main inherits IO {
    main() : Int {
        let stack : List <- new List, currentCommand : String in {
            currentCommand <- prompt();                                             -- get user input
            while not (currentCommand = "x") loop {                                 -- keep going until user enters 'x'
                if currentCommand = "e" then stack <- evalStack(stack) else
                if currentCommand = "d" then stack <- displayStack(stack) else
                if currentCommand = "+" then stack <- pushPlus(stack) else
                stack <- pushNumber(currentCommand, stack)                          -- if not one of the above special characters, assume it's an integer
                fi fi fi;
                currentCommand <- prompt();                                         -- prompt user for next command
            } pool;
            0;                                                                      -- return 0, as any good main() function should
        }
    };

    -- Prompt the user for the next operation or input to put on the stack.
    prompt() : String {
        let userInput : String in {
            out_string(">");                            -- '>' indicates the program is awaiting a prompt, as instructed
            userInput <- in_string();                   -- grab user input from stdin and return the grabbed string
        }
    };

    (* Evaluate the current top of the stack:
        - If top of stack is a number, do nothing.
        - If top of stack is +, then pop it and the next two numbers, then add them.
       It is assumed that the stack has no errors in syntax, and that each + is always followed by two integers (avoiding recursion).   *)
    evalStack(s : List) : List {
        if s.head() = "+" then
            let first : Int, second : Int, string_fns : A2I <- new A2I in {     -- string_fns is a dummy variable to access A2I methods
                -- pop the +
                s <- s.tail();
                -- read then pop the first addend
                first <- string_fns.a2i(s.head());
                s <- s.tail();
                -- read then pop the second addend
                second <- string_fns.a2i(s.head());
                s <- s.tail();
                -- add the addends, convert result to a string, then put result on top of stack, then return the stack
                s <- s.cons(string_fns.i2a(first + second));
            }
        else s fi      -- otherwise (if not a +), return the stack with no changes
    };

    -- Print every element of the stack list on a new line.
    displayStack(s : List) : List {
        let currHead : String, currTail : List in {
            currHead <- s.head();
            currTail <- s.tail();                           -- Copy of the list, to iterate over.
            out_string(currHead); out_string("\n");
            while not (currTail.isNil()) loop {             -- Until there are no more strings to be printed...
                currHead <- currTail.head();                -- Grab the next string for printing
                currTail <- currTail.tail();                -- Trim off the string that will be printed.
                out_string(currHead); out_string("\n");     -- Print the to-be-printed string, with a newline.
            } pool;
            s;                                              -- return the stack, because why not
        }
    };

    pushPlus(s : List) : List {
        s <- s.cons("+")                                    -- add + to list/stack, then return the list/stack
    };

    pushNumber(n : String, s : List) : List {
        s <- s.cons(n)                                      -- add the integer to the stack (in string form), then return the list/stack
    };

};


