%{
#include <cstdio>
#include <iostream>
#include <map>
#include <list>
#include <algorithm>
#include <utility>
#include "configstring.h"

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
    configstring_node_t* cfn;
}

%token <sval> TOKEN
%type <sptr> key entry
%type <cfn> configline configlines
%%

configstring:
    configlines {
        std::cout << "Done parsing." << std::endl;
        int depth = 0;
        if ($1->data.length() != 0) {
            std::cout << $1->data << std::endl;
        }
        //std::pair<auto, auto> p = pair($1->children.begin(), $1->children.end());
        auto p = std::make_pair($1->children.begin(), $1->children.end());
        auto l = make_list_with_init(p);
        auto it = $1->children.begin();
        while (l.size() != 0) {
            // continue processing noe at top of stack
            p = l.back();
            l.pop_back();
            for (it = p.first ; it != p.second ; it ++ ) {
                // print data
                if (depth < 0) {
                    std::cout << "error: depth < 0" << std::endl;
                }
                for (int i = 0 ; i < depth ; i++) {
                    std::cout << "    ";
                }
                std::cout << it->first << " : " << it->second.data << std::endl;
                if (it->second.children.size() != 0) {
                    break;
                }
            }
            if (it != p.second) {
                // save current state
                p = std::make_pair(std::next(it), p.second);
                l.push_back(p);
                // iterate into children
                depth++;
                p = std::make_pair(it->second.children.begin(), it->second.children.end());
                l.push_back(p);
            } else {
                depth--;
            }
        }
    }
    ;

configlines:
    configlines configline {
        // merge the children
        for (auto it = $2->children.begin() ; it != $2->children.end() ; it++ ) {
            $1->children[ it->first ] = it->second;
        }
        delete $2;
        $$ = $1;
    }
    | configline {
        $$ = $1;
    }
    ;

configline:
    key '{' configlines '}' ';' {
        configstring_node_t *x = new configstring_node_t();
        x->children[*$1] = *$3;
        delete $1;
        delete $3;
        $$ = x;
    }
    | key entry ';' {
        configstring_node_t *x = new configstring_node_t();
        x->children[*$1] = configstring_node_t(*$2);
        delete $1;
        delete $2;
        $$ = x;
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
