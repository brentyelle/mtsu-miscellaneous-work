#ifndef _ABSYN_H_
#define _ABSYN_H_

#include <string>
#include <memory>
#include "AbsynExtension.h"

using namespace std;

namespace absyn
{

	/*This namespace defines all kinds of nodes in the abstract syntax tree*/
	template<class Item>
	class List {
	private:
		Item		head;
		List<Item>	*rest;
	public:
		List(Item h, List<Item> *r)
			: head(h), rest(r)
		{}

		Item getHead(void) const { return head; }
		List<Item>* getRest(void) const { return rest; }
		unsigned int size() {
			return rest == nullptr ? 1 : 1 + rest->size();
		}
		
	};

	//Ancestor of all nodes
	class TreeNode;
	class Program_class;
	class Class_class;
	class Feature_class;
	class Method;
	class Attr;

	class Formal_class;
	class Expression_class;
	class Branch_Class;
	class AssignExp;
	class StaticCallExp;
	class CallExp;
	class IfExp;
	class WhileExp;
	class CaseExp;
	class BlockExp;
	class LetExp;
	class OpExp;
	class NotExp;

	class IntExp;
	class BoolExp;
	class StringExp;

	class NewExp;
	class IsvoidExp;
	class ObjectExp;

	typedef class Program_class *Program;
	typedef class Class_class *Class_;
	typedef class Feature_class *Feature;
	typedef class Formal_class *Formal;
	typedef class Expression_class *Expression;
	typedef class Branch_class *Branch;

	typedef List<Class_>*		Classes;
	typedef List<Feature>*		Features;
	typedef List<Formal>*		Formals;
	typedef List<Branch>*		Branches;
	typedef List<Expression>*	Expressions;

	/*****************************************************************/
	/*****************************************************************/
	/*                       Definition                              */
	/*****************************************************************/
	/*****************************************************************/
	//abstract base class, the ancestor of all type of tree nodes
	class TreeNode {
	private:
		int		lineno;
		int		colno;
	public:
		//ructor
		TreeNode(int line, int col) : lineno(line), colno(col) {}

		int getLineno( void ) const { return lineno; }
		int getColno( void )  const { return colno; }

//		virtual TreeNode *copy() = 0;
		virtual ~TreeNode() { }
		virtual void dump(ostream& stream, int n) = 0;
	};

	// define the class for constructors
	// define constructor - program
	class Program_class : public TreeNode {
	protected:
		List<Class_>* classes;
	public:
		Program_class(int line, int col, List<Class_> *all) 
			: TreeNode(line, col), classes(all) 
		{}
		virtual ~Program_class() {}

		void dump(ostream& stream, int n);

#ifdef Program_EXTRAS
		Program_EXTRAS
#endif
	};

	class Class_class : public TreeNode {
	protected:
		Symbol		filename;
		Symbol		classname;
		Symbol		parent;
		Features	features;
	public:
		Class_class(int line, int col, Symbol a1, Symbol a2, Symbol a3, Features a4)
			: TreeNode(line, col), filename(a1), classname(a2), parent(a3), features(a4)
		{ }
		virtual ~Class_class() {}

		Symbol getFilename() const { return filename; }
		Symbol getClassname() const { return classname; }
		Symbol getParent() const { return parent; }
		Features getFeatures() const { return features; }

		void dump(ostream& stream, int n);
	};

	class Feature_class : public TreeNode {
	public:
		Feature_class(int line, int col) : TreeNode(line, col)
		{}

		virtual ~Feature_class() {}
#ifdef Feature_EXTRAS
		Feature_EXTRAS
#endif
	};

	class Expression_class : public TreeNode {
	public:
		Expression_class(int line, int col) : TreeNode(line, col)
		{}

		virtual ~Expression_class() {}
#ifdef Expression_EXTRAS
		Expression_EXTRAS
#endif
	};


	class Method : public Feature_class {
	protected:
		Symbol			name;
		Formals			formals;
		Symbol			return_type;
		Expression		expr;
	public:
		Method(int line, int col, Symbol a1, Formals a2, Symbol a3, Expression a4)
		: Feature_class(line, col), name(a1), formals(a2), return_type(a3), expr(a4) 
		{ }

		Symbol getName() const { return name; }
		Formals getFormals() const { return formals; }
		Symbol getReturnType() const { return return_type; }
		const Expression getExpr() const { return expr; }
		int num_formals() { return formals == nullptr ? 0 : formals->size(); }

		void dump(ostream& stream, int n);
#ifdef Feature_SHARED_EXTRAS
		Feature_SHARED_EXTRAS
#endif
#ifdef method_EXTRAS
			method_EXTRAS
#endif
	};

	// define constructor - attr
	class Attr : public Feature_class {
	protected:
		Symbol name;
		Symbol type_decl;
		Expression init;
	public:
		Attr(int line, int col, Symbol a1, Symbol a2, Expression a3 = nullptr)
		: Feature_class(line, col), name(a1), type_decl(a2), init(a3) 
		{ }

		Symbol getName() const { return name; }
		Symbol getType() const { return type_decl; }
		const Expression getInit() { return init; }

		void dump(ostream& stream, int n);
#ifdef Feature_SHARED_EXTRAS
		Feature_SHARED_EXTRAS
#endif
#ifdef attr_EXTRAS
			attr_EXTRAS
#endif
	};

	// define constructor - formal
	class Formal_class : public TreeNode {
	protected:
		Symbol name;
		Symbol type_decl;
	public:
		Formal_class(int line, int col, Symbol a1, Symbol a2)
		: TreeNode(line, col), name(a1), type_decl(a2)
		{ }
		virtual ~Formal_class() {}

		Symbol getName() const { return name; }
		Symbol getType() const { return type_decl; }
		void dump(ostream& stream, int n);
#ifdef Formal_EXTRAS
		Formal_EXTRAS
#endif
	};

	// define constructor - branch
	class Branch_class : public TreeNode {
	protected:
		Symbol name;
		Symbol type_decl;
		Expression expr;
	public:
		Branch_class(int line, int col, Symbol a1, Symbol a2, Expression a3 = nullptr)
			: TreeNode (line, col), name(a1), type_decl(a2), expr(a3)
		{ }

		Symbol getName() const { return name; }
		Symbol getType() const { return type_decl; }
		const Expression getExpr() { return expr; }

		void dump(ostream& stream, int n);
#ifdef Branch_EXTRAS
		Branch_EXTRAS
#endif
	};

	// define constructor - assign
	class AssignExp : public Expression_class {
	protected:
		Symbol name;
		Expression expr;
	public:
		AssignExp(int line, int col, Symbol a1, Expression a2)
		: Expression_class(line, col), name(a1), expr(a2)
		{ }

		Symbol getName() const { return name; }
		const Expression getExpr() { return expr; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - static_dispatch
	class StaticCallExp : public Expression_class {
	protected:
		Expression		lvalue;
		Symbol			type_name;
		Symbol			method_name;
		Expressions		actual;
	public:
		StaticCallExp(int line, int col, Expression a1, Symbol a2, Symbol a3, Expressions a4)
		: Expression_class(line, col), lvalue(a1), type_name(a2), method_name(a3), actual(a4)
		{ }

		const Expression getObject() const { return lvalue; }
		const Symbol getTypeName() const { return type_name; }
		const Symbol getMethodName() const { return method_name; }
		Expressions getActual() { return actual; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - dispatch
	class CallExp : public Expression_class {
	protected:
		Expression		lvalue;
		Symbol			method_name;
		Expressions		actual;
	public:
		CallExp(int line, int col, Expression a1, Symbol a2, Expressions a3)
			: Expression_class(line, col), lvalue(a1), method_name(a2), actual(a3)
		{ }

		const Expression getObject() const { return lvalue; }
		const Symbol getMethodName() const { return method_name; }
		Expressions getActual() { return actual; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - cond
	class IfExp : public Expression_class {
	protected:
		Expression pred;
		Expression then_exp;
		Expression else_exp;
	public:
		IfExp(int line, int col, Expression a1, Expression a2, Expression a3)
		: Expression_class(line, col), pred(a1), then_exp(a2), else_exp(a3) 
		{ }

		const Expression getPred() const { return pred; }
		const Expression getThenClause() const { return then_exp; }
		const Expression getElseClause() const { return else_exp; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - loop
	class WhileExp : public Expression_class {
	protected:
		Expression pred;
		Expression body;
	public:
		WhileExp(int line, int col, Expression a1, Expression a2)
			: Expression_class(line, col), pred(a1), body(a2)
		{ }
		const Expression getPred() const { return pred; }
		const Expression getBody() const { return body; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - typcase
	class CaseExp : public Expression_class {
	protected:
		Expression	expr;
		Branches	cases;
	public:
		CaseExp(int line, int col, Expression a1, Branches a2)
		: Expression_class(line, col), expr(a1), cases(a2)
		{ }

		const Expression getExpr() const { return expr; }
		Branches getCases() const { return cases; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - block
	class BlockExp : public Expression_class {
	protected:
		List<Expression>* body;
	public:
		BlockExp(int line, int col, List<Expression>* a1)
		: Expression_class(line, col), body(a1)
		{ }
		
		const List<Expression>* getBody() const { return body; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};


	// define constructor - let
	class LetExp : public Expression_class {
	protected:
		Symbol		identifier;
		Symbol		type_decl;
		Expression	init;
		Expression	body;
	public:
		LetExp(int line, int col, Symbol a1, Symbol a2, Expression a3, Expression a4)
		: Expression_class(line, col), identifier(a1), type_decl(a2), init(a3), body(a4)
		{ }

		Symbol getVarName() const { return identifier; }
		Symbol getVarType() const { return type_decl; }
		const Expression getInit() const { return init; }
			
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - plus
	class OpExp : public Expression_class {
	public:
		enum Op {PLUS, MINUS, MUL, DIV, LT, EQ, LE };
	protected:
		Expression	left;
		Expression	right;
		Op			op;
	public:
		OpExp(int line, int col, Expression a1, Op a2, Expression a3) 
		: Expression_class(line, col), left(a1), op(a2), right(a3)
		{ }

		const Expression getLeft() const { return left; }
		const Expression getRight() const { return right; }
		Op getOperator() const { return op; }

		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - not
	class NotExp : public Expression_class {
	protected:
		Expression expr;
	public:
		NotExp(int line, int col, Expression a1)
		: Expression_class(line, col), expr(a1) 
		{ }
		
		const Expression getExpr() const { return expr; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - int_const
	class IntExp : public Expression_class {
	protected:
		Symbol		value;
	public:
		IntExp(int line, int col, Symbol a1)
		: Expression_class(line, col), value(a1)
		{ }
		
		Symbol getValue() const{ return value; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - bool_const
	class BoolExp : public Expression_class {
	protected:
		bool	value;
	public:
		BoolExp(int line, int col, bool a1)
		: Expression_class(line, col), value(a1)
		{ }
		
		bool getValue() const { return value; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};


	// define constructor - string_const
	class StringExp : public Expression_class {
	protected:
		Symbol	content;
	public:
		StringExp(int line, int col, Symbol a1)
		: Expression_class(line, col), content(a1)
		{ }
		
		Symbol getValue() const { return content; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - new_
	class NewExp : public Expression_class {
	protected:
		Symbol		type_name;
	public:
		NewExp(int line, int col, Symbol a1)
		: Expression_class(line, col), type_name(a1)
		{ }
		
		Symbol getType() const { return type_name; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};


	// define constructor - isvoid
	class IsvoidExp : public Expression_class {
	protected:
		Expression expr;
	public:
		IsvoidExp(int line, int col, Expression a1)
		: Expression_class(line, col), expr(a1)
		{ }
		
		const Expression getExpr() const { return expr; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	// define constructor - object
	class ObjectExp : public Expression_class {
	protected:
		Symbol	name;
	public:
		ObjectExp(int line, int col, Symbol a1)
		: Expression_class(line, col), name(a1) 
		{ }
		
		Symbol getName() const { return name; }
		void dump(ostream& stream, int n);
#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
	};

	class NoExp : public Expression_class {
	protected:
	public:
		NoExp() : Expression_class(0,0) {
		}
		void dump(ostream& stream, int n);

#ifdef Expression_SHARED_EXTRAS
		Expression_SHARED_EXTRAS
#endif
#ifdef no_expr_EXTRAS
			no_expr_EXTRAS
#endif
	};







}	//end of namespace Absyn


#endif