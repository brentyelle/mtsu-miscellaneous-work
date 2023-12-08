#include <algorithm>
#include "slp.h"


using namespace std;

void CompoundStm::interp( SymbolTable& symbols )
{
    stm1->interp(symbols);
    stm2->interp(symbols);
    return;
}


void AssignStm::interp( SymbolTable& symbols )
{
    symbols[id] = exp->interp(symbols);
    return;
}


void PrintStm::interp( SymbolTable& symbols )
{
    /* It feels incorrect that I'm calling the prints to cout in the ExpList's ->interp method,
       but there's no other way to access the contents of the ExpList... */
    exps->interp(symbols);
    cout << endl;
    return;
}


int IdExp::interp( SymbolTable& symbols )
{
    return symbols.at(id);
}


int NumExp::interp( SymbolTable& symbols )
{
    return num;
}


int OpExp::interp( SymbolTable& symbols )
{
    int lhs = left->interp(symbols);
    int rhs = right->interp(symbols);

    switch (oper) {
        case PLUS:
            return lhs + rhs;
        case MINUS:
            return lhs - rhs;
        case TIMES:
            return lhs * rhs;
        case DIV:
            return lhs / rhs;
        default:
            cerr << "INVALID OPERATION FOUND: \"" << oper << "\"" << endl;
            return 0;
    }
}



int EseqExp::interp( SymbolTable& symbols )
{
    stm->interp(symbols);
    return exp->interp(symbols);
}


void PairExpList::interp( SymbolTable& symbols)
{
    /*implementation here*/
    std::cout << head->interp(symbols) << " ";
    tail->interp(symbols);
    return;
}


void LastExpList::interp( SymbolTable& symbols)
{
    /*implementation here*/
    std::cout << head->interp(symbols) << " ";
    return;
}

