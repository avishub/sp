%token ID NUM SWITCH BREAK CASE DEFAULT
%right '='
%left '+' '-'
%left '*' '/'
%left UMINUS
%%

S:SWITCH'('ID')''{'B'}';

B:C | C D;

C:C C| CASE E {lab1();} ':'E';'{lab2();} |BREAK';';

D: DEFAULT':' E ';'{def();} BREAK';'{lab3();};

E :V '='{push();} E{codegen_assign();}
  | E '+'{push();} E{codegen();}
  | E '-'{push();} E{codegen();}
  | E '*'{push();} E{codegen();}
  | E '/'{push();} E{codegen();}
  | '(' E ')'
  | '-'{push();} E{codegen_umin();} %prec UMINUS
  | V
  | NUM{push();}
  ;
V : ID {push();}
  ;
%%

#include "lex.yy.c"
#include<ctype.h>
char st[100][10];
int top=0;
char i_[2]="0";
char temp[2]="t";

int label[20];
int lnum=0;
int ltop=0;

main()
 {
 printf("Enter the expression : \n");
 yyparse();

 }

push()
 {
  strcpy(st[++top],yytext);
 }

codegen()
 {
 strcpy(temp,"t");
 strcat(temp,i_);
  printf("%s = %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
  top-=2;
 strcpy(st[top],temp);
 i_[0]++;
 }

codegen_umin()
 {
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = -%s\n",temp,st[top]);
 top--;
 strcpy(st[top],temp);
 i_[0]++;
 }

codegen_assign()
 {
 printf("%s = %s\n",st[top-2],st[top]);
 top-=2;
 }

lab1()
{
 lnum++;
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = not %s\n",temp,st[top]);
 printf("if %s goto L%d\n",temp,lnum);
 i_[0]++;
 label[++ltop]=lnum;
}

def()
{
int x;
lnum++;
x=label[ltop--];
label[++ltop]=lnum;
}


lab2()
{
int x;
lnum++;
x=label[ltop--];
printf("goto EXIT\n");
printf("L%d: \n",x);
label[++ltop]=lnum;
}

lab3()
{
printf("EXIT:exit()\n");
}


/*-----------------------------------------------------------------
OUTPUT::

lex switch.l
yacc -d switch.y
gcc y.tab.c -ly -ll
./a.out
Enter the expression : 
switch(a){ case 1:a=1; break; case 2:a=2; break; default:a=0; break; }
t0 = not 1
if t0 goto L1
a = 1
goto EXIT
L1: 
t1 = not 2
if t1 goto L3
a = 2
goto EXIT
L3: 
a = 0
EXIT:exit()*/
