/*
 Bison file
*/

/* Include Variables */
%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex();
    void yyerror(const char *msg);
    int currLine, currPos;
    FILE* yyin;
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
%left ASSIGN
%left SUB ADD
%left AND OR
%left MULT DIV MOD
%left EQ NEQ LT GT LTE GTE
%right NOT

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
                identifiers R_PAREN		        {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
           |    identifiers COLON ARRAY
                L_SQUARE_BRACKET NUMBER
                R_SQUARE_BRACKET OF INTEGER             {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
           |    identifiers COLON INTEGER               {printf("declaration -> identifiers COLON INTEGER\n");}
           ;

identifiers:    IDENTIFIER		                {printf("identifiers -> IDENTIFIER\n");}
           |    IDENTIFIER COMMA identifiers            {printf("identifiers -> IDENTIFIER COMMA identifiers\n");}
           ;

statements:     statement SEMICOLON                     {printf("statements -> statement SEMICOLON\n");}
          |     statement SEMICOLON statements          {printf("statements -> statement SEMICOLON statements\n");}
          ;

statement:      					{printf("statement -> epsilon\n");}
	|	var ASSIGN expressions                  {printf("statement -> var ASSIGN expressions\n");}
        |       IF bool_expr THEN statements ENDIF      {printf("statement -> IF bool_expr THEN statements ENDIF\n");}
        |       IF bool_expr THEN statements ELSE
                statements ENDIF                        {printf("statement -> IF bool_expr THEN statements ELSE statements ENDIF\n");}
        |       WHILE bool_expr BEGINLOOP statements
                ENDLOOP                                 {printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n");}
        |       DO BEGINLOOP statements ENDLOOP
                WHILE bool_expr                         {printf("statement -> DO BEGINLOOP stmt_loop ENDLOOP WHILE bool_expr\n");}
        |       READ vars                           	{printf("statement -> READ vars\n");}
        |       WRITE vars                          	{printf("statement -> WRITE vars\n");}
        |       CONTINUE                                {printf("statement -> CONTINUE\n");}
        |       RETURN expressions                      {printf("statement -> RETURN expressions\n");}
        ;

vars:                                                   {printf("vars -> epsilon\n");}
    |           var                                     {printf("vars -> var\n");}
    |           var COMMA vars                          {printf("vars -> var COMMA vars\n");}
    ;

var:            IDENTIFIER                              {printf("var -> IDENTIFIER\n");}
   |            IDENTIFIER L_SQUARE_BRACKET expression
                R_SQUARE_BRACKET                        {printf("var -> IDENTIFIER L_SQUARE_BRACKET expressions R_SQUARE_BRACKET\n");}
   ;

bool_expr:      relation_and_expr                       {printf("bool_expr -> relation_and_expr\n");}
        |       relation_and_expr OR relation_and_expr  {printf("bool_expr -> relation_and_expr OR bool_expr\n");}
        ;

relation_and_expr:  relation_exprs                       {printf("relation_and_expr -> relation_exprs\n");}
                 |  relation_exprs AND relation_and_expr {printf("relation_and_expr -> relation_exprs AND relation_and_expr\n");}
                 ;

relation_exprs:     relation_expr			{printf("relation_exprs -> relation_expr\n");}
              |     NOT relation_expr             	{printf("relation_exprs -> NOT relation_expr\n");}
              ;

relation_expr:      expressions comp expressions        {printf("relation_expr -> expressions comp expressions\n");}
             |	    TRUE                                {printf("relation_expr -> TRUE\n");}
             |      FALSE                               {printf("relation_expr -> FALSE\n");}
             |      L_PAREN bool_expr R_PAREN           {printf("relation_expr -> L_PAREN bool_expr R_PAREN\n");}
             ;

comp:           EQ                                      {printf("comp -> EQ\n");}
    |           NEQ                                     {printf("comp -> NEQ\n");}
    |           LT                                      {printf("comp -> LT\n");}
    |           GT                                      {printf("comp -> GT\n");}
    |           LTE                                     {printf("comp -> LTE\n");}
    |           GTE                                     {printf("comp -> GTE\n");}
    ;

expressions:                                            {printf("expressions -> epsilon\n");}
	   |    expression				{printf("expressions -> expression\n");}
           |    expression COMMA expressions            {printf("expressions -> expression COMMA expressions\n");}
           ;

expression:     multiplicative_expr                     {printf("expression -> multiplicative_expr\n");}
          |     multiplicative_expr ADD expressions     {printf("expression -> multiplicative_expr ADD expressions\n");}
          |     multiplicative_expr SUB expressions     {printf("expression -> multiplicative_expr SUB expressions\n");}
          ;

multiplicative_expr:    term                            {printf("multiplicative_expr -> term\n");}
                   | 	term MULT multiplicative_expr   {printf("multiplicative_expr -> term MULT multiplicative_expr\n");}
                   | 	term DIV multiplicative_expr    {printf("multiplicative_expr -> term DIV multiplicative_expr\n");}
                   | 	term MOD multiplicative_expr    {printf("multiplicative_expr -> term MOD multiplicative_expr\n");}
                   ;

terms:          var					{printf("terms -> vars\n");}
     |		NUMBER					{printf("terms -> NUMBER\n");}
     |          L_PAREN expression R_PAREN              {printf("terms -> L_PAREN expression R_PAREN\n");}
     ;

term:           terms                                   {printf("term -> terms\n");}
    |           SUB terms                               {printf("term -> SUB terms\n");}
    |           IDENTIFIER L_PAREN expressions R_PAREN  {printf("term -> IDENTIFIER L_PAREN expressions R_PAREN\n");}
    ;

%%

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

  return 0;
}

void yyerror (const char* msg) {
    printf("Line %d, position %d: %s\n", currPos, currLine, msg);
}
