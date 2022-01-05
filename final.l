%{
  #include "y.tab.h"
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  
  extern int countn;
  extern int token_num;
  extern int res;
  
  
  void add_token_ids(char *str);
  void add_id_dataType(char* str);
  void add_token(char* str);
  int search(char*);
  void add_token_others(char c,char* str);
  void add_token_cons(char c,char *n);
  
  
  char type[10];
  //extern int yylval;

  //extern struct ptokens_util* NEW_PTOKEN;
%}

FLOAT         ([0-9]+(".")([0-9])*)
NUMBER		  (0|[1-9][0-9]*)
ID            ([a-zA-z_][a-zA-z_0-9]*)
CHAR          ('.')
%x CMNT

%%

[\t ]           /* ignore whitespaces */ ;
"//".*      ;

for             { yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext); add_token(yytext); return FOR ;}
if              {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token(yytext);return IF ;}
else            {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);return ELSE;}
"int"   {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_id_dataType(yytext);return TYPE ;}
"unsigned int"  {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_id_dataType(yytext);return TYPE ;}
"long long"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_id_dataType(yytext);return TYPE ;}
"long"      {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_id_dataType(yytext);return TYPE;}
{NUMBER}  {
	yylval.ptoken_handle.ptoken=newPtoken(atoi(yytext),0.0,yytext,'$') ;
	//printf("Parsed num : %d",yylval.ptoken_handle.ptoken->itype);
	add_token_cons('i',yytext);return NUM;	
}
{FLOAT}  {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	yylval.ptoken_handle.ptoken->ftype=atof(yytext);
    strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	add_token_cons('f',yytext);return FLOAT;
}
{ID}    {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);res=search(yytext);if(res==-1) {add_token_ids(yytext); yylval.ptoken_handle.ptoken->index=token_num-1;}else yylval.ptoken_handle.ptoken->index=res; return ID;}
"++"    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	yylval.ptoken_handle.ptoken->itype=0;
    strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	add_token_others('o',yytext);return Overload ;
}
"--"    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	yylval.ptoken_handle.ptoken->itype=1;
    strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	add_token_others('o',yytext);return Overload ;
}
"&&"    {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('c',yytext);return ConcatAnd ;}
"||"    {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('c',yytext);return ConcatOr ;}
"+="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=0;
	add_token_others('e',yytext);return AssignOp ;
}
"-="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=1;
	add_token_others('e',yytext);return AssignOp ;
}
"/="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=2;
	add_token_others('e',yytext);return AssignOp ;
}
"*="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=3;
	add_token_others('e',yytext);return AssignOp ;
}
"&="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=4;
	add_token_others('e',yytext);return AssignOp ;
}
"^="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=5;
	add_token_others('e',yytext);return AssignOp ;
}
"|="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=6;
	add_token_others('e',yytext);return AssignOp ;
}
"<<="   {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=7;
	add_token_others('e',yytext);return AssignOp ;
}
">>="   {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=8;
	add_token_others('e',yytext);return AssignOp ;
}
"%="   {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=9;
	add_token_others('e',yytext);return AssignOp ;
}
"<="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=0;
	add_token_others('e',yytext);return RelationalCompare ;
}
">="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=1;
	add_token_others('e',yytext);return RelationalCompare ;
}
"<"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=2;
	add_token_others('r',yytext);return RelationalCompare ;
}
">"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=3;
	add_token_others('r',yytext);return RelationalCompare ;
}
"!="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=0;
	add_token_others('r',yytext);return RelationalEquals ;
}
"=="    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=1;
	add_token_others('r',yytext);return RelationalEquals ;
}
"="     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('e',yytext);return Assign;}
"*"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=0;
	add_token_others('a',yytext);return OperatorPrecMul ;
}
"/"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=1;
	add_token_others('a',yytext);return OperatorPrecMul ;
}
"%"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=2;
	add_token_others('a',yytext);return OperatorPrecMul ;
}
"+"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=0;
	add_token_others('a',yytext);return OperatorPrecAdd ;
}
"-"     {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=1;
	add_token_others('a',yytext);return OperatorPrecAdd ;
}
">>"    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=0;
	add_token_others('t',yytext);return OperatorShift ;
}
"<<"    {
	yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;
	strcpy(yylval.ptoken_handle.ptoken->str,yytext);
	yylval.ptoken_handle.ptoken->itype=1;
	add_token_others('t',yytext);return OperatorShift ;
}
"&"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('t',yytext);return OperatorAnd ;}
"|"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('t',yytext);return OperatorOr ;}
"^"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('t',yytext);return OperatorOr ;}
"!"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('c',yytext);return ConcatNot ;}
"~"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('c',yytext);return OperatorNot ;}
";"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('p',yytext);return SCOLON ;}
"("     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('p',yytext);return OpenBracket ;}
")"     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('p',yytext);return CloseBracket ;}
","     {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;strcpy(yylval.ptoken_handle.ptoken->str,yytext);add_token_others('p',yytext);return COMMA ;}

"/*"    { BEGIN CMNT;}
<CMNT>\n {yylineno++;}
<CMNT>"*/" {BEGIN INITIAL;}

 
.               {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;add_token(yytext);return yytext[0];}
 
\n              {yylval.ptoken_handle.ptoken=newPtoken(0,0.0,"",'$') ;yylval.ptoken_handle.ptoken->itype = yylineno;yylineno++; countn++;}
 
\n\n            {return 0;}
 
%%

int  search(char *str_token)
{
	int i;
	for(i=token_num-1;i>=0;i--)
	{
		if(strcmp(symbolTable[i].token_name,str_token)==0)
		{
			return i;
			break;
		}
	
	}
	return -1;
}

void add_token_ids(char *str){				
    symbolTable[token_num].token_name=strdup(str);
    symbolTable[token_num].token_dataType=strdup(type);
    symbolTable[token_num].token_lineNum = countn;
    symbolTable[token_num].token_type=strdup("IDENTIFIER");
    symbolTable[token_num].token_val=strdup("N/A");
    token_num++;
}


void add_token_cons(char c,char *n)
{
	if(c=='i')
	{
			symbolTable[token_num].token_name=strdup(n);
			symbolTable[token_num].token_dataType="int";
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("constant");
			token_num++;
	}
	else if(c=='f')
	{
			symbolTable[token_num].token_name=strdup(n);
			symbolTable[token_num].token_dataType="float";
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("constant");
			token_num++;
	}
	else if(c=='c')
	{
			symbolTable[token_num].token_name=strdup(n);
			symbolTable[token_num].token_dataType="char";
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("constant");
			token_num++;
	}
}

void add_token_others(char c,char* str)
{
	int res=0;
	if(res==0){
		if(c=='h')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Header");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
		else if(c=='p')
		{	
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Punctuation");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
		else if(c=='a')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Arithmetic Op");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
		else if(c=='r')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Rel Op\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
		else if(c=='k')
		{
						
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("KEYWORD\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
		else if(c=='n')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("int");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("NUMBER\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
	    else if(c=='f')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("FUNCTION\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
        else if(c=='b')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Bool op\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
        else if(c=='c')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Concat op\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}
        else if(c=='t')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Bit op\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}

         else if(c=='o')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Overload op\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}  

         else if(c=='e')
		{
			symbolTable[token_num].token_name=strdup(str);
			symbolTable[token_num].token_dataType=strdup("N/A");
			symbolTable[token_num].token_lineNum = countn;
			symbolTable[token_num].token_type=strdup("Assign op\t");
            symbolTable[token_num].token_val=strdup("N/A");
			token_num++;
		}   
	}
}


void add_id_dataType(char* str){
	int res=0;
	strcpy(type,str);
	if(res==0){		
		symbolTable[token_num].token_name=strdup(str);
		symbolTable[token_num].token_dataType=strdup("N/A");
		symbolTable[token_num].token_lineNum = countn;
		symbolTable[token_num].token_type=strdup("KEYWORD\t");
        symbolTable[token_num].token_val=strdup("N/A");
		token_num++;
	}	
}

void add_token(char* str){
	int res=0;
	if(res==0){		
		symbolTable[token_num].token_name=strdup(str);
		symbolTable[token_num].token_dataType=strdup("N/A");
		symbolTable[token_num].token_lineNum = countn;
		symbolTable[token_num].token_type=strdup("KEYWORD-Type\t");
        symbolTable[token_num].token_val=strdup("N/A");
		token_num++;
	}
}



