#include "y.tab.h"
#define YY_NO_UNPUT

using namespace std;

#include <iostream>
#include <stdio.h>
#include <string>
#include <stdlib.h>
#include <fstream>

int yyparse();

extern FILE * yyin;

string fileName;

int yywrap() {
    return 1;
}

int main(int argc, char* argv[]) {
  if (argc >= 2) {
    fileName = argv[1];
  	fileName = fileName.substr(0, fileName.size() - 4);
  	fileName = fileName + ".mil";
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
      printf("Error opening file: %s\n", argv[1]);
      exit(1);
    }
  }
  else {
    yyin = stdin;
  }

    yyparse();

    return 0;
}