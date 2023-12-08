#ifndef _SYMTAB_H_
#define _SYMTAB_H_

#include <string>
#include <unordered_map>
#include <list>
#include <string>

using namespace std;

// SymtabEnty<SYM,DAT> defines the entry for a symbol table that associates
//    symbols of type `SYM' with data of type `DAT *'.  
//

/*
template <class SYM, class DAT>
class SymtabEntry {
private:
	SYM id;        // the key field
	DAT *info;     // associated information for the symbol
public:
	SymtabEntry(SYM x, DAT *y) : id(x), info(y) { }
	SYM getId() const { return id; }
	DAT *getInfo() const { return info; }
};
*/

//
// SymbolTable<SYM,DAT> describes a symbol table mapping symbols of
//    type `SYM' to data of type `DAT *'.  It is implemented as a
//    list of lists of `SymtabEntry<SYM,DAT> *'.  The inner list is
//    a scope, a mapping from symbols to data, and the outer list is
//    a list of scopes. 
//
//    `tbl' points to the current top scope.
//
//    `enterscope' makes the table point to a new scope whose parent
//       is the scope it pointed to previously.
//
//    `exitscope' makes the table point to the parent scope of the
//        current scope.  Note that the old child scope is not
//        deallocated.  One may save the state of a symbol table
//        at a given point by copying it with `operator ='
//
//    `addid(s,i)' adds a symbol table entry to the current scope of
//        the symbol table mapping symbol `s' to data `d'.  The old
//        top scope isn't modified; a new scope is created whose
//        entry list is the new entry followed by the old entry list,
//        and whose tail is the old top scope's parent.  The table
//        is made to point to this new scope.
//
//    `lookup(s)' looks for the symbol `s', starting at the top scope
//        and proceeding down the list of scopes until either an
//        entry is found whose `get_id()' equals `s', or the end of
//        the root scope is reached.  It returns the data item
//        associated with the entry, or NULL if no such entry exists.
//
//    
//    `probe(s)' checks the top scope for an entry whose `get_id()'
//        equals `s', and returns the entry's `get_info()' if
//        found, and NULL otherwise.
//
//    `dump()' prints the symbols in the symbol table.
//

template <class SYM, class DAT>
class SymbolTable
{
	typedef unordered_map<SYM, DAT*>	Scope;
	typedef list<Scope> ScopeList;

private:
	ScopeList	tbl;
	string		dumpinfo;

public:
	SymbolTable() : tbl() { }     // create a new symbol table
	~SymbolTable();

	// Create pointer to current symbol table.
	SymbolTable &operator =(const SymbolTable &s) { tbl = s.tbl; return *this; }


	// Enter a new scope.  A symbol table is organized as a list of
	// lists.  The head of the list is the innermost scope, the tail
	// holds the outer scopes.  A scope must be entered before anything
	// can be added to the table.

	void enterScope();

	// Pop the first scope off of the symbol table.
	void exitScope();

	// Add an item to the symbol table.
	void addid(SYM s, DAT *i);

	// Lookup an item through all scopes of the symbol table.  If found
	// it returns the associated information field, if not it returns
	// NULL.

	DAT * lookup(SYM s);

	// probe the symbol table.  Check the top scope (only) for the item
	// 's'.  If found, return the information field.  If not return NULL.
	DAT *probe(SYM s);

protected:
	// Prints out the contents of the symbol table  
	void dump();
	void raiseException(string msg);
};

#include "SymbolTable.cpp"

#endif