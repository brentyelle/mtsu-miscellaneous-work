#include <iostream>
#include <fstream>
#include <string>
#include <FlexLexer.h>
#include "ErrorMsg.h"
#include "Absyn.h"


using namespace std;

extern int yyparse(void);
extern ErrorMsg	errormsg;
extern absyn::Program	root;

yyFlexLexer		lexer;
string			curr_filename;
int				semant_debug = 0;

void parse(string fname) 
{
	ifstream	ifs(fname);
	errormsg.reset(fname);
	lexer.switch_streams(&ifs, NULL);

	if ( yyparse() == 0 ) /* parsing worked */
		cout << "Parsing successful!\n" << endl;
	else
		cout << "Parsing failed\n" << endl;
}

extern int yydebug;

int main(int argc, char **argv) 
{
	yydebug = 0;
	if (argc!=2) 
	{
		cerr <<"usage: " << argv[0] << " filename" << endl; 
		return 1;
	}
	curr_filename = string(argv[1]);

	parse( argv[1] );


	root->semant();

	return 0;
}

