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
    #include <algorithm>
    using namespace std;

    extern "C" int yylex();
    void yyerror(const char *msg);
    extern int currPos, currLine;
    extern FILE* yyin;

    bool no_error = true;

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
        string tmp = "__temp__" + to_string(numTemp);
        tempTable.push_back(tmp);
        numTemp++;
        return tmp;
    }
    string new_label() {
        string lbl = "__label__" + to_string(numLabel);
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
    struct startprog {
	} startprog;
	struct grammar {
		char code;
	} grammar;
}

%error-verbose

%start startprogram
%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY
%token ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA LPAREN RPAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <intVal> NUMBER
%token <identVal> IDENT
%token <intVal> INTEGER
%type <startprog> startprogram
%type <grammar> program functions function declarations declaration identifiers statements statement vars var bool_expr relation_and_expr relation_expr comp expressions expression multiplicative_expr terms term
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

startprogram:	program
                {}
  	    	;

program:        functions
                {
                    /*if (find(functionTable.begin(), functionTable.end(), "main") == functionTable.end()) {
                        cout << "Error line " << currLine << " : no main function declared." << endl;
                        no_error = true;
                    }

                    if (no_error) {
                        return -1;
                    }*/
                }
       ;

functions:      /* epsilon*/
                {}
         |      function functions
                {}
         ;

function:       FUNCTION IDENT SEMICOLON
                BEGINPARAMS declarations ENDPARAMS
                BEGINLOCALS declarations ENDLOCALS
                BEGINBODY statements ENDBODY
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

declaration:    identifiers COLON ENUM LPAREN
                identifiers RPAREN
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
                    for (unsigned i =0; i < str.size(); i++) { // getting first identifier
                        if (str.at(i) == '(' || str.at(i) == ')' || str.at(i) == ' ' || str.at(i) == ';') {
                            i =100; // breaks for loop
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

identifiers:    IDENT
                {
                    string t;
                    if (isFunc) {
                        functionTable.push_back($1);
                        isFunc = false;
                        code += "FUNCTION";
                        string str($1);
                        for (unsigned i =0; i< str.size(); i++) {
                            if (str.at(i) == '(' || str.at(i) == ')' || str.at(i) == ' ' || str.at(i) == ';') {
                                i =100; // breaks for loop
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
                        for (unsigned i =0; i< str.size(); i++) {
                            if (str.at(i) == '(' || str.at(i) == ')' || str.at(i) == ' ' || str.at(i) == ';') {
                                i =100; // breaks for loop
                            }
                            else {
                                code += str.at(i);
                                t += str.at(i);
                            }
                        }
                    }
                    code += "\n"; idTable.push_back(t); idNum++;
                }
           |    IDENT COMMA identifiers
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
                    code += "ret ";
                    code += "__temp__" + to_string(numTemp-1) + "\n";
                }
        ;

vars:
                {}
    |           var
                {}
    |           var COMMA vars
                {}
    ;

var:            IDENT
                {
                    /*
                    varTable.push_back(idTable.back());
                    idTable.pop_back();
                    */
                }
   |            IDENT L_SQUARE_BRACKET expression
                R_SQUARE_BRACKET
                {
                    code += ".[] "; string str($1);
                    for (int i =0; i < str.size(); ++i) {
                            if (str.at(i) == ' ' || str.at(i) == '('){
                                    i = 100;
                            }
                            else {
                                    code += str.at(i);
                            }
                    }
                    code += ",\n";

                    /*
                    code += ". ";
                    code += idTable.back(); // id
                    code += "=[] ";
                    code += idTable.back(); // id
                    code += ", ";
                    code += idTable.back(); // id
                    code += "\n";
                    */
                }

   ;

bool_expr:      relation_and_expr
                {
                    /*
                    code += "|| ";
                    code += idTable.back(); //id
                    code += ", ";
                    code += idTable.back(); //id
                    code += ", ";
                    code += idTable.back(); //id
                    code += "\n";
                    */
                }
        |       relation_and_expr OR relation_and_expr
                {}
        ;

relation_and_expr:  relation_exprs
                    {
                        /*
                        code += "&& ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += "\n";
                        */
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
                        /*
                        code += ". ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += ", ";
                        code += idTable.back(); //id
                        code += "\n";
                        */
                    }
             |	    TRUE
                    {}
             |      FALSE
                    {}
             |      LPAREN bool_expr RPAREN
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
                {
                    if (addTag == true) {addTag = false; string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n+ __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 6); code += ", __temp__" + to_string(numTemp - 2) + "\n";}
                    if (subTag == true) {subTag = false; string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n- __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n";/* code += "param __temp__" + to_string(numTemp-1); code += "\n";*/}
                    if (multTag == true) {multTag = false; string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n* __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n";}
                    if (divTag == true) {divTag = false; string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n/ __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n";}
                    if (modTag == true) {modTag = false; string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n% __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n";}
                    if (lteTag == true) {lteTag = false; string lab = new_label(); string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n<= __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n?:= " + lab + ", __temp__" + to_string(numTemp-1) + "\n"; string lab2 = new_label(); code += ":= " + lab2 + "\n" + ": " + lab + "\n";}
                    if (gteTag == true) {gteTag = false; string lab = new_label(); string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n>= __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n?:= " + lab + ", __temp__" + to_string(numTemp-1) + "\n"; string lab2 = new_label(); code += ":= " + lab2 + "\n" + ": " + lab + "\n";}
                    if (ltTag == true) {ltTag = false; string lab = new_label(); string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n< __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n?:= " + lab + ", __temp__" + to_string(numTemp-1) + "\n"; string lab2 = new_label(); code += ":= " + lab2 + "\n" + ": " + lab + "\n";}
                    if (gtTag == true) {gtTag = false; string lab = new_label(); string temp = new_temp(); code += ". __temp__" + to_string(numTemp-1); code += "\n> __temp__" + to_string(numTemp-1) + ", "; code += "__temp__" + to_string(numTemp - 3); code += ", __temp__" + to_string(numTemp - 2) + "\n?:= " + lab + ", __temp__" + to_string(numTemp-1) + "\n"; string lab2 = new_label(); code += ":= " + lab2 + "\n" + ": " + lab + "\n";}
                }
           |    expression COMMA expressions
                {}
           ;

expression:     multiplicative_expr
                {}
          |     multiplicative_expr ADD expression
                {addTag = true;}
          |     multiplicative_expr SUB expression
                {subTag = true;}
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
     |          LPAREN expression RPAREN
                {
                    code += "param temp " + to_string(numTemp - 1) + "\n";
                    code += "call ";
                    string str(idTable.back());
                    for (unsigned i =0; i< str.size(); i++) {
                        if (str.at(i) == '(' || str.at(i) == ' ') {
                            i =100; // breaks for loop
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
    |           IDENT LPAREN expressions RPAREN
                {
                    code += "param __temp__" + to_string(numTemp-1) + "\n";

                    string temp = new_temp(); code += ". " + temp + "\n"; code += "call "; string str($1);
                    for (int i = 0; i < str.size(); ++i) {
                             if (str.at(i) == ' ' || str.at(i) == '('){
                                     i = 100;
                             }
                             else {
                                     code += str.at(i);
                             }
                     }
                     code += ", __temp__" + to_string(numTemp-1) + "\n";

                     /*
                     if (find(functionTable.begin(), functionTable.end(), "main") == functionTable.end()) {

                     }
                     */

                }
    ;

%%

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

  //  checks if multiple functions share same name
    for (unsigned i =0; i < functionTable.size() - 1; ++i) {
  		for (unsigned j = i+1; j < idFuncTable.size(); ++j) {
  			if (functionTable.at(i) == idFuncTable.at(j)) {
  				no_error = false;
  				cerr << "Multiple functions with same name detected. \n";
  			}
  		}
  	}

    if (no_error) {
        ofstream file;
        file.open("CODE.mil");
        file << code;
        file.close();
    }
    else {
        cout << "Error! Couldn't properly generate code." << endl;
    }

    return 0;
}

void yyerror (const char* msg) {
    printf("Line %d, position %d: %s\n", currPos, currLine, msg);
}
