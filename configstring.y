%{
#include <cstdio>
#include <iostream>
#include <map>
#include <algorithm>

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern unsigned int linenum;

void yyerror(const char *s);
%}

%union {
    char* sval;
    std::string* sptr;
    std::map<std::string, std::string>* smap;
}

%token <sval> TOKEN
%type <sptr> key entry
%type <smap> configline configlines
%%

configstring:
    configlines {
        std::cout << "Done parsing." << std::endl;
        for (auto it = $1->begin() ; it != $1->end() ; it++ ) {
            std::cout << it->first << " = " << it->second << std::endl;
        }
    }
    ;

configlines:
    configlines configline {
        for (auto it = $2->begin() ; it != $2->end() ; it++ ) {
            (*$1)[ it->first ] = it->second;
        }
        $$ = $1;
        delete $2;
    }
    | configline {
        $$ = $1;
    }
    ;

configline:
    key '{' configlines '}' ';' {
        std::map<std::string, std::string> *x = new std::map<std::string, std::string>();
        for (auto it = $3->begin() ; it != $3->end() ; it++ ) {
            (*x)[ *$1 + "." + it->first ] = it->second;
        }
        $$ = x;
        delete $1;
        delete $3;
    }
    | key entry ';' {
        std::map<std::string, std::string> *x = new std::map<std::string, std::string>();
        (*x)[*($1)] = *($2);
        $$ = x;
        delete $1;
        delete $2;
    }
    ;

key:
    TOKEN {
        $$ = new std::string($1);
    }
    ;

entry:
    entry TOKEN {
        $$ = new std::string((*$1) + " " + std::string($2));
        delete $1;
    }
    | TOKEN {
        $$ = new std::string($1);
    }
    ;
%%

int main(int argc, char* argv[]) {
    // open a file handle to a particular file:
    const char* filename = "platform.rvcs";
    if (argc > 1) {
        filename = argv[1];
    }
    FILE *myfile = fopen(filename, "r");
    // make sure it is valid:
    if (!myfile) {
        std::cout << "Error opening " << filename << std::endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    
    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
}

void yyerror(const char *s) {
    std::cout << "[ERROR] line " << linenum << ": " << s << std::endl;
    exit(-1);
}
