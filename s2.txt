#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define max 20

char buf[max],tok1[max],tok2[max],tok3[max],tok4[max],tok5[max],temp[80],s8[max],s9[max],s10[max],str[80],str1[80],str2[80];
int lc=-1,token_count=0,i;
FILE *f1,*f2,*f3,*f4,*f5;

void twopass()
{
	lc=0;
	
	f1=fopen("output.txt","r");
	f2=fopen("xyze.txt","w");
	
	while(fgets(buf,80,f1)!=NULL)
	{
		token_count=sscanf(buf,"%s %s %s %s %s",tok1,tok2,tok3,tok4,tok5);
		tok1[strlen(tok1)-1]='\0';
		tok2[strlen(tok2)-1]='\0';
		tok4[strlen(tok4)-1]='\0';
		tok5[strlen(tok5)-1]='\0';
		
		switch(token_count)
		{
			case 2: 
				if(strcmp(tok1+1,"IS")==0)
				{
					fprintf(f2,"%d) + 00 0 000\n",lc);
					
				}
				break;
			case 4:
				tok3[strlen(tok3)-1]='\0';
				if(strcmp(tok1+1,"AD")==0)
				{
					if(strcmp(tok3+1,"C")==0)
					{
						lc=atoi(tok4)-1;
					}
					if(strcmp(tok3+1,"L")==0)
					{
						fprintf(f2,"%d) + 00 0 %03d\n",lc,atoi(tok4));
					}
				}
				
				//READ A,PRINT B
				
				else if(strcmp(tok1+1,"IS")==0)
				{
					f3=fopen("sym.txt","r");
					while(!feof(f3))
					{
						if(fgets(temp,80,f3)!=NULL)
						{
							sscanf(temp,"%s %s %s",s8,s9,s10);
							if(strcmp(tok4,s8)==0)
							{
								fprintf(f2,"%d) + %02d 0 %03d\n",lc,atoi(tok2),atoi(s10));
							}	
						}	
					}
					fclose(f3);
					
				}
				
				else if(strcmp(tok1+1,"DL")==0)
				{
					if(atoi(tok2)==1)//DS
					{
						for(i=0;i<atoi(tok4);i++)
						{
							fprintf(f2,"%d)\n",lc++);
						}
						lc--;
					}
					else if(atoi(tok2)==0)
					{
						fprintf(f2,"%d) + 00 0 %03d\n",lc,atoi(tok4));
					}
				}
				break;
				
			case 5: //(IS, 02) 1 (S, 02) || (IS,03) 2 (L,02) 
				if(tok4[1]=='S')
				{
					f4=fopen("sym.txt","r");
					while(!feof(f4))
					{
						if(fgets(temp,80,f4)!=NULL)
						{
							sscanf(temp,"%s %s %s",s8,s9,s10);
							if(strcmp(tok5,s8)==0)
							{
								//printf("%02d %d %03d",lc,atoi(tok2),atoi(tok3),atoi(s10));
								fprintf(f2,"%d) +%02d %d %03d\n",lc,atoi(tok2),atoi(tok3),atoi(s10));
								break;
							}
						}
					}
					fclose(f4);
				}
				
				else if(tok4[1]=='L')
				{
					f5=fopen("lit.txt","r");
					while(!feof(f5))
					{
						if(fgets(str,80,f5)!=NULL)
						{
							sscanf(str,"%s %s %s",s8,s9,s10);
							if(strcmp(tok5,s8)==0)
							{
								fprintf(f2,"%d) +%02d %d %03d\n",lc,atoi(tok2),atoi(tok3),atoi(s10));
								break;
							}
						}
					}
					fclose(f5);
				}
				break;
				
		
				
		}
	
		lc++;
	}
	fclose(f1);
	fclose(f2);
}

int main()
{
	printf("\nTwo PAss:");
	twopass();
	return 0;
}
