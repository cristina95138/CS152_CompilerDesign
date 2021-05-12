/*
 Bison file
*/

%{
    #include <stdio.h>
    #include <stdlib.h>

    void yyerror(const char *str);
    extern int currPos;
    extern int currLine;

    File *yyin;
%}

%error-verbose
%start program
%type <strval> mulop

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE
%token WHILE DO BEGINLOOP ENDLOOP CONTINUE
%token READ WRITE AND OR NOT TRUE FALSE RETURN
%token ADD SUB MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <strval> IDENTIFIER
%token <ival> NUMBER

%%

program:
        | program function
        ;

function:   FUNCTION IDENTIFIER SEMICOLON
            BEGIN_PARAMS dec_loop END_PARAMS
            BEGIN_LOCALS dec_loop END_LOCALS
            BEGIN_BODY stmt_loop END_BODY
            ;

dec_loop:
        | dec_loop declaration SEMICOLON
        ;

stmt_loop:
        | stmt_loop statement SEMICOLON
        ;

declaration: iden_loop COLON INTEGER
        | iden_loop COLON ENUM L_PAREN iden_loop R_PAREN
        | iden_loop L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
        ;

iden_loop: IDENTIFIER
        | iden_loop COMMA IDENTIFIER
        ;
    
