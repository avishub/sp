ALPHA [A-Za-z]
DIGIT [0-9]
%%
switch                return SWITCH;
case                 return CASE;
break                 return BREAK;
default                return DEFAULT;
{ALPHA}({ALPHA}|{DIGIT})*    return ID;
{DIGIT}+             {yylval=atoi(yytext); return NUM;}
[ \t]                 ;
\n                yyterminate();
.                 return yytext[0];
%%
