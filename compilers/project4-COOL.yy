 /*
PROGRAMMER:     Brent Yelle
PROJECT #:      Project 4
DUE DATE:       Wednesday, 2023/10/31
INSTRUCTOR:     Dr. Zhijiang Dong
DESCRIPTION:
    This file, COOL.yy, is designed to work with the Bison parser generator to create a parser for the COOL programming language.
    For Project #4 in particular, we (temporarily?) removed all the error handling, but otherwise created all of the rules required to build an Abstract Syntax Tree from a syntactically-correct COOL program.
 */


%debug
%verbose

%code requires {
#include <iostream>
#include "ErrorMsg.h"
#include "StringTab.h"
#include "Absyn.h"

using namespace absyn;
}

 /*
 The following UNION defines data type for the semantic values of 
 all language constructs (i.e. non-terminals and terminals).
 */
%union {
        Symbol			symbol;		//to store the index of symbol in literal tables like intTable, stringTable, and idTable.
        bool			boolean;	//to store boolean constants
        Program			program;	//to store the object representing a COOL program
        Class_			class_;		//to store the definition of one COOL class
        Classes			classes;	//to represent a list of COOL classes
        Feature			feature;	//to store one feature (i.e. method or attribute) definition of a class
        Features		features;	//to represent a list of features
        Formal			formal;		//to store a formal parameter including parameter name and type
        Formals			formals;	//to represent the list of formals for a method
        Branch			branch;		//to store one branch of case expression in COOL
        Branches		branches;	//to represent the list of case branches in a case expression
        Expression		expression;	//to store one expression
        Expressions		expressions;//to represent a list of expressions
}

%{
extern string curr_filename;	//current file name

int yylex(void); /* function prototype */
void yyerror(char *s);	//called by the parser whenever an eror occurs

template<typename Item>
List<Item>* single_list(Item i);	//create a list of one item only

template<typename Item>
List<Item>* pair_list(Item head, List<Item>* rest);	//create a list of two items: head and tail
                                                                                                        //tail itself is a list


Program root;			/* the root of generated abstract syntax tree */
%}


/* Declare types for the grammar's non-terminals. */
///////////////////////////////////////////////////////////////////
/*
I use the following non-terminals. You need to replace them with 
your own non-terminals. Make sure these non-terminals and ones
used in your CFG rules are consistent.
*/
///////////////////////////////////////////////////////////////////
%nterm <program>     program
%nterm <classes>     class_list
%nterm <class_>      class
%nterm <features>    feature_list optional_feature_list
%nterm <feature>     feature
%nterm <formals>     formal_list optional_formal_list
%nterm <formal>		 formal
%nterm <expression>	 expr optional_assignment let_list
%nterm <expressions> expr_list argument_list optional_argument_list
%nterm <branches>    case_list 
%nterm <branch>      simple_case

/* Declare types for the grammar's terminals. */
%token <symbol>      STR_CONST TYPEID OBJECTID INT_CONST 
%token <boolean>     BOOL_CONST

%token CLASS ELSE FI IF IN 
%token INHERITS LET LOOP POOL THEN WHILE 
%token CASE ESAC OF DARROW NEW ISVOID 
%token ASSIGN NOT LE 

/* Precedence declarations. */
%left LET_STMT
%right ASSIGN
%left NOT
%nonassoc LE '<' '='
%left '-' '+'
%left '*' '/'
%left ISVOID
%left '~'
%left '@'
%left '.'

%start program

%%


program	        : class_list
            { root = new Program_class(@1.first_line, @1.first_column, $1); }	  
                ;

class_list 	    :	class			
                        { $$ = single_list($1); }
                |	class class_list	// several classes
                        { $$ = pair_list($1, $2); }
                ;

// If no parent is specified, the class inherits from the Object class.
class	        :	CLASS TYPEID '{' optional_feature_list '}' ';'
                        { $$ = new Class_class(@1.first_line, @1.first_column, 
                                                                        stringtable.add_string(curr_filename),
                                                                        $2, idtable.add_string("Object"), $4); }
                |	CLASS TYPEID INHERITS TYPEID '{' optional_feature_list '}' ';'
                        { $$ = new Class_class(@1.first_line, @1.first_column, 
                                                                        stringtable.add_string(curr_filename),
                                                                        $2, $4, $6); }
                ;

////////////////////////////////////////////////////////////////////////////
/*
* Copy CFG Rules from previous assignment here, and remove all rules for error recovery.
* Make sure your non-terminals are consistent with ones defined in above.
* For each rule, please define actions to construct AST.
*/
//////////////////////////////////////////////////////////////////////////


optional_feature_list   : //nothing
                                { $$ = nullptr; }
                        | feature_list             	// at least one feature
                                { $$ = $1; }
                        ;

feature_list            : feature ';'                   // just one feature, or the last feature of the list
                                { $$ = single_list($1); }
                        | feature ';' feature_list      // list of features
                                { $$ = pair_list($1, $3); }
                        ;

feature                 : OBJECTID '(' optional_formal_list ')' ':' TYPEID '{' expr '}'     // method definition
                                { $$ = new Method(@1.first_line, @1.first_column, $1, $3, $6, $8); }
                        | OBJECTID ':' TYPEID optional_assignment                           // attribute definition
                                { $$ = new Attr(@1.first_line, @1.first_column, $1, $3, $4); }
                        ; 

optional_formal_list    : //formal list can be empty
                                { $$ = nullptr; }
                        | formal_list                   // possibly empty list of formals
                                { $$ = $1; }
                        ;

formal_list             : formal                        // one formal, or last formal
                                { $$ = single_list($1); }
                        | formal ',' formal_list        // multiple formals
                                { $$ = pair_list($1, $3); }
                        ;

formal                  : OBJECTID ':' TYPEID           // parameter name, and its type
                                { $$ = new Formal_class(@1.first_line, @1.first_column, $1, $3); }
                        ;

optional_assignment     : // nothing               no assignment
                                { $$ = nullptr; }
                        | ASSIGN expr           // assign the variable
                                { $$ = $2; }
                        ;

expr                    : OBJECTID ASSIGN expr                                              // assignment of a variable
                                { $$ = new AssignExp(@1.first_line, @1.first_column, $1, $3); }
                        | expr '.' OBJECTID '(' optional_argument_list ')'                  // expression without downcast
                                { $$ = new CallExp(@1.first_line, @1.first_column, $1, $3, $5); }
                        | expr '@' TYPEID '.' OBJECTID '(' optional_argument_list ')'       // expression with downcast
                                { $$ = new StaticCallExp(@1.first_line, @1.first_column, $1, $3, $5, $7); }
                        | OBJECTID '(' optional_argument_list ')'                           // invoking a function
                                { Expression self_obj = new absyn::ObjectExp(@1.first_line, @1.first_column, idtable.add_string("self"));
                                  $$ = new CallExp(@1.first_line, @1.first_column, self_obj, $1, $3); }
                        | IF expr THEN expr ELSE expr FI                                    // if-then-else clause
                                { $$ = new IfExp(@1.first_line, @1.first_column, $2, $4, $6); }
                        | WHILE expr LOOP expr POOL                                         // while loop
                                { $$ = new WhileExp(@1.first_line, @1.first_column, $2, $4); }
                        | '{' expr_list '}'                                                 // multiple expressions in one expression
                                { $$ = new BlockExp(@1.first_line, @1.first_column, $2); }
                        | LET let_list                                                      // declare local variable
                                { $$ = $2; }
                        | CASE expr OF case_list ESAC                                       // type testing
                                { $$ = new CaseExp(@1.first_line, @1.first_column, $2, $4); }
                        | NEW TYPEID                                                        // allocate new variable of type
                                { $$ = new NewExp(@1.first_line, @1.first_column, $2); }
                        | ISVOID expr                                                       // check if void
                                { $$ = new IsvoidExp(@1.first_line, @1.first_column, $2); }
                        | expr '+' expr                                                     // arithmetic: addition
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::PLUS, $3); }
                        | expr '-' expr                                                     // arithmetic: subtraction
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::MINUS, $3); }
                        | expr '*' expr                                                     // arithmetic: multiplication
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::MUL, $3); }
                        | expr '/' expr                                                     // arithmetic: division
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::DIV, $3); }
                        | '~' expr                                                          // arithmetic: unary negation
                                { Expression UNARY_NEGATION_ZERO = new IntExp(@1.first_line, @1.first_column, inttable.add_int(0));
                                  $$ = new OpExp(@1.first_line, @1.first_column, UNARY_NEGATION_ZERO, OpExp::MINUS, $2); }
                        | expr '<' expr                                                     // logical: less than
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::LT, $3); }
                        | expr LE expr                                                      // logical: less than or equal to
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::LE, $3); }
                        | expr '=' expr                                                     // logical: equal to
                                { $$ = new OpExp(@1.first_line, @1.first_column, $1, OpExp::EQ, $3); }
                        | NOT expr                                                          // logical: not
                                { $$ = new NotExp(@1.first_line, @1.first_column, $2); }
                        | '(' expr ')'                                                      // put expression in parentheses
                                { $$ = $2; }
                        | OBJECTID                                                          // invoke a variable
                                { $$ = new ObjectExp(@1.first_line, @1.first_column, $1); }
                        | INT_CONST                                                         // integer literal
                                { $$ = new IntExp(@1.first_line, @1.first_column, $1); }
                        | STR_CONST                                                         // string literal
                                { $$ = new StringExp(@1.first_line, @1.first_column, $1); }
                        | BOOL_CONST                                                        // boolean literal
                                { $$ = new BoolExp(@1.first_line, @1.first_column, $1); }
                        ;

optional_argument_list  : // nothing
                                { $$ = nullptr; }
                        | argument_list                 // arguments of a function (maybe none)
                                { $$ = $1; }
                        ;

argument_list           : expr                          // last or only argument
                                { $$ = single_list($1); }
                        | expr ',' argument_list        // list of arguments
                                { $$ = pair_list($1, $3); }
                        ;

expr_list               : expr ';'                      // last or only expression
                                { $$ = single_list($1); }
                        | expr ';' expr_list            // list of expressions
                                { $$ = pair_list($1, $3); }
                        ;

let_list                : OBJECTID ':' TYPEID optional_assignment IN expr %prec LET_STMT
                                { $$ = new LetExp(@1.first_line, @1.first_column, $1, $3, $4, $6); }
                        | OBJECTID ':' TYPEID optional_assignment ',' let_list
                                { $$ = new LetExp(@1.first_line, @1.first_column, $1, $3, $4, $6); }    // is using $6 here correct?

case_list               : simple_case
                                { $$ = single_list($1); }
                        | simple_case case_list
                                { $$ = pair_list($1, $2); }
                        ;

simple_case             : OBJECTID ':' TYPEID DARROW expr ';'
                                { $$ = new Branch_class(@1.first_line, @1.first_column, $1, $3, $5); }
                        ;


/* end of grammar */
%%

#include <FlexLexer.h>
extern yyFlexLexer	lexer;
int yylex(void)
{
        return lexer.yylex();
}

void yyerror(char *s)
{	
        extern ErrorMsg errormsg;
        errormsg.error(yylloc.first_line, yylloc.first_column, s);
}

template<typename Item>
List<Item>* single_list(Item i) 
{
        return new List<Item>(i, nullptr);
}

template<typename Item>
List<Item>* pair_list(Item head, List<Item>* rest)
{
        return new List<Item>(head, rest);
}
