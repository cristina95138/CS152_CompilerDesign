/* Include Variables */
%{
    #include "y.tab.h"
    extern "C" int yylex();
    int currLine = 1, currPos = 1;
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

"function"     {currLine += yyleng; return FUNCTION;}
"beginparams"  {currLine += yyleng; return BEGIN_PARAMS;}
"endparams"    {currLine += yyleng; return END_PARAMS;}
"beginlocals"  {currLine += yyleng; return BEGIN_LOCALS;}
"endlocals"    {currLine += yyleng; return END_LOCALS;}
"beginbody"    {currLine += yyleng; return BEGIN_BODY;}
"endbody"      {currLine += yyleng; return END_BODY;}
"integer"      {currLine += yyleng; return INTEGER;}
"array"        {currLine += yyleng; return ARRAY;}
"enum"         {currLine += yyleng; return ENUM;}
"of"           {currLine += yyleng; return OF;}
"if"           {currLine += yyleng; return IF;}
"then"         {currLine += yyleng; return THEN;}
"endif"        {currLine += yyleng; return ENDIF;}
"else"         {currLine += yyleng; return ELSE;}
"while"        {currLine += yyleng; return WHILE;}
"do"           {currLine += yyleng; return DO;}
"beginloop"    {currLine += yyleng; return BEGINLOOP;}
"endloop"      {currLine += yyleng; return ENDLOOP;}
"continue"     {currLine += yyleng; return CONTINUE;}
"read"         {currLine += yyleng; return READ;}
"write"        {currLine += yyleng; return WRITE;}
"and"          {currLine += yyleng; return AND;}
"or"           {currLine += yyleng; return OR;}
"not"          {currLine += yyleng; return NOT;}
"true"         {currLine += yyleng; return TRUE;}
"false"        {currLine += yyleng; return FALSE;}
"return"       {currLine += yyleng; return RETURN;}

"-"            {currLine += yyleng; return SUB;}
"+"            {currLine += yyleng; return ADD;}
"*"            {currLine += yyleng; return MULT;}
"/"            {currLine += yyleng; return DIV;}
"%"            {currLine += yyleng; return MOD;}

"=="           {currLine += yyleng; return EQ;}
"<>"           {currLine += yyleng; return NEQ;}
"<"            {currLine += yyleng; return LT;}
">"            {currLine += yyleng; return GT;}
"<="           {currLine += yyleng; return LTE;}
">="           {currLine += yyleng; return GTE;}

{DIGIT}*"."?{DIGIT}+([eE][+-]?{DIGIT}+)?       {printf("NUMBER %s\n", yytext); currLine += yyleng; return NUMBER;}

";"            {currLine += yyleng; return SEMICOLON;}
":"            {currLine += yyleng; return COLON;}
","            {currLine += yyleng; return COMMA;}
"("            {currLine += yyleng; return L_PAREN;}
")"            {currLine += yyleng; return R_PAREN;}
"["            {currLine += yyleng; return L_SQUARE_BRACKET;}
"]"            {currLine += yyleng; return R_SQUARE_BRACKET;}
":="           {currLine += yyleng; return ASSIGN;}

{COMMENT}+     {currPos++; currLine = 1;}


({DIGIT}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*({LETTER}|{DIGIT}|{UNDERSCORE})     {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);}
({LETTER}|{DIGIT}|{UNDERSCORE})*{UNDERSCORE}                                              {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0);}

({LETTER}|{DIGIT}|{UNDERSCORE})*({LETTER}|{DIGIT})*                                       {printf("identifier -> IDENTIFIER %s\n", yytext); currLine += yyleng; return IDENTIFIER;}


[ ]                   {currLine += yyleng;}
{WHITESPACE}+         {currLine += yyleng;}
{NEWLINE}+            {currPos++; currLine = 1;}

.              {printf("Error at line %d, column %d: unrecognized token %s.\n", currLine, currPos, yytext); exit(0);}

%%
