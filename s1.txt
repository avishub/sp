#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define max 20
#define ad_max 5
#define is_max 11
#define reg_max 4
#define cond_max 6

struct sym_table
{
	char sym[15];
	int addr;
}s[max];


struct lit_table
{                              
	char lit[5];
	int addr;
}l[max];

int pool_table[max],sym_count=0,lit_count=0,pool_count=0,token_count=0,lc=-1,i,j,z,k;
char tok1[max],tok2[max],tok3[max],tok4[max],tok5[max],buffer[80],temp[max];
FILE *fp1,*fp2,*fp;

char reg[4][10] = {"AREG","BREG","CREG","DREG"};
char ad[5][10] = {"START","END","ORIGIN","EQU","LTORG"};
char is[11][10] = {"STOP","ADD","SUB","DIV","MULT","MOVER","MOVEM","BC","COMP","READ","PRINT"};
char cond[6][10] = {"LT","LE","GT","GE","EQ","ANY"};


int reg_search(char tok[])
{
	int i;
	for(i=0;i<reg_max;i++)
	{
		if(strcmp(reg[i],tok)==0)
			return i;
	}
	return -1;
}


int ad_search(char tok[])
{
	int i;
	for(i=0;i<ad_max;i++)
	{
		if(strcmp(ad[i],tok)==0)
			return i;
	}
	return -1;
}

int is_search(char tok[])
{
	int i;
	for(i=0;i<is_max;i++)
	{
		if(strcmp(is[i],tok)==0)
			return i;
	}
	return -1;
}


int cond_search(char tok[])
{
	int i;
	for(i=0;i<cond_max;i++)
	{
		if(strcmp(cond[i],tok)==0)
			return i;
	}
	return -1;
}


int sym_search(char tok[])
{
	int i;
	for(i=0;i<sym_count;i++)
	{
		if(strcmp(s[i].sym,tok)==0)
			return i;
	}
	return -1;
}

int lit_search(char tok[])
{
	int i;
	for(i=pool_table[pool_count];i<lit_count;i++)
	{
		if(strcmp(l[i].lit,tok)==0)
			return i;
	}
	return -1;
}


void display_sym_table()
{
	int i;

	printf("Index\tSymbol\tAddress\n");
	for(i=0;i<sym_count;i++)
{
	if(s[i].addr==0)
	{
		printf("\nSymbol not Defined %s\n",s[i].sym);
	
	}
	else{
	
	    printf("%d\t%s\t%d\n",i+1,s[i].sym,s[i].addr);
}
}
}

void display_lit_table()
{
	int i;
	
	printf("Literal Count\tLiteral\tAddress\n");
	for(i=0;i<lit_count;i++)
	    printf("%d\t%s\t%d\n",i,l[i].lit,l[i].addr);
	}


void display_pool_table()
{
	int i;
	printf("Pool_index\tPool_Base\n");
	for(i=0;i<pool_count;i++)
	    printf("%d\t%d\n",i,pool_table[i]);
}


void print_file(char fn[])
{
	FILE *fp = fopen(fn,"r");
	
	if(fp==NULL)
	{
		printf("Can't open file\n");
		exit(0);
	}
	
	while(fgets(buffer,80,fp))
	{
		printf("%s",buffer);
	}
	fclose(fp);
}



void onePass()
{
	fp1 = fopen("input.txt","r");
	
	if(fp1==NULL)
	{
		printf("Can't open file 1\n");
		exit(0);
	}
	
	fp2 = fopen("output.txt","w");
	
	if(fp2==NULL)
	{
		printf("Can't open file 2\n");
		exit(0);
	}
	
	while(fgets(buffer,80,fp1))
	{
		token_count = sscanf(buffer,"%s %s %s %s",tok1,tok2,tok3,tok4);   //MOVER A, B
		
		switch(token_count)
		{
			
			case 1:   //START,STOP,LTORG,END
					i = is_search(tok1);
					if(i==0) //STOP
					{
						fprintf(fp2,"(IS, %02d)\n",i);    //(IS,00)
						break;
					}
					
					i = ad_search(tok1);
					if(i==0) //START
					{
						fprintf(fp2,"(AD, %02d)\n",i);   //(AD,00)
						lc = -1;                                                       //pool table
						break;                                                   
					}
					
					if(i==1 || i==4)  //LTORG,END
					{
						fprintf(fp2,"(AD, %02d)\n",i);     //(AD,01)
						for(k=pool_table[pool_count];k<lit_count;k++)
						{
							l[k].addr = lc++;
						}
						pool_table[++pool_count] = lit_count;
						lc--;
					}
					break;
					
					
 			case 2:
 			//START,ORIGIN,PRINT,READ,STOP(with label)   START 200,ORIGIN 105,PRINT A,READ B,NEXT STOP
 					i = ad_search(tok1);
 					if(i==0 || i==2)  //START,ORIGIN
 					{
 							lc = atoi(tok2)-1;
 							fprintf(fp2,"(AD, %02d) (C, %02d)\n",i,lc+1);
 							break;
					}
					
					i = is_search(tok1); //PRINT,READ
					if(i==9 || i==10)
					{   
						j = sym_search(tok2);
						if(j==-1)
						{
							fprintf(fp2,"(IS, %02d) (S, %02d)\n",i,sym_count);
							strcpy(s[sym_count++].sym,tok2);
							break;
						}
						else
						{
							fprintf(fp2,"(IS, %02d) (S, %02d)\n",i,j);
						}
					}
					break;
					
 			case 3:
 					//ADD-DIV                 ADD AREG, B    MOVER BREG,A
 					i = is_search(tok1);
 					                           //ADD AREG, ='5'
 					if(i>=1 && i<=9)
 					{
 						if(tok3[0]=='=')
						 {
						 	j = lit_search(tok3);
						 	if(j==-1)
						 	{
						 		sprintf(temp,"(L, %02d)",lit_count);
						 		strcpy(l[lit_count++].lit,tok3);
						 		
							}
							else
							{
								sprintf(temp,"(L, %02d)",j);
							}
						 }
						 else
						 {
						 	j = sym_search(tok3);
						 	if(j==-1)
						 	{
						 		sprintf(temp,"(S, %02d)",sym_count);
								strcpy(s[sym_count++].sym,tok3);	
							}
							else
							{
								sprintf(temp,"(S, %02d)",j);
							}
						 }
						 tok2[strlen(tok2)-1] = '\0';   // removing comma
						 if(i==7)   //BC                    BC LE 5             ADD AREG, B
						 {
						 	j = cond_search(tok2);
						 }	
						 else
						 {
						 	j = reg_search(tok2);
						 }
						 fprintf(fp2,"(IS, %02d) %d %s\n",i,j,temp);      //ADD-DIV
						 break;
					}
					//DC
					if(strcmp(tok2,"DC")==0)                  //A DC 5
					{
						j = sym_search(tok1);
						if(j==-1)
						{
							strcpy(s[sym_count].sym,tok1);
							s[sym_count++].addr = lc;
						}
						else
						{
							s[j].addr = lc;
						}
						
						fprintf(fp2,"(DL, 00) (C, %02d)\n",atoi(tok3));
						break;
					}
					
					//DS
					if(strcmp(tok2,"DS")==0)           // A DS 10
					{
						j = sym_search(tok1);
						if(j==-1)
						{
							strcpy(s[sym_count].sym,tok1);
							s[sym_count++].addr = lc;
						}
						else
						{
							s[j].addr = lc;
						}
						lc = lc + atoi(tok3)-1;
						fprintf(fp2,"(DL, 01) (C, %02d)\n",atoi(tok3));
						break;
					}
 					
 					//EQU
 					j = ad_search(tok2);                   // A EQU B     (S,00) (AD,03) (S,01)
 					if(j==3)
 					{
 						i = sym_search(tok1);
						k = sym_search(tok3);
						if(i==-1)
						{
						 	strcpy(s[sym_count].sym,tok1);
							s[sym_count++].addr = s[k].addr;	
						}
						else
						{
							s[i].addr = s[k].addr;	
						}
						fprintf(fp2,"(AD, %02d)\n",j);
						lc--;
						break;	
					}
					break;
					
			case 4:
					j = sym_search(tok1); //label               NEXT ADD AREG, A
					if(j==-1)
					{
						strcpy(s[sym_count].sym,tok1);
						s[sym_count++].addr = lc;	
					}	
 					else
 					{
 						s[j].addr = lc;
					}
					//printf("++++++%s+++++++++++",tok2);
					z = sym_search(tok2);			//NEXT B AREG ,A
					
					if(z==1){
						printf("ERROR.....After Label not Writing the Symbol ..There is always Mnemonic...\n ");
						break;
					}
					i = is_search(tok2);  //ADD-DIV
					 					

 					if(i>=1 && i<=9)
 					{
 						if(tok4[0]=='=')
						 {
						 	j = lit_search(tok4);
						 	if(j==-1)
						 	{
						 		sprintf(temp,"(L, %02d)",lit_count);
						 		strcpy(l[lit_count++].lit,tok4);
						 		
							}
							else
							{
								sprintf(temp,"(L, %02d)",j);
							}
						 }
						 else
						 {
						 	j = sym_search(tok4);
						 	if(j==-1)
						 	{
						 		sprintf(temp,"(S, %02d)",sym_count);
								strcpy(s[sym_count++].sym,tok4);	
							}
							else
							{
								sprintf(temp,"(S, %02d)",j);
							}
						 }
						 tok3[strlen(tok3)-1] = '\0';
						 if(i==7)
						 {
						 	j = cond_search(tok3);
						 }	
						 else
						 {
						 	j = reg_search(tok3);
						 }
						 fprintf(fp2,"(IS, %02d) %d %s\n",i,j,temp);
						 break;
					}
					break;
					
		}
		lc++;
	}
	fclose(fp1);
	fclose(fp2);
}


void main()
{
	int ch;
	onePass();
	do{
	
	printf("Enter ur choice :\n1.Read The file :\n2.Output File .\n3.Display Symbol Table.\n4.Literral Table \n5.Pool Table \n6.Exit");
	scanf("%d",&ch);
	switch(ch)
	{
	case 1:	
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	print_file("input.txt");
	break;
	case 2:
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	print_file("output.txt");
	break;
	case 3:	
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	display_sym_table();
	break;
	case 4:
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	display_lit_table();
	break;
	case 5:
	printf("\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	display_pool_table();
	break;
	case 6:
		exit(0);
}
}while(1);

}