/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%option noyywrap 
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

bool max_string_check();
bool max_string_check(int);
int max_string_err();
int nested_level = 0;
%}
/*
 *  Add Your own definitions here
 */
%x STRING
%x COMMENT
/*
 * Define names for regular expressions here.
 */

DARROW        =>
LETTER      [a-zA-Z_]
DIGIT       [0-9]
NEWLINE     (\r\n|\n)+
WHITESPACE  [ \t]*
DASHCOMMENT --.*
INVALID     [!#\$%\^&_>\?`\[\]\\\|]

CLASS       ([Cc][Ll][Aa][Ss][Ss])
ELSE        ([Ee][Ll][Ss][Ee])
FI          ([Ff][Ii])
IF          ([Ii][Ff])
IN          ([Ii][Nn])
INHERITS    ([Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss])
LET         ([Ll][Ee][Tt])
LOOP        ([Ll][Oo][Oo][Pp])
POOL        ([Pp][Oo][Oo][Ll])
THEN        ([Tt][Hh][Ee][Nn])
WHILE       ([Ww][Hh][Ii][Ll][Ee])
CASE        ([Cc][Aa][Ss][Ee])
ESAC        ([Ee][Ss][Aa][Cc])
NEW         ([Nn][Ee][Ww])
ISVOID      ([Ii][Ss][Vv][Oo][Ii][Dd])
OF          ([Oo][Ff])
NOT         ([Nn][Oo][Tt])

TYPEID      [A-Z]({DIGIT}|{LETTER})*
OBJECTID    [a-z]({DIGIT}|{LETTER})*
INT_CONST   {DIGIT}+

%%


 /*
  *  Stringovi
  */

\" {
    BEGIN(STRING);
    string_buf_ptr = string_buf;
}

<STRING>\" {
    BEGIN(INITIAL);
    if (max_string_check()) return max_string_err();
    *string_buf_ptr = '\0';
    cool_yylval.symbol = stringtable.add_string(string_buf);
    return STR_CONST;
}
<STRING>\\[^ntbf] {
    if (max_string_check()) return max_string_check();
    *string_buf_ptr++ = yytext[1];
}
<STRING>\\[n] {
    if (max_string_check()) return max_string_check();
    *string_buf_ptr++ = '\n';
}
<STRING>\\[t] {
    if (max_string_check()) return max_string_check();
    *string_buf_ptr++ = '\t';
}
<STRING>\\[b] {
    if (max_string_check()) return max_string_check();
    *string_buf_ptr++ = '\b';
}
<STRING>\\[f] {
    if (max_string_check()) return max_string_check();
    *string_buf_ptr++ = '\f';
}
<STRING>. {
    if (max_string_check()) return max_string_err();
    *string_buf_ptr++ = *yytext;
}

 /*
  *  String errori
  */

<STRING>\n {
    curr_lineno++;
    BEGIN(INITIAL);
    cool_yylval.error_msg = "Unterminated string constant";
    return ERROR;
}

<STRING><<EOF>> {
    BEGIN(INITIAL);
    cool_yylval.error_msg = "EOF in string constant";
    return ERROR;
}

 /*
  *  Komentari
  */
 /*
  *  Nested comments
  */

"*)" {
    cool_yylval.error_msg = "Unmatched *)";
    return ERROR;
}
"(*" {
    BEGIN(COMMENT);
}

<COMMENT>{ 
    "(*"       { nested_level++; }
    "*)"      { if (nested_level) --nested_level;
                else BEGIN(INITIAL); }
    .           { ; }
    "\n"      {curr_lineno++;}
}
<COMMENT><<EOF>> {
    BEGIN(INITIAL);
    cool_yylval.error_msg = "EOF in comment";
    return ERROR;
}

 /*
  *  The multiple-character operators.
  */
{DARROW}	{ return (DARROW); }
"<="        { return LE; }
"<-"        { return ASSIGN; }
"<"         { return '<'; }
"@"         { return '@'; }
"~"         { return '~'; }
"="         { return '='; }
"."         { return '.'; }
"-"         { return '-'; }
","         { return ','; }
"+"         { return '+'; }
"*"         { return '*'; }
"/"         { return '/'; }
"}"         { return '}'; }
"{"         { return '{'; }
"("         { return '('; }
")"         { return ')'; }
":"         { return ':'; }
";"         { return ';'; }
{CLASS}     { return 258; }
{ELSE}      { return 259; }
{FI}        { return 260; }
{IF}        { return IF; }
{IN}        { return IN; }
{INHERITS}  { return INHERITS; }    
{LET}       { return LET; } 
{LOOP}      { return LOOP; }    
{POOL}      { return POOL; }
{THEN}      { return THEN; }
{WHILE}     { return WHILE; }
{CASE}      { return CASE; }
{ESAC}      { return ESAC; }
{NEW}       { return NEW; }
{ISVOID}    { return ISVOID; }
{OF}        { return OF; }
{NOT}       { return NOT; }


f[Aa][Ll][Ss][Ee] {
    cool_yylval.boolean = 0;
    return (BOOL_CONST);
}
t[Rr][Uu][Ee]  {
    cool_yylval.boolean = 1;
    return (BOOL_CONST);
}
{NEWLINE}    { curr_lineno++; }
{WHITESPACE} { ; }

{DASHCOMMENT} { curr_lineno++; }

{INT_CONST} { 
    cool_yylval.symbol = inttable.add_string(yytext);
    return INT_CONST; 
}

{OBJECTID} { 
    cool_yylval.symbol = idtable.add_string(yytext); 
    return OBJECTID; 
}
{TYPEID} { 
    cool_yylval.symbol = idtable.add_string(yytext); 
    return TYPEID; 
}
{INVALID}  {
    cool_yylval.error_msg = strdup(yytext);
    return ERROR;
}

 /*
  * invisible and other characters 
  */

^[^({INT_CONST}{OBJECTID}{TYPEID})] { ; }

[^({INT_CONST}{OBJECTID}{TYPEID})] {
    cool_yylval.error_msg = strdup(yytext);
    return ERROR;
}
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

%%

bool max_string_check () { 
    return (string_buf_ptr - string_buf) + 1 > MAX_STR_CONST; 
}
bool max_string_check (int size) {
    return (string_buf_ptr - string_buf) + size > MAX_STR_CONST;
}
int max_string_err() { 
    BEGIN(INITIAL);
    cool_yylval.error_msg = "String constant too long";
    return ERROR;
}