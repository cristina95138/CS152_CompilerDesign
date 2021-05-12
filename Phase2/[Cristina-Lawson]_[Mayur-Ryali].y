/*
 Bison file
*/

/* Include Variables */
%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char *msg);
    int currLine = 1, currPos = 1;
    FILE* yyin;
%

%start PROGRAM
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <identVal> IDENTIFIER
%token <intVal> INTEGER
%left SUB ADD
%left MULT DIV MOD
%right EQ NEQ LT GT LTE GTE



program:        functions                               {printf("program -> functions\n");}
       ;

functions:                                              {printf("functions -> epsilon\n");}
         |      function functions                      {printf("functions -> function functions\n");}
         ;

function:       FUNCTION IDENTIFIER SEMICOLON
                BEGIN_PARAMS declarations END_PARAMS
                BEGIN_LOCALS declarations END_LOCALS
                BEGIN_BODY statements END_BODY          {printf("function -> FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS BEGIN_BODY statements END_BODY\n");}
        ;

declarations:                                           {printf("declarations -> epsilon\n");}
            |   declaration SEMICOLON declarations      {printf("declarations -> declaration SEMICOLON declarations\n");}
            ;

declaration:    identifiers COLON ENUM L_PAREN
                identifiers R_PAREN INTEGER             {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN INTEGER\n");}
           |    identifiers COLON ARRAY
                L_SQUARE_BRACKET NUMBER
                R_SQUARE_BRACKET OF INTEGER             {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
           |    identifiers COLON INTEGER               {printf("declaration -> identifiers COLON INTEGER\n");}
           ;

identifiers:                                            {printf("identifiers -> epsilon\n");}
           |    IDENTIFIER identifiers                  {printf("identifiers -> IDENTIFIER identifiers\n");}
           |    COMMA IDENTIFIER identifiers            {printf("identifiers -> COMMA IDENTIFIER identifiers\n");}
           ;

statements:                                             {printf("statements -> epsilon\n");}
          |     statement SEMICOLON statements          {printf("statements -> statement SEMICOLON statements\n");}
          ;

statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
        | IF bool_exp THEN stmt_loop ENDIF {printf("statement -> IF bool_exp THEN stmt_loop ENDIF\n");}
        | IF bool_exp THEN stmt_loop ELSE stmt_loop ENDIF {printf("statement -> IF bool_exp THEN stmt_loop ELSE stmt_loop ENDIF\n");}
        | WHILE bool_exp BEGINLOOP stmt_loop ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP stmt_loop ENDLOOP\n");}
        | DO BEGINLOOP stmt_loop ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP stmt_loop ENDLOOP WHILE bool_exp\n");}
        | READ var_loop {printf("statement -> READ var_loop\n");}
        | WRITE var_loop {printf("statement -> WRITE var_loop\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        | RETURN expression {printf("statement -> RETURN expression\n");}
        ;

stmt_loop: statement SEMICOLON {printf("stmt_loop -> statement SEMICOLON\n");}
        | stmt_loop statement SEMICOLON {printf("stmt_loop -> stmt_loop statement SEMICOLON\n");}

var_loop: var {printf("var_loop -> var\n");}
        | var_loop COMMA var {printf("var_loop -> var_loop COMMA var\n");}


vars:                                                   {printf("vars -> epsilon\n");}
    |           var                                     {printf("vars -> var\n");}
    |           var COMMA vars                          {printf("vars -> var COMMA vars\n");}
    ;

var:            IDENTIFIER                              {printf("var -> IDENTIFIER\n");}
   |            IDENTIFIER L_SQUARE_BRACKET expr
                R_SQUARE_BRACKET                        {printf("var -> IDENTIFIER L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n");}
   ;

bool_exp: relation_and_expr {printf("bool_exp -> relation_and_expr\n");}
        | relation_and_expr OR relation_and_expr {printf("bool_exp -> relation_and_expr OR relation_and_expr\n");}
        ;

relation_and_expr: relation_expr {printf("relation_and_expr -> relation_xpr\n");}
        | relation_expr AND relation_expr {printf("relation_and_expr -> relation_expr AND relation_expr\n");}
        ;

relation_exprs:

relation_expr:

comp:           EQ                                      {printf("comp -> EQ\n");}
    |           NEQ                                     {printf("comp -> NEQ\n");}
    |           LT                                      {printf("comp -> LT\n");}
    |           GT                                      {printf("comp -> GT\n");}
    |           LTE                                     {printf("comp -> LTE\n");}
    |           GTE                                     {printf("comp -> GTE\n");}
    ;

expressions:

expression:

multiplicative_exprs:

multiplicative_expr:

terms:

term:


int yywrap() {
    return 1;
}

int main(int argc, char* argv[]) {
  if (argc == 2) {
    yyin = fopen(argv[1], "r");
    if (yyin == 0) {
      printf("Error opening file: %s\n", argv[1]);
      exit(1);
    }
  }
  else {
    yyin = stdin;
  }

  yylex();

  return 0;
}
