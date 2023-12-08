#include "Absyn.h"
#include "Semant.h"

using namespace absyn;

#define student_version tc_student(env)
#define teacher_version tc_teacher(env)


// The function which runs the semantic analyser.
extern void initialize_constants();
InheritanceNodeP Program_class::semant()
{

	initialize_constants();
	ClassTableP classtable = new ClassTable(classes);

	if (classtable->errors()) {
		cerr << "Compilation halted due to static semantic errors." << endl;
		exit(1);
	}

	return classtable->root();
}

///////////////////////////////////////////////////////////////////////////////
//
//  Type Checking Features
//
//  Replace student_version in the following method with teacher_version will
//  use teacher's type checking solution for that class.
//  You can do that step by step to test your solution.
//
///////////////////////////////////////////////////////////////////////////////

void Attr::tc(EnvironmentP env)
{
	return student_version;
}


Symbol IntExp::tc(EnvironmentP env)
{
	return teacher_version;
}

Symbol BoolExp::tc(EnvironmentP env)
{
	return teacher_version;
}

Symbol StringExp::tc(EnvironmentP env)
{
	return teacher_version;
}


Symbol OpExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol NotExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol ObjectExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol NewExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol IsvoidExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol LetExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol BlockExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol AssignExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol CallExp::tc(EnvironmentP env)
{
	return teacher_version;
}

Symbol StaticCallExp::tc(EnvironmentP env)
{
	return teacher_version;
}

Symbol IfExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol WhileExp::tc(EnvironmentP env)
{
	return student_version;
}

Symbol Branch_class::tc(EnvironmentP env)
{
	return teacher_version;
}

Symbol CaseExp::tc(EnvironmentP env)
{
	return teacher_version;
}

void Method::tc(EnvironmentP env)
{
	return teacher_version;
}

void Formal_class::tc(EnvironmentP env)
{
	return teacher_version;
}


Symbol NoExp::tc(EnvironmentP env)
{
	return teacher_version;
}

