#include <iostream>
#include <sstream>
#include <exception>

using namespace std;

template <class SYM, class DAT>
void SymbolTable<SYM, DAT>::raiseException(string msg)
{
	throw runtime_error(msg);
}

// Enter a new scope.  A symbol table is organized as a list of
// lists.  The head of the list is the innermost scope, the tail
// holds the outer scopes.  A scope must be entered before anything
// can be added to the table.

template <class SYM, class DAT>
void SymbolTable<SYM, DAT>::enterScope()
{
	Scope newscope;
	tbl.push_front( newscope );
}

// Pop the first scope off of the symbol table.
template <class SYM, class DAT>
void SymbolTable<SYM, DAT>::exitScope()
{
	// It is an error to exit a scope that doesn't exist.
	if (tbl.size() == 0)
		raiseException("No scope exist!");
	dump();
	tbl.pop_front();
}

// Add an item to the symbol table.
template<class SYM, class DAT>
void SymbolTable<SYM, DAT>::addid(SYM s, DAT *i)
{
	// There must be at least one scope to add a symbol.
	if (tbl.size() == 0) 
		raiseException("addid: Can't add a symbol without a scope.");
	
	tbl.front().insert({ s, i });
	return;
}

// Lookup an item through all scopes of the symbol table.  If found
// it returns the associated information field, if not it returns
// NULL.
template<class SYM, class DAT>
DAT * SymbolTable<SYM, DAT>::lookup(SYM s)
{
	for (typename list<Scope>::iterator it = tbl.begin(); it != tbl.end(); it++)
	{
		if (it->find(s) != it->end())
			return (*it)[s];	//found the lexeme
	}
	return nullptr;
}

// probe the symbol table.  Check the top scope (only) for the item
// 's'.  If found, return the information field.  If not return NULL.
template<class SYM, class DAT>
DAT * SymbolTable<SYM, DAT>::probe(SYM s)
{
	if (tbl.size() == 0) {
		raiseException("probe: No scope in symbol table.");
	}
	if (tbl.front().find(s) != tbl.front().end())
		return tbl.front()[s];	//found the lexeme
	return nullptr;
}

template<class SYM, class DAT>
void SymbolTable<SYM, DAT>::dump()
{
	int			level = tbl.size();
	string		indent;
	Scope		current = *(tbl.begin());
	typename Scope::iterator	it = current.begin();

	for (int i = 0; i<level; i++)
		indent += "    ";
	string			info;
	stringstream	ss(info);

	for (; it != current.end(); ++it)
		ss << indent << it->first << endl;
	ss << indent << "-------------------------------" << endl;
	dumpinfo += ss.str();
}

template<class SYM, class DAT>
SymbolTable<SYM, DAT>::~SymbolTable()
{
	//delete all remaining scopes 
	for (unsigned int i = 0; i<tbl.size(); i++)
		exitScope();

	//cout << "*******************Symbol Table************************" << endl;
	//cout << dumpinfo << endl;
	//cout << "*******************Symbol Table************************" << endl;
}

