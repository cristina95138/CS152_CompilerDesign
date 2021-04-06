/* Include Variables */
%{
  int numints = 0, numops = 0, numparens = 0, numequals = 0;
%}

/* Define Rules */
DIGIT [0-9]


/* Define Patterns */
%%
{DIGIT}*"."?{DIGIT}+([eE][+-]?{DIGIT}+)?  printf("NUMBER %s\n", yytext); numints++;
"+"       printf("PLUS\n"); numops++;
"-"       printf("MINUS\n"); numops++;
"*"       printf("MULT\n"); numops++;
"/"       printf("DIV\n"); numops++;
"("       printf("L_PAREN\n"); numparens++;
")"       printf("R_PAREN\n"); numparens++;
"="       printf("EQUAL\n"); numequals++;
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