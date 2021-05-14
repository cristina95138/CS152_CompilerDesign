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
%}

%union {
    int intVal;
    char* identVal
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
%left SUB ADD
%left MULT DIV MOD
%right EQ NEQ LT GT LTE GTE

%%

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

statement:      var ASSIGN expression                   {printf("statement -> var ASSIGN expression\n");}
        |       IF bool_exp THEN stmt_loop ENDIF        {printf("statement -> IF bool_exp THEN stmt_loop ENDIF\n");}
        |       IF bool_exp THEN stmt_loop ELSE
                stmt_loop ENDIF                         {printf("statement -> IF bool_exp THEN stmt_loop ELSE stmt_loop ENDIF\n");}
        |       WHILE bool_exp BEGINLOOP stmt_loop
                ENDLOOP                                 {printf("statement -> WHILE bool_exp BEGINLOOP stmt_loop ENDLOOP\n");}
        |       DO BEGINLOOP stmt_loop ENDLOOP
                WHILE bool_exp                          {printf("statement -> DO BEGINLOOP stmt_loop ENDLOOP WHILE bool_exp\n");}
        |       READ var_loop                           {printf("statement -> READ var_loop\n");}
        |       WRITE var_loop                          {printf("statement -> WRITE var_loop\n");}
        |       CONTINUE                                {printf("statement -> CONTINUE\n");}
        |       RETURN expression                       {printf("statement -> RETURN expression\n");}
        ;

stmt_loop:      statement SEMICOLON                     {printf("stmt_loop -> statement SEMICOLON\n");}
        |       stmt_loop statement SEMICOLON           {printf("stmt_loop -> stmt_loop statement SEMICOLON\n");}
        ;

var_loop:       var                                     {printf("var_loop -> var\n");}
        |       var_loop COMMA var                      {printf("var_loop -> var_loop COMMA var\n");}
        ;

vars:                                                   {printf("vars -> epsilon\n");}
    |           var                                     {printf("vars -> var\n");}
    |           var COMMA vars                          {printf("vars -> var COMMA vars\n");}
    ;

var:            IDENTIFIER                              {printf("var -> IDENTIFIER\n");}
   |            IDENTIFIER L_SQUARE_BRACKET expression
                R_SQUARE_BRACKET                        {printf("var -> IDENTIFIER L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n");}
   ;

bool_exp:       relation_and_expr                       {printf("bool_exp -> relation_and_expr\n");}
        |       bool_exp OR relation_and_expr           {printf("bool_exp -> bool_exp OR relation_and_expr\n");}
        ;

relation_and_expr:  relation_expr                       {printf("relation_and_expr -> relation_xpr\n");}
                 |  relation_and_expr AND relation_expr {printf("relation_and_expr -> relation_and_expr AND relation_expr\n");}
                 ;

relation_exprs:                                         {printf("relation_exprs -> epsilon\n");}
              |     relation_expr SEMICOLON
                    relation_exprs                      {printf("relation_exprs -> relation_expr SEMICOLON relation_exprs\n");}
              ;

relation_expr:      expression comp expression          {printf(relation_expr -> expression comp expression);}
             |      NOT expression comp expression      {printf(relation_expr -> NOT expression comp expression);}
             |      TRUE                                {printf(relation_expr -> TRUE);}
             |      NOT TRUE                            {printf(relation_expr -> NOT TRUE);}
             |      FALSE                               {printf(relation_expr -> FALSE);}
             |      NOT FALSE                           {printf(relation_expr -> NOT FALSE);}
             |      L_PAREN bool_exp R_PAREN            {printf(relation_expr -> L_PAREN bool_exp R_PAREN);}
             |      NOT L_PAREN bool_exp R_PAREN        {printf(relation_expr -> NOT L_PAREN bool_exp R_PAREN);}
             ;

comp:           EQ                                      {printf("comp -> EQ\n");}
    |           NEQ                                     {printf("comp -> NEQ\n");}
    |           LT                                      {printf("comp -> LT\n");}
    |           GT                                      {printf("comp -> GT\n");}
    |           LTE                                     {printf("comp -> LTE\n");}
    |           GTE                                     {printf("comp -> GTE\n");}
    ;

expressions:                                            {printf("expressions -> epsilon\n");}
           |    expression COMMA expressions            {printf("expressions -> expression COMMA expressions\n");}
           ;

expression:     multiplicative_expr                     {printf("expression -> multiplicative_expr\n");}
          |     expression ADD multiplicative_expr      {printf("expression -> expression ADD multiplicative_expr\n");}
          |     expression SUB multiplicative_expr      {printf("expression -> expression SUB multiplicative_expr\n");}
          ;

multiplicative_exprs:                                   {printf("multiplicative_exprs -> epsilon\n");}
                    | multiplicative_expr COMMA
                      multiplicative_exprs              {printf("multiplicative_exprs -> multiplicative_expr COMMA multiplicative_exprs\n");}
                    ;

multiplicative_expr:    term                            {printf("multiplicative_expr -> term\n");}
                   | multiplicative_expr MULT term      {printf("multiplicative_expr -> tmultiplicative_expr MULT term\n");}
                   | multiplicative_expr DIV term       {printf("multiplicative_expr -> multiplicative_expr DIV term\n");}
                   | multiplicative_expr MOD term       {printf("multiplicative_expr -> multiplicative_expr MOD term\n");}
                   ;

terms:                                                  {printf("terms -> epsilon\n");}
     |          term COMMA terms                        {printf("terms -> term COMMA terms\n");}
     ;

term:           var                                     {printf("term -> var\n");}
    |           SUB var                                 {printf("term -> SUB var\n");}
    |           NUMBER                                  {printf("term -> NUMBER %d\n", $1);}
    |           SUB NUMBER                              {printf("term -> SUB NUMBER %d\n", $2);}
    |           L_PAREN expression R_PAREN              {printf("term -> L_PAREN expression R_PAREN\n");}
    |           SUB L_PAREN expression R_PAREN          {printf("term -> SUB L_PAREN expression R_PAREN\n");}
    |           IDENTIFIER L_PAREN R_PAREN              {printf("term -> IDENTIFIER %s L_PAREN R_PAREN\n", $1);}
    |           IDENTIFIER L_PAREN expr_loop R_PAREN    {printf("term -> IDENTIFIER %s L_PAREN expr_loop R_PAREN\n", $1);}
    ;

expr_loop:      expression                              {printf("expr_loop -> expression\n");}
         |      expr_loop COMMA expression              {printf("expr_loop -> expr_loop COMMA expression\n");}
         ;

%%

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
