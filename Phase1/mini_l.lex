/* Include Variables */
%{
  int numints = 0, numops = 0, numparens = 0, numequals = 0;
%}

/* Define Rules */
DIGIT [0-9]
LETTER [a-zA-Z]
WHITESPACE [\t]
NEWLINE [\n]

/* Define Patterns */
%%
/* Reserved Words */
"function"     printf("FUNCTION\n");
"beginparams"  printf("BEGIN_PARAMS\n");
"endparams"    printf("END_PARAMS"\n);
"beginlocals"  printf("BEGIN_LOCALS\n");
"endlocals"    printf("END_LOCALS\n");
"beginbody"    printf("BEGIN_BODY\n");
"endbody"      printf("END_BODY\n");
"integer"      printf("INTEGER\n");
"array"        printf("ARRAY\n");
"enum"         printf("ENUM\n");
"of"           printf("OF\n");
"if"           printf("IF\n");
"then"         printf("THEN\n");
"endif"        printf("ENDIF\n");
"else"         printf("ELSE\n");
"while"        printf("WHILE\n");
"do"           printf("DO\n");
"beginloop"    printf("BEGINLOOP\n");
"endloop"      printf("ENDLOOP\n");
"continue"     printf("CONTINUE\n");
"read"         printf("READ\n");
"write"        printf("WRITE\n");
"and"          printf("AND\n");
"or"           printf("OR\n");
"not"          printf("NOT\n");
"true"         printf("TRUE\n");
"false"        printf("FALSE\n");
"return"       printf("RETURN\n");

/* Arithmetic Operators */
"-"            printf("SUB\n");
"+"            printf("ADD\n");
"*"            printf("MULT\n");
"/"            printf("DIV\n");
"%"            printf("MOD\n");

/* Comparison Operators */
"=="           printf("EQ\n");
"<>"           printf("NEQ\n");
"<"            printf("LT\n");
">"            printf("GT\n");
"<="           printf("LTE\n");
">="           printf("GTE\n");


/* Identifiers and Numbers */
{DIGIT}*"."?{DIGIT}+([eE][+-]?{DIGIT}+)?  printf("NUMBER %s\n", yytext);

/* Other Special Symbols */
";"            printf("SEMICOLON\n");
":"            printf("COLON\n");
","            printf("COMMA\n");
"("            printf("L_PAREN\n");
")"            printf("R_PAREN\n");
"["            printf("L_SQUARE_BRACKET\n");
"]"            printf("R_SQUARE_BRACKET\n");
":="           printf("ASSIGN\n");

.         {
  printf("Error! Unrecognized token %s.\n", yytext);
  exit(1);
}

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