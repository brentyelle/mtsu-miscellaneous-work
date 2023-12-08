//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"


//                                                                           ##
// This file defines extensions of the cool AST for                          ##
// type checking project. More specifically, it addes the following methods:
// virtual InheritanceNodeP Program_class::semant();	use this function to start type checking
// virtual void Feature_class::tc(EnvironmentP) = 0;
// void Method::tc(EnvironmentP);
// void Attr::tc(EnvironmentP);
// void Branch_class::tc(EnvironmentP);
// virtual void Expression_class::tc(EnvironmentP) = 0;
// void tc(EnvironmentP); for all Expression descendants

//Each typechecking method contains three versions. For example in LetExp class, there are three tc methods:
// void tc_student(EnvironemntP);	//student's solution
// void tc_teacher(EnvironmentP);	//teacher's solution
// void tc(EnvironmentP);			//decide which version to use

// A member: Symbol type; is added to Expression and all its descendents 
//			 to track the type of the expression
// Other declared methods:
// The following three methods used to check method and attributes before adding them
// to the environment of the class.
// virtual void Feature_class::add_to_table(EnvironmentP) = 0; 
// void Method::add_to_table(EnvironmentP);
// void Attr::add_to_table(EnvironmentP);
 

#ifndef COOL_TREE_HANDCODE_H
#define COOL_TREE_HANDCODE_H

#include "StringTab.h"

class InheritanceNode;                               
typedef InheritanceNode *InheritanceNodeP;           
													 
class Environment;                                   
typedef Environment *EnvironmentP;
//##

#define Program_EXTRAS                        \
virtual InheritanceNodeP semant();

#define Feature_EXTRAS                        \
virtual void tc(EnvironmentP) = 0;            \
virtual void tc_student(EnvironmentP) = 0;    \
virtual void tc_teacher(EnvironmentP) = 0;    \
virtual void add_to_table(EnvironmentP) = 0; 

#define Feature_SHARED_EXTRAS             \
void tc(EnvironmentP);                    \
void tc_student(EnvironmentP);            \
void tc_teacher(EnvironmentP);            \
void add_to_table(EnvironmentP);                          

#define Formal_EXTRAS                         \
virtual void tc(EnvironmentP);                    \
virtual void tc_student(EnvironmentP);            \
virtual void tc_teacher(EnvironmentP);            \

#define Branch_EXTRAS                       \
virtual Symbol tc(EnvironmentP env);		\
virtual Symbol tc_student(EnvironmentP);    \
virtual Symbol tc_teacher(EnvironmentP);            

#define Expression_EXTRAS                    \
virtual Symbol tc(EnvironmentP) = 0;         \
virtual Symbol tc_student(EnvironmentP) = 0; \
virtual Symbol tc_teacher(EnvironmentP) = 0; \
Symbol type;                                 \
Symbol getType() { return type; }            \
Expression setType(Symbol s) { type = s; return this; } 


#define Expression_SHARED_EXTRAS          \
Symbol tc(EnvironmentP);                  \
Symbol tc_student(EnvironmentP);          \
Symbol tc_teacher(EnvironmentP);

#endif
