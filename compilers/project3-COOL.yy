 /*
PROGRAMMER:     Brent Yelle
PROJECT #:      Project 3
DUE DATE:       Wednesday, 2023/10/18
INSTRUCTOR:     Dr. Zhijiang Dong
DESCRIPTION:
    This file, COOL.yy, is designed to work with the Bison parser generator to create a parser for the COOL programming language.
    Ordinarily, each rule of the CFG would have an action associated with it, but for this project, we are first just implementing the CFG and making sure that we can handle the various error cases that may arise.
 */

%debug
%verbose
%locations

%code requires {
#include <iostream>
#include "ErrorMsg.h"
#include "StringTab.h"

int yylex(void); /* function prototype */
void yyerror(char *s);    //called by the parser whenever an eror occurs

}

%union {
    bool        boolean;    
    Symbol        symbol;    
}

%token <symbol>        STR_CONST TYPEID OBJECTID INT_CONST 
%token <boolean>    BOOL_CONST

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

/*
* The above only gives precedence levels of some operators.
* Please provide precedence levels of other operators : LE '<' '=', ISVOID '~' '@' '.'
*/

%start program

%%

/*
 * The following is CFG of COOL programming languages. Several simple rules in the following comments are given for demonstration purpose.
 * You can uncomment them and provide extra rules for the CFG. Please be noted that you uncomment without providing extra rules, BISON will
 * will report errors when compiling COOL.yy file since several non-terminals are not defined.
 * 
 
 * No rule action needed in this assignment 
 * If a recusive rule is needed, for example, define a list of something, always use 
 * right recursion like:
 * class_list : class class_list
 *
 */


//A COOL program is viewed as a list of classes 
program                 : class_list
                        | error                         // bad list
                        ;

class_list              : class ';'                     // just one class, or the last class of the list
                        | error ';'                     // error in the last class
                        | error ';' class_list          // error in the first class
                        | class ';' class_list          // several classes
                        ;

// If no parent is specified, the class inherits from the Object class. 
class                   : CLASS TYPEID '{' optional_feature_list '}'                        // basic type (inhertis from Object)
                        | CLASS TYPEID INHERITS TYPEID '{' optional_feature_list '}'        // type derived from another type
                        ;

// Feature list may be empty, but no empty features in list. 

optional_feature_list   : // nothing
                        | feature_list                  // list of methods and attributes
                        ;

feature_list            : feature ';'                   // just one feature, or the last feature of the list
                        | error                         // entirely bad feature
                        | error ';'                     // bad feature, but with a semicolon
                        | feature ';' feature_list      // list of features
                        | error ';' feature_list        // error in the first feature
                        ;

feature                 : OBJECTID '(' optional_formal_list ')' ':' TYPEID '{' expr '}'     // method definition
                        | formal optional_assignment                                        // attribute definition
                        ; 

optional_formal_list    : //formal list can be empty
                        | formal_list                   // possibly empty list of formals
                        ;

formal_list             : formal                        // one formal, or last formal
                        | formal ',' formal_list        // multiple formals
                        ;

formal                  : OBJECTID ':' TYPEID           // parameter name, and its type
                        | error
                        ;

expr                    : OBJECTID ASSIGN expr                                              // assignment of a variable
                        | expr '.' OBJECTID '(' optional_argument_list ')'                  // expression without downcast
                        | expr '@' TYPEID '.' OBJECTID '(' optional_argument_list ')'       // expression with downcast
                        | OBJECTID '(' optional_argument_list ')'                           // invoking a function
                        | IF expr THEN expr ELSE expr FI                                    // if-then-else clause
                        | WHILE expr LOOP expr POOL                                         // while loop
                        | '{' expr_list '}'                                                 // multiple expressions in one expression
                        | LET let_variable_list IN expr                                     // declare local variable
                        | CASE expr OF case_list ESAC                                       // type testing
                        | NEW TYPEID                                                        // allocate new variable of type
                        | ISVOID expr                                                       // check if void
                        | expr '+' expr                                                     // arithmetic: addition
                        | expr '-' expr                                                     // arithmetic: subtraction
                        | expr '*' expr                                                     // arithmetic: multiplication
                        | expr '/' expr                                                     // arithmetic: division
                        | '~' expr                                                          // arithmetic: unary negation
                        | expr '<' expr                                                     // logical: less than
                        | expr LE expr                                                      // logical: less than or equal to
                        | expr '=' expr                                                     // logical: equal to
                        | NOT expr                                                          // logical: not
                        | '(' expr ')'                                                      // put expression in parentheses
                        | OBJECTID                                                          // invoke a variable
                        | INT_CONST                                                         // integer literal
                        | STR_CONST                                                         // string literal
                        | BOOL_CONST                                                        // boolean literal
                        | error                                                             // nonsensical expression
                        ;

optional_argument_list  : // nothing
                        | argument_list                 // arguments of a function (maybe none)
                        ;

argument_list           : expr                          // last or only argument
                        | expr ',' argument_list        // list of arguments
                        ;

expr_list               : expr ';'                      // last or only expression
                        | expr ';' expr_list            // list of expressions
                        ;

let_variable_list       : formal optional_assignment                            // let statement with one variable
                        | formal optional_assignment ',' let_variable_list      // let statement with multiple variables
                        ;

optional_assignment     : // nothing               no assignment
                        | ASSIGN expr           // assign the variable
                        | error                 // bad assignment
                        ;

case_list               : formal DARROW expr ';'                // good down-cast
                        | error ';'                             // bad down-cast
                        | formal DARROW expr ';' case_list      // good down-cast list
                        | error ';' case_list                   // bad-down cast list
                        ;


/* end of grammar */

%%
#include <FlexLexer.h>
extern yyFlexLexer    lexer;
int yylex(void)
{
    return lexer.yylex();
}

void yyerror(char *s)
{    
    extern ErrorMsg errormsg;
    errormsg.error(yylloc.first_line, yylloc.first_column, s);
}


