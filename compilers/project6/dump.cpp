#include <string>
#include <iostream>
#include "Absyn.h"

using namespace std;

namespace absyn {
	string pad(int n)
	{
		return string(n, ' ');
	}

	void dump_string(ostream& stream, int n, string content, bool newline=true)
	{
		if (content.empty())
			return;
		stream << pad(n) << content;
		if (newline)
			stream << endl;
	}

	void dump_symbol(ostream& stream, int n, Symbol content, bool newline = true)
	{
		if (content == nullptr)
			return;
		stream << pad(n) << content->getContent();
		if (newline)
			stream << endl;
	}

	void dump_int(ostream& stream, int n, int content, bool newline=true)
	{
		stream << pad(n) << content;
		if (newline)
			stream << endl;
	}

	template<typename Item>
	void dump_list(ostream& stream, int n, List<Item> *content)
	{
		const List<Item>*	cur = content;
		while (cur != nullptr) {
			cur->getHead()->dump(stream, n + 2);
			cur = cur->getRest();
		}
	}

	void Program_class::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "Program");
		dump_list(stream, n+2, classes);
	}

	void Class_class::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "Class: [" + classname->getContent() + (parent ==nullptr?"" : ": " + parent->getContent()) + "]");
//		dump_string(stream, n + 2, name);
//		dump_string(stream, n + 2, parent);
		dump_list(stream, n + 2, features);
	}

	void Method::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "Method: [" + name->getContent() + "]");
//		dump_string(stream, n + 2, name);
		dump_list(stream, n + 2, formals);
		dump_symbol(stream, n + 2, return_type);
		expr->dump(stream, n + 2);
	}

	void Attr::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "Attr: [" + name->getContent() + "]");
//		dump_string(stream, n + 2, name);
		dump_symbol(stream, n + 2, type_decl);
		if ( init != nullptr )
			init->dump(stream, n + 2);
	}

	void Formal_class::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "Formal");
		dump_symbol(stream, n + 2, name);
		dump_symbol(stream, n + 2, type_decl);
	}

	void Branch_class::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "Branch");
		dump_symbol(stream, n + 2, name);
		dump_symbol(stream, n + 2, type_decl);
		expr->dump(stream, n + 2);
	}

	void AssignExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "AssignExp");
		dump_symbol(stream, n + 2, name);
		expr->dump(stream, n + 2);
	}

	void StaticCallExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "StaticCallExp");
		lvalue->dump(stream, n + 2);
		dump_symbol(stream, n + 2, type_name);
		dump_symbol(stream, n + 2, method_name);
		dump_list(stream, n + 2, actual);
	}

	void CallExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "CallExp");
		if ( lvalue != nullptr )
			lvalue->dump(stream, n + 2);
		dump_symbol(stream, n + 2, method_name);
		dump_list(stream, n + 2, actual);
	}

	void IfExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "IfExp");
		pred->dump(stream, n + 2);
		then_exp->dump(stream, n + 2);
		else_exp->dump(stream, n + 2);
	}

	void WhileExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "WhileExp");
		pred->dump(stream, n + 2);
		body->dump(stream, n + 2);
	}

	void CaseExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "CaseExp");
		expr->dump(stream, n + 2);
		dump_list(stream, n + 2, cases);
	}

	void BlockExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "BlockExp");
		dump_list(stream, n + 2, body);
	}

	void LetExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "LetExp");
		dump_symbol(stream, n + 2, identifier);
		dump_symbol(stream, n + 2, type_decl);
		if ( init != nullptr )
			init->dump(stream, n + 2);
		body->dump(stream, n + 2);
	}

	void OpExp::dump(ostream& stream, int n)
	{
		string	symbol;
		switch (op) {
		case PLUS:	symbol = "+"; break;
		case MINUS:	symbol = "-"; break;
		case MUL:	symbol = "*"; break;
		case DIV:	symbol = "/"; break;
		case LT:	symbol = "<"; break;
		case LE:	symbol = "<="; break;
		case EQ:	symbol = "="; break;
		}

		dump_string(stream, n, "OpExp");
		left->dump(stream, n + 2);
		dump_string(stream, n + 2, symbol);
		right->dump(stream, n + 2);
	}


	void NotExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "NotExp");
		expr->dump(stream, n + 2);
	}

	void IntExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "int_const");
		dump_symbol(stream, n + 2, value);
	}

	void BoolExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "bool_const");
		dump_string(stream, n + 2, value?"true":"false");
	}

	void StringExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "string_const");
		dump_symbol(stream, n + 2, content);
	}

	void NewExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "NewExp");
		dump_symbol(stream, n + 2, type_name);
	}

	void IsvoidExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "IsvoidExp");
		expr->dump(stream, n + 2);
	}

	void ObjectExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "ObjectExp");
		dump_symbol(stream, n + 2, name);
	}

	void NoExp::dump(ostream& stream, int n)
	{
		dump_string(stream, n, "no_expr");
	}


} // end of namespace Absyn