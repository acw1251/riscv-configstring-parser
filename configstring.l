%{
#include <iostream>
#include <map>
#include "configstring.h"
#include "configstring.tab.h"
#define YY_DECL extern "C" int yylex()
unsigned int linenum = 0;
%}
%%
[ \t]           ;
\n              { linenum++; }
[\{\}\;]        { return yytext[0]; }
[a-zA-Z0-9@:-]+ { yylval.sval = yytext; return TOKEN; }
.               { std::cerr << "Illegal token on line " << linenum << " : " << yytext << std::endl; }
%%

