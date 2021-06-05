#include "y.tab.h"
#define YY_NO_UNPUT

using namespace std;

#include <iostream>
#include <stdio.h>
#include <string>
#include <stdlib.h>
#include <fstream>
#include <algorithm>

//int yyparse();

extern bool isError;
extern string code;
extern FILE * yyin;

int yywrap() {
    return 1;
}

int main(int argc, char* argv[]) {
  if (argc >= 2) {
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

    if (isError) {
        cout << "Error! Couldn't properly generate code." << endl;
    }
    else {
        ofstream file;
        file.open("mil_code.mil");
        file << code;
        file.close();
    }

    return 0;
}
