/*
 Bison file
*/

/* Include Variables */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <string>
    #include <sstream>
    #include <fstream>
    #include <iostream>
    #include <vector>
    #include <cstdlib>
    using namespace std;

    int yylex();
    void yyerror(const char *msg);
    extern int currPos, currLine;

    bool isError = true;

    // adding to symbol table
    vector<string> functionTable;
    void addFunction(string s) {
        functionTable.push_back(s);
    }

    int numTemp = 0;
    int numLabel = 0;
    vector<string> tempTable; // holder table for temp string
    vector<string> labelTable; // holder table for labels
    vector<string> idTable; // holder table for identifiers
    vector<string> exprTable; // holder table for expressions
    vector<string> varTable; // holder table for variables
    vector<string> idFuncTable; // holder table for function identifiers
    string new_temp() {
        string tmp = "temp" + to_string(numTemp);
        tempTable.push_back(tmp);
        numTemp++;
        return tmp;
    }
    string new_label() {
        string lbl = "label" + to_string(numLabel);
        labelTable.push_back(lbl);
        numLabel++;
        return lbl;
    }

    // tags to see what actions need to be performed
    bool isFunc = true; // checks if function end is reached
    bool eqTag = false;
    bool neqTag = false;
    bool ltTag = false;
    bool gtTag = false;
    bool lteTag = false;
    bool gteTag = false;
    bool multTag = false;
    bool divTag = false;
    bool modTag = false;
    bool addTag = false;
    bool subTag = false;
    bool trueTag = false;
    bool falseTag = false;
    bool root = true;
    bool assignTag = false;
    bool readTag = false;
    bool writeTag = false;
    bool isSub = false; // check if doing sub in terms
    int regNum = 0;
    int idNum = 0;
    string code; // string for code representation in program

%}

%union {
    int intVal;
    char* identVal;
}

%error-verbose

%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <intVal> NUMBER
%token <identVal> IDENTIFIER
%token <intVal> INTEGER
%right ASSIGN
%left SUB ADD
%left AND OR
%left MULT DIV MOD
%left EQ NEQ LT GT LTE GTE
%right NOT

%%

/* using stack-based algorithm from class
 * Code Representation: https://www.cs.ucr.edu/~mafar001/compiler/webpages3/mil.html
 */

 /* Still need to do:
  * var
  * term
  * expression
  * check to make sure proper code representation is achieved i.e "ret" vs "RETURN"
  * testing
  */

program:        functions
                {
                    if (find(functionTable.begin(), functionTable.end(), "main") == functionTable.end()) {
                        cout << "Error line " << currLine << " : no main function declared." << endl;
                        isError = true;
                    }

                    if (isError) {
                        return -1;
                    }
                }
       ;

functions:      /* epsilon*/
                {}
         |      function functions
                {}
         ;

function:       FUNCTION IDENTIFIER SEMICOLON
                BEGIN_PARAMS declarations END_PARAMS
                BEGIN_LOCALS declarations END_LOCALS
                BEGIN_BODY statements END_BODY
                {
                    if(!isFunc) {
                        code += "endfunc\n\n";
                    }
                    isFunc = true;
                }
        ;

declarations:
                {}
            |   declaration SEMICOLON declarations
                {}
            ;

declaration:    identifiers COLON ENUM L_PAREN
                identifiers R_PAREN
                {
                    code += idTable.back(); //id
                    code += ", ";
                    code += idTable.back(); //id
                    code += "\n";
                }
           |    identifiers COLON ARRAY
                L_SQUARE_BRACKET NUMBER
                R_SQUARE_BRACKET OF INTEGER
                {
                    code += ".[] ";
                    code += idTable.back(); //id
                    code += ", ";
                    code += idTable.back(); //number
                    code += "\n";
                }
           |    identifiers COLON INTEGER
                {
                    code += ". ";
                    string str(idTable.back());
                    string t = "";
                    for (int i = 0; i < str.size(); i++) { // getting first identifier
                        if (str.at(i) == '(' || str.at(i) == ')' || str.at(i) == ' ' || str.at(i) == ';') {
                            i = 100; // breaks for loop
                        }
                        else {
                            code += str.at(i);
                            t += str.at(i);
                        }
                    }
                    if (root) {
                        code += "\n= " + t;
                        code += ", $" + to_string(regNum);
                        regNum++;
                        root = false;
                    }
                    code += "\n";
                    idTable.push_back(t);
                    idNum++;
                }
           ;

identifiers:    IDENTIFIER
                {
                    string t;
                    if (isFunc) {
                        functionTable.push_back($1);
                        isFunc = false;
                        code += "FUNCTION";
                        string str($1);
                        for (int i = 0; i< str.size(); i++) {
                            if (str.at(i) == '(' || str.at(i) == ')' || str.at(i) == ' ' || str.at(i) == ';') {
                                i = 100; // breaks for loop
                            }
                            else {
                                code += str.at(i);
                                t += str.at(i);
                            }
                        }
                    }
                    else if (assignTag) {
                        assignTag = false;
                        idNum--;
                    }
                    else {
                        string temp = new_temp();
                        code += ". " + temp;
                        code += "\n= ";
                        code += temp + ", ";
                        string str($1);
                        for (int i = 0; i< str.size(); i++) {
                            if (str.at(i) == '(' || str.at(i) == ')' || str.at(i) == ' ' || str.at(i) == ';') {
                                i = 100; // breaks for loop
                            }
                            else {
                                code += str.at(i);
                                t += str.at(i);
                            }
                        }
                    }
                    code += "\n"; idTable.push_back(t); idNum++;
                }
           |    IDENTIFIER COMMA identifiers
                {}
           ;

statements:     statement SEMICOLON
                {}
          |     statement SEMICOLON statements
                {}
          ;

statement:
                {}
        |	    var ASSIGN expressions
                {
                    assignTag = true;
                    code += "= " + string(idTable.at(idNum-2)) + ", temp" + to_string(numTemp-1);
                }
        |       IF bool_expr THEN statements ENDIF
                {
                    code += ": label"+ to_string(numLabel-1) + "\n";
                }
        |       IF bool_expr THEN statements ELSE
                statements ENDIF
                {}
        |       WHILE bool_expr BEGINLOOP statements
                ENDLOOP
                {}
        |       DO BEGINLOOP statements ENDLOOP
                WHILE bool_expr
                {}
        |       READ vars
                {
                    readTag = true;
                    if (readTag) {
                        readTag = false;
                        code += ".< " + string(idTable.at(idNum-1)) + "\n";
                    }
                }
        |       WRITE vars
                {
                    writeTag = true;
                    if (writeTag) {
                        writeTag = false;
                        code += ".> " + string(idTable.at(idNum-2)) + "\n";
                    }
                }
        |       CONTINUE
                {
                    code += "CONTINUE\n";
                }
        |       RETURN expressions
                {
                    code += "RETURN ";
                    code += "temp" + to_string(numTemp-1) + "\n";
                }
        ;

vars:
                {}
    |           var
                {}
    |           var COMMA vars
                {}
    ;

var:            IDENTIFIER
                {
                    varTable.push_back(idTable.back());
                    idTable.pop_back();
                }
   |            IDENTIFIER L_SQUARE_BRACKET expression
                R_SQUARE_BRACKET
                {
                    code += ". ";
                    code += idTable.back(); // id
                    code += "=[] ";
                    code += idTable.back(); // id
                    code += ", ";
                    code += idTable.back(); // id
                    code += "\n";
                }

   ;

bool_expr:      relation_and_expr
                {
                    code += "|| ";
                    code += idTable.back(); //id
                    code += ", ";
                    code += idTable.back(); //id
                    code += ", ";
                    code += idTable.back(); //id
                    code += "\n";
                }
        |       relation_and_expr OR relation_and_expr
                {}
        ;

relation_and_expr:  relation_exprs
                    {
                        code += "&& ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += "\n";
                    }
                 |  relation_exprs AND relation_and_expr
                    {}
                 ;

relation_exprs:     relation_expr
                    {}
              |     NOT relation_expr
                    {}
              ;

relation_expr:      expressions comp expressions
                    {
                        code += ". ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += "\n";
                    }
             |	    TRUE
                    {trueTag = true;}
             |      FALSE
                    {falseTag = false;}
             |      L_PAREN bool_expr R_PAREN
                    {}
             ;

comp:           EQ
                {eqTag = true;}
    |           NEQ
                {neqTag = true;}
    |           LT
                {ltTag = true;}
    |           GT
                {gtTag = true;}
    |           LTE
                {lteTag = true;}
    |           GTE
                {gteTag = true;}
    ;

expressions:
                {}
           |    expression
                {}
           |    expression COMMA expressions
                {}
           ;

expression:     multiplicative_expr
                {}
          |     multiplicative_expr ADD expression
                {}
          |     multiplicative_expr SUB expression
                {}
          ;

multiplicative_expr:    term
                        {}
                   | 	term MULT multiplicative_expr
                        {multTag = true;}
                   | 	term DIV multiplicative_expr
                        {divTag = true;}
                   | 	term MOD multiplicative_expr
                        {modTag = true;}
                   ;

terms:          var
                {}
     |		    NUMBER
                {
                    if (!isSub) {
                        string t = new_temp();
                        code += ". " + t + "\n= " + t + ", ";
                        code += to_string($1) + "\n";
                    }
                }
     |          L_PAREN expression R_PAREN
                {
                    code += "param temp " + to_string(numTemp - 1) + "\n";
                    code += "call ";
                    string str(idTable.back());
                    for (int i = 0; i< str.size(); i++) {
                        if (str.at(i) == '(' || str.at(i) == ' ') {
                            i = 100; // breaks for loop
                        }
                        else {
                            code += str.at(i);
                        }
                    }
                    code += ", temp " + to_string(numTemp-1) + "\n";
                }
     ;

term:           terms
                {isSub = false;}
    |           SUB terms
                {isSub = true;}
    |           IDENTIFIER L_PAREN expressions R_PAREN
                {
                   if (find(functionTable.begin(), functionTable.end(), "main") == functionTable.end()) {

                   }
                }
    ;

%%
//  checks if multiple functions share same name
//  for (int i = 0; i < functionTable.size() - 1; ++i) {
//		for (int j = i+1; j < idFuncTable.size(); ++j) {
//			if (functionTable.at(i) == idFuncTable.at(j)) {
//				isError = false;
//				cerr << "Multiple functions with same name detected. \n";
//			}
//		}
//	}
