/* Include Variables */
%{
  int currLine = 1, numints = 0, numops = 1, numparens = 0, numequals = 0, currPos = 0;
%}

/* Define Rules */
DIGIT      [0-9]
LETTER     [a-zA-Z]
WHITESPACE [\t]
NEWLINE    [\n]
UNDERSCORE [_]
COMMENT    ##.*

/* Define Tokens */

/* Reserved Words */
%%

"function"     printf("FUNCTION\n"); currLine += yyleng;
"beginparams"  printf("BEGIN_PARAMS\n"); currLine += yyleng;
"endparams"    printf("END_PARAMS\n"); currLine += yyleng;
"beginlocals"  printf("BEGIN_LOCALS\n"); currLine += yyleng;
"endlocals"    printf("END_LOCALS\n"); currLine += yyleng;
"beginbody"    printf("BEGIN_BODY\n"); currLine += yyleng;
"endbody"      printf("END_BODY\n"); currLine += yyleng;
"integer"      printf("INTEGER\n"); currLine += yyleng;
"array"        printf("ARRAY\n"); currLine += yyleng;
"enum"         printf("ENUM\n"); currLine += yyleng;
"of"           printf("OF\n"); currLine += yyleng;
"if"           printf("IF\n"); currLine += yyleng;
"then"         printf("THEN\n"); currLine += yyleng;
"endif"        printf("ENDIF\n"); currLine += yyleng;
"else"         printf("ELSE\n"); currLine += yyleng;
"while"        printf("WHILE\n"); currLine += yyleng;
"do"           printf("DO\n"); currLine += yyleng;
"beginloop"    printf("BEGINLOOP\n"); currLine += yyleng;
"endloop"      printf("ENDLOOP\n"); currLine += yyleng;
"continue"     printf("CONTINUE\n"); currLine += yyleng;
"read"         printf("READ\n"); currLine += yyleng;
"write"        printf("WRITE\n"); currLine += yyleng;
"and"          printf("AND\n"); currLine += yyleng;
"or"           printf("OR\n"); currLine += yyleng;
"not"          printf("NOT\n"); currLine += yyleng;
"true"         printf("TRUE\n"); currLine += yyleng;
"false"        printf("FALSE\n"); currLine += yyleng;
"return"       printf("RETURN\n"); currLine += yyleng;

"-"            printf("SUB\n"); currLine += yyleng;
"+"            printf("ADD\n"); currLine += yyleng;
"*"            printf("MULT\n"); currLine += yyleng;
"/"            printf("DIV\n"); currLine += yyleng;
"%"            printf("MOD\n"); currLine += yyleng;

"=="           printf("EQ\n"); currLine += yyleng;
"<>"           printf("NEQ\n"); currLine += yyleng;
"<"            printf("LT\n"); currLine += yyleng;
">"            printf("GT\n"); currLine += yyleng;
"<="           printf("LTE\n"); currLine += yyleng;
">="           printf("GTE\n"); currLine += yyleng;

{DIGIT}*"."?{DIGIT}+([eE][+-]?{DIGIT}+)?       printf("NUMBER %s\n", yytext); currLine += yyleng;

";"            printf("SEMICOLON\n"); currLine += yyleng;
":"            printf("COLON\n"); currLine += yyleng;
","            printf("COMMA\n"); currLine += yyleng;
"("            printf("L_PAREN\n"); currLine += yyleng;
")"            printf("R_PAREN\n"); currLine += yyleng;
"["            printf("L_SQUARE_BRACKET\n"); currLine += yyleng;
"]"            printf("R_SQUARE_BRACKET\n"); currLine += yyleng;
":="           printf("ASSIGN\n"); currLine += yyleng;

{COMMENT}+     {currPos++; currLine = 1;}


[0-9_][a-zA-z0-9_]*[a-zA-z0-9_]               {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);}
[a-zA-z0-9_]*[_]                              {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0);}

[a-zA-z0-9_]*[a-zA-z0-9]*                     {printf("IDENT %s\n", yytext); currLine += yyleng;}


.              {printf("Error at line %d, column %d: unrecognized token %s.\n", currLine, currPos, yytext); exit(1);}

[ ]                   {currLine += yyleng;}
{WHITESPACE}+         {currLine++;}
{NEWLINE}+            {currPos++; currLine = 1;}

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

  // print info
  printf("Number of integers encountered: %d\n", numints);
  printf("Number of operators encountered: %d\n", numops);
  printf("Number of parentheses encountered: %d\n", numparens);
  printf("Number of equal signs encountered: %d\n", numequals);

  return 0;
}
