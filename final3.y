%{
  #include<stdio.h>
  #include<stdlib.h>
  #include<ctype.h>
  #include<string.h>
  #define MAX_Q_SIZE 100
  int yylex(void);
  int yywrap();
  int yyerror(const char *s);
  int success = 1;


// ###############  Symbol table Purpose ############

  int res=-1; // For declaration and redeclaration purposes
  int token_num=0; // contains the value of no.of elements in symbol table
  int countn=1; // for line count

  struct parsed_token{
    char* token_name;
    char* token_type;
    char* token_dataType;
    int token_lineNum;
    char* token_val;
	} symbolTable[200];

  void print();
  // char count=0;
  char type[10]; // Used normally to store type of id (or) name of keyword
  
  char token_handle[25];
  
  /* To print the elements in the symbol table */
  void print_table();
  
  void reverse(char str[], int length);
  char* itoa(int num, char* str, int base);

  // ##############  Parsing purpose ###########
  
  struct ptokens_util{
    int itype;
    float ftype;
    char str[30];
    char ctype;
    int index;
  };
  /* To create a new ptokens_util with the specified parameters passed */
  struct ptokens_util* newPtoken(int x,float f,char* str,char c);

//  ###################   AST purpose  ######################

  struct treeNode{
  	int child;
  	char NT[20];
  	struct treeNode* children[10];
    struct ptokens_util* ptoken;
  };


  struct treeNode* root;
  struct treeNode* cppp[5];
  struct treeNode* newNode(int c,char* name,struct treeNode* child[]);
  struct treeNode* newLeafNode(char* name);
  void printAST(struct treeNode*);


  // ##################       ICG purpose          #########################
  
  // Adding vars for ICG

  char st[100][10]; //string array
  int temp_val=0;
  char temp_count[20];
  int top=-1;
  char temp[20]="t";

  int label_num=0;
  int label[20];
  int ltop=0;

  void push(char* a)
  {
    //printf("%s\n",yytext);
    strcpy(st[++top],a);
  }
  void codegen()
  {
   strcpy(temp,"t");
   itoa(temp_val,temp_count,10);
   strcat(temp,temp_count);
   printf("%s= %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
   top-=2;
   strcpy(st[top],temp);
   temp_val++;
  }
  void code_assign()
  {
    printf("%s=%s\n",st[top-2],st[top]);
    top-=2;
 
  }
  
 //handles !b;~b,++b,--b
  void codegen_u(int a)
  {
    strcpy(temp,"t");
    itoa(temp_val,temp_count,10);
    strcat(temp,temp_count);
    if(a==0)
    printf("%s=!%s\n",temp,st[top]);
    else if(a==1)
    printf("%s=~%s\n",temp,st[top]);
    else if(a==2)
      printf("%s=++%s\n",temp,st[top]);
    else 
      printf("%s=--%s\n",temp,st[top]);
     top--;
      strcpy(st[top],temp);
      temp_val++;
  }
  
  //handles b++,b--
  void codegen_o(char* id,int a)
  {
    strcpy(temp,"t");
    itoa(temp_val,temp_count,10);
    strcat(temp,temp_count);
    if(a==0)
    printf("%s=%s++\n",temp,id);
    else
    printf("%s=%s--\n",temp,id);
    top--;
    strcpy(st[top],temp);
    temp_val++;
  }

  //to handle += ,-=,*=
  void code_assign_and()
  {
    printf("%s=%s\n",st[top-1],st[top]);
    top-=1;
  }
  
  void if1()
  {
    label_num++;
    strcpy(temp,"t");
    itoa(temp_val,temp_count,10);
    strcat(temp,temp_count);
    printf("\n%s = not %s\n",temp,st[top]);
    printf("if %s goto L%d\n",temp,label_num);
    temp_val++;
    label[++ltop]=label_num;
  }
  
  void if2()
  {
   label_num++;
   //printf("\n goto L%d\n",label_num);
   printf("L%d: \n",label[ltop--]);
   label[++ltop]=label_num;
  }
  void if3()
  {
   printf("\nL%d:\n",label[ltop--]);
  }
  
  void for1()
  {
    label_num++;
    label[++ltop]=label_num;
    printf("\nL%d:\n",label_num);
  }
  
  void for2()
  {
    label_num++;
    strcpy(temp,"t");
    itoa(temp_val,temp_count,10);
    strcat(temp,temp_count);
    printf("\n%s = not %s\n",temp,st[top--]);
    printf("if %s goto L%d\n",temp,label_num);
    temp_val++;
    label[++ltop]=label_num;
    label_num++;
    printf("goto L%d\n",label_num);
    label[++ltop]=label_num;
    label_num++;
    printf("L%d:\n",label_num);
    label[++ltop]=label_num; 
  }
  
  void for3()
  {
    printf("\ngoto L%d\n",label[ltop-3]);
    printf("L%d:\n",label[ltop-1]);
  }
  
  void for4()
  {
    printf("\ngoto L%d\n",label[ltop]);
    printf("L%d:\n",label[ltop-2]);
    ltop-=4;
  }


// ################  AST Purpose  #######################


	struct treeNode** createQueue(int*, int*);
	void enQueue(struct treeNode**, int*, struct treeNode*);
	struct treeNode* deQueue(struct treeNode**, int*);
	 
	/* Given a tree, print its nodes in level order
	   using array for implementing queue */
	void printLevelOrder(struct treeNode* root)
	{
		int rear, front;
		struct treeNode** queue = createQueue(&front, &rear);
		struct treeNode* temp_node = root;
		enQueue(queue, &rear, newLeafNode("$"));
		int prev=0;
		while (temp_node) {
			if(temp_node->NT[0]=='$') printf("\n");
		    else{
		    	prev=0; 
		    	printf("%s ", temp_node->NT);
		    }
		    for(int i=0;i<temp_node->child;i++)if(temp_node->children[i]!=NULL)enQueue(queue, &rear, temp_node->children[i]);
		    if(prev) break;
		    if(temp_node->NT[0]=='$'){ 
		    	enQueue(queue, &rear, newLeafNode("$"));
		    	prev=1;
		    }
		    temp_node = deQueue(queue, &front);
		}
	}
	 
	/*UTILITY FUNCTIONS*/
	struct treeNode** createQueue(int* front, int* rear)
	{
		struct treeNode** queue = (struct treeNode**)malloc(
		    sizeof(struct treeNode*) * MAX_Q_SIZE);
	 
		*front = *rear = 0;
		return queue;
	}
	 
	void enQueue(struct treeNode** queue, int* rear,
		         struct treeNode* new_node)
	{
		queue[*rear] = new_node;
		(*rear)++;
	}
	 
	struct treeNode* deQueue(struct treeNode** queue, int* front)
	{
		(*front)++;
		return queue[*front - 1];
	}

// ################################################

%}
 
%union{
  struct treeNode* tNode;
  struct ptokens{struct ptokens_util* ptoken;} ptoken_handle;
}

%type<tNode>  BODY TEMP INIT UPDATE DECL FOR_CONSTRUCT IF_CONSTRUCT CONST NOT E A B C D F G H I J K L M DEF INIT1 DECL_UTIL UPDATE_TEMP UPDATE_UTIL COND_UTIL CHECK INIT_UTIL


%token<ptoken_handle> NUM AssignOp Overload RelationalCompare RelationalEquals OperatorPrecMul OperatorPrecAdd OperatorShift FLOAT ID FOR TYPE ConcatAnd ConcatOr OperatorAnd OperatorXor OperatorOr Assign OpenBracket CloseBracket SCOLON COMMA OperatorNot ConcatNot IF ELSE CHAR
 
 
%left Overload
%left ConcatAnd
%left ConcatOr
%right AssignOp Assign
%left RelationalCompare
%left RelationalEquals
%left OperatorPrecAdd
%left OperatorShift
%left OperatorAnd
%left OperatorXor
%left OperatorOr
%left OperatorPrecMul
%left COMMA
%left SCOLON
%right ConcatNot OperatorNot
%nonassoc OpenBracket CloseBracket
%nonassoc IFX
%nonassoc ELSE
%start BODY


%%

BODY      : BODY TEMP{struct treeNode* child[2]={$1,$2};$$=newNode(2,"BODY",child);root=$$;}
          |	{$$=NULL;}
          ;
TEMP      : INIT{$$=$1;}
          | UPDATE SCOLON{$$=$1;}
          | DECL{$$=$1;}
          | FOR_CONSTRUCT{$$=$1;}
          | IF_CONSTRUCT{$$=$1;}
          ;


CONST     : NUM    {$$=newLeafNode("NUM");$$->ptoken=$1.ptoken;push($1.ptoken->str);}
          //| CHAR   {$$=newLeafNode("CHAR");$$->ptoken=$1.ptoken;push($1.ptoken->str);}
          | ID  CHECK_DECLARATION   {$$=newLeafNode("ID");$$->ptoken=$1.ptoken; $$->ptoken->itype=atoi(symbolTable[$1.ptoken->index].token_val);push($1.ptoken->str);}
          //| FLOAT  {$$=newLeafNode("FLOAT");$$->ptoken=$1.ptoken;push($1.ptoken->str);}
          ;


NOT : ConcatNot {$$=newLeafNode("!");$$->ptoken=$1.ptoken;}
    | OperatorNot {$$=newLeafNode("~");$$->ptoken=$1.ptoken;} ; 
    

E : E ConcatOr {strcpy(st[++top],$2.ptoken->str);} A {struct treeNode* child[2]={$1,$4};$$=newNode(2,"||",child);$$->ptoken->itype = ($1->ptoken->itype || $4->ptoken->itype);codegen();strcpy($$->ptoken->str,st[top]);}
  | A{$$=$1;};
A : A ConcatAnd {strcpy(st[++top],$2.ptoken->str);} B {struct treeNode* child[2]={$1,$4};$$=newNode(2,"&&",child); $$->ptoken->itype = ($1->ptoken->itype && $4->ptoken->itype);codegen();strcpy($$->ptoken->str,st[top]);}
  | B{$$=$1;};
B : B OperatorOr {strcpy(st[++top],$2.ptoken->str);} C {struct treeNode* child[2]={$1,$4};$$=newNode(2,"|",child);$$->ptoken->itype = ($1->ptoken->itype | $4->ptoken->itype);codegen(); strcpy($$->ptoken->str,st[top]);}
  | C{$$=$1;};
C : C OperatorXor {strcpy(st[++top],$2.ptoken->str);} D {struct treeNode* child[2]={$1,$4};$$=newNode(2,"^",child);$$->ptoken->itype = ($1->ptoken->itype ^ $4->ptoken->itype);codegen(); strcpy($$->ptoken->str,st[top]);}
  | D{$$=$1;};
D : D OperatorAnd {strcpy(st[++top],$2.ptoken->str);} F {struct treeNode* child[2]={$1,$4};$$=newNode(2,"&",child);$$->ptoken->itype = ($1->ptoken->itype & $4->ptoken->itype);codegen(); strcpy($$->ptoken->str,st[top]);}
  | F{$$=$1;};
F : F RelationalEquals {strcpy(st[++top],$2.ptoken->str);} G  {if($2.ptoken->itype==0){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"!=",child);$$->ptoken->itype=($1->ptoken->itype != $4->ptoken->itype);
                            }else{
  struct treeNode* child[2]={$1,$4};$$=newNode(2,"==",child);$$->ptoken->itype=($1->ptoken->itype==$4->ptoken->itype);
                            }
                            codegen();strcpy($$->ptoken->str,st[top]);
                          }
  | G{$$=$1;};
G : G RelationalCompare {strcpy(st[++top],$2.ptoken->str);} H {if($2.ptoken->itype==0){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"<=",child);$$->ptoken->itype=($1->ptoken->itype <= $4->ptoken->itype);
                            }else if($2.ptoken->itype==1){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,">=",child);$$->ptoken->itype=($1->ptoken->itype>=$4->ptoken->itype);
                            }else if($2.ptoken->itype==2){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"<",child);$$->ptoken->itype=($1->ptoken->itype < $4->ptoken->itype);
                            }else{
	struct treeNode* child[2]={$1,$4};$$=newNode(2,">",child);$$->ptoken->itype=($1->ptoken->itype > $4->ptoken->itype);
                            }
                            codegen(); strcpy($$->ptoken->str,st[top]);
                          }
  | H{$$=$1;};
H : H OperatorShift {strcpy(st[++top],$2.ptoken->str);} I {if($2.ptoken->itype==0){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,">>",child);$$->ptoken->itype=(($1->ptoken->itype) >> ($4->ptoken->itype));
                        }else{
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"<<",child);$$->ptoken->itype=($1->ptoken->itype << $4->ptoken->itype);
                        }
                        codegen();strcpy($$->ptoken->str,st[top]);
                      }
  | I{$$=$1;};
I : I OperatorPrecAdd {strcpy(st[++top],$2.ptoken->str);} J {if($2.ptoken->itype==0){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"+",child);$$->ptoken->itype=($1->ptoken->itype + $4->ptoken->itype);
                          }else{
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"-",child);$$->ptoken->itype=($1->ptoken->itype - $4->ptoken->itype);
                          }
                          codegen();strcpy($$->ptoken->str,st[top]);
                        }
  | J{$$=$1;};
J : J OperatorPrecMul {strcpy(st[++top],$2.ptoken->str);} K {if($2.ptoken->itype==0){
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"*",child);$$->ptoken->itype=($1->ptoken->itype * $4->ptoken->itype);
                        }else if($2.ptoken->itype==1){
                        	struct treeNode* child[2]={$1,$4};$$=newNode(2,"/",child);
                          if($4->ptoken->itype!=0){
	$$->ptoken->itype=($1->ptoken->itype / $4->ptoken->itype);
                          }else{
                            yyerror("division with zero");
                          }
                        }else{
	struct treeNode* child[2]={$1,$4};$$=newNode(2,"%",child);$$->ptoken->itype=($1->ptoken->itype % $4->ptoken->itype);
                        }
                        codegen();strcpy($$->ptoken->str,st[top]);
                      }
  | K{$$=$1;};
K : NOT {strcpy(st[++top],$1->ptoken->str);} L            {if($1->ptoken->itype==0){
	struct treeNode* child[1]={$3};$$=newNode(1,"!",child);$$->ptoken->itype=(! $3->ptoken->itype);
  codegen_u(0);
                        }else{
	struct treeNode* child[1]={$3};$$=newNode(1,"~",child);$$->ptoken->itype=(~ $3->ptoken->itype);
  codegen_u(1);
                        }
                      }
  | Overload {strcpy(st[++top],$1.ptoken->str);} L        {{strcpy(st[++top],$3->ptoken->str);}if($1.ptoken->itype==0){
	struct treeNode* child[1]={$3};$$=newNode(1,"++",child);$3->ptoken->itype=($3->ptoken->itype + 1);
  codegen_u(2);
                        }else{
	struct treeNode* child[1]={$3};$$=newNode(1,"--",child);$3->ptoken->itype=($3->ptoken->itype - 1);
  codegen_u(3);
                        }
                      }
  | L{$$=$1;};
L : M Overload         {if($2.ptoken->itype==0){
	struct treeNode* child[1]={$1};$$=newNode(1,"++",child);$1->ptoken->itype=($1->ptoken->itype + 1);
  codegen_o($1->ptoken->str,0);
                        }else{
	struct treeNode* child[1]={$1};$$=newNode(1,"--",child);$1->ptoken->itype=($1->ptoken->itype - 1);
  codegen_o($1->ptoken->str,1);
                        }
                       }
  | M{$$=$1;};
M : OpenBracket E CloseBracket {$$ = $2;}  
  | CONST {char* str;$$=newLeafNode(itoa($1->ptoken->itype,str,10));$$->ptoken = $1->ptoken;}
  ;
FOR_CONSTRUCT : FOR OpenBracket INIT1 FOR1 CHECK FOR2 SCOLON UPDATE FOR3 CloseBracket DEF FOR4{struct treeNode* child[4]={$3,$5,$8,$11};$$=newNode(4,"for",child);}
              ;            
IF_CONSTRUCT : IF OpenBracket COND_UTIL CloseBracket IF1 DEF %prec IFX IF2{struct treeNode* child[1]={$6};struct treeNode* temp[1]={newNode(1,"true",child)};$$=newNode(1,"if",temp);}
             | IF OpenBracket COND_UTIL CloseBracket IF1 DEF IF2 ELSE DEF IF3{struct treeNode* child1[1]={$6};struct treeNode* temp1=newNode(1,"true",child1);struct treeNode* child2[1]={$9};struct treeNode* temp2=newNode(1,"false",child2);struct treeNode* temp[2]={temp1,temp2};$$=newNode(2,"if",temp);}
             ;



DEF       : '{' BODY '}'{$$=$2;}
          | TEMP{$$=$1;}
          ;
 
 

INIT1 : INIT{$$=$1;}
    | SCOLON{$$=NULL;}
    ;
    
IF1 :  {if1();};
IF2 : {if2();};
IF3 : {if3();};
FOR1 : {for1();};
FOR2 : {for2();};
FOR3 : {for3();};
FOR4 : {for4();};



INIT : INIT_UTIL SCOLON {$$=$1;};

INIT_UTIL : ID {strcpy(st[++top],$1.ptoken->str);} CHECK_DECLARATION Assign {strcpy(st[++top],$4.ptoken->str);} E {$1.ptoken->itype=$6->ptoken->itype;$1.ptoken->ftype=$6->ptoken->ftype;symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);code_assign();struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp1,$6};struct treeNode* assign_child=newNode(2,"=",child1);struct treeNode* child2[1]={assign_child};$$=newNode(1,"INIT_UTIL",child2);}
          | INIT_UTIL COMMA ID {strcpy(st[++top],$3.ptoken->str);} CHECK_DECLARATION Assign {strcpy(st[++top],$6.ptoken->str);} E{$3.ptoken->itype=$8->ptoken->itype;$3.ptoken->ftype=$8->ptoken->ftype;symbolTable[$3.ptoken->index].token_val=itoa($3.ptoken->itype,symbolTable[$3.ptoken->index].token_val,10);code_assign();struct treeNode* temp1=newLeafNode($3.ptoken->str);struct treeNode* child1[2]={temp1,$8};struct treeNode* assign_child=newNode(2,"=",child1);struct treeNode* child2[2]={$1,assign_child};$$=newNode(2,"INIT_UTIL",child2);}
          ; 


CHECK_DECLARATION : {if(res==-1) yyerror("Identifier not declared");} ;


//////////////////////////////////////
          
DECL : TYPE DECL_UTIL SCOLON{struct treeNode* child[1]={$2};$$=newNode(1,"DECL",child);}
     ;
DECL_UTIL : ID {push($1.ptoken->str);} CHECK_REDECLARATION
          | DECL_UTIL COMMA ID {push($3.ptoken->str);} CHECK_REDECLARATION
          | ID {strcpy(st[++top],$1.ptoken->str);} CHECK_REDECLARATION Assign {strcpy(st[++top],$4.ptoken->str);} E {$1.ptoken->itype=$6->ptoken->itype;$1.ptoken->ftype=$6->ptoken->ftype;symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);code_assign();struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp1,$6};struct treeNode* assign_child=newNode(2,"=",child1);struct treeNode* child2[1]={assign_child};$$=newNode(1,"DECL_UTIL",child2);}
          | DECL_UTIL COMMA ID {strcpy(st[++top],$3.ptoken->str);} CHECK_REDECLARATION Assign {strcpy(st[++top],$6.ptoken->str);} E{$3.ptoken->itype=$8->ptoken->itype;$3.ptoken->ftype=$8->ptoken->ftype;symbolTable[$3.ptoken->index].token_val=itoa($3.ptoken->itype,symbolTable[$3.ptoken->index].token_val,10);code_assign();struct treeNode* temp1=newLeafNode($3.ptoken->str);struct treeNode* child1[2]={temp1,$8};struct treeNode* assign_child=newNode(2,"=",child1);struct treeNode* child2[2]={$1,assign_child};$$=newNode(2,"DECL_UTIL",child2);}
          ;

CHECK_REDECLARATION : {if(res!=-1) yyerror("Redeclaration of identifier");} ;

///////////////////////////////////////////////////////////
 
UPDATE : UPDATE_TEMP{$$=$1;}
       | UPDATE_UTIL COMMA UPDATE_TEMP{struct treeNode* child[2]={$1,$3};$$=newNode(2,"UPDATE",child);}
       | {$$=NULL;}
       ;
UPDATE_TEMP: E {$$=$1;}
           | ID {push($1.ptoken->str);push($1.ptoken->str);if(res==-1) yyerror("Identifier not declared");} AssignOp {char c =$3.ptoken->str[0];char *ptr = malloc(2*sizeof(char));ptr[0] = c;ptr[1] = '\0';strcpy(st[++top],ptr);free(ptr);} E {
             if($3.ptoken->itype==0){
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) +$5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"+",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             }else if($3.ptoken->itype==1){
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) - $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"-",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             }else if($3.ptoken->itype==2){
             	/* added divison with 0 condition */
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"/",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	if($5->ptoken->itype!=0){
             		$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) / $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             	}else{
             		yyerror("Semantic phase checking - Divison with zero");
             	}
             }else if($3.ptoken->itype==3){
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"*",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) * $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }else if($3.ptoken->itype==4){
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"&",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) & $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }else if($3.ptoken->itype==5){
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"^",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) ^ $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }else if($3.ptoken->itype==6){
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"|",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) | $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }else if($3.ptoken->itype==7){
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"<<",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) << $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }else if($3.ptoken->itype==8){
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,">>",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) >> $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }else{
             	/* $3 type should be a int type */
             	struct treeNode* temp1=newLeafNode($1.ptoken->str);struct treeNode* child[2]={temp1,$5};struct treeNode* temp2=newNode(2,"%",child);struct treeNode* temp3=newLeafNode($1.ptoken->str);struct treeNode* child1[2]={temp3,temp2};$$=newNode(2,"=",child1);
             	$1.ptoken->itype=(atoi(symbolTable[$1.ptoken->index].token_val) % $5->ptoken->itype);symbolTable[$1.ptoken->index].token_val=itoa($1.ptoken->itype,symbolTable[$1.ptoken->index].token_val,10);
             }
             codegen();
             code_assign_and();
           }
           ;
UPDATE_UTIL : UPDATE_TEMP {$$=$1;}
            | UPDATE_UTIL COMMA UPDATE_TEMP{struct treeNode* child[2]={$1,$3};$$=newNode(2,"UPDATE",child);}
            ;
 
COND_UTIL : COND_UTIL COMMA E{$$=$3;}
          | E{$$=$1;}
          ;
CHECK : E{struct treeNode* child[1]={$1};$$=newNode(1,"CHECK",child);}
      | COND_UTIL COMMA E{struct treeNode* child[1]={$3};$$=newNode(1,"CHECK",child);}
      |	{struct treeNode* child[1]={newLeafNode("1")};$$=newNode(1,"CHECK",child);}
      ;
 
 
 
%%
#include "lex.yy.c"
int main (void)
{       
    // printf("#####################  Intermediate Code Generation #####################\n\n");
    yyparse();
    if(success){
      printf("\n ***********  Input parsed succesfully  *****************\n");
      printf("\n\n###################   Postorder traversal of AST  ############################ \n\n");
      printAST(root);printf("\n\n");
      printf("\n###################   Level order traversal of AST  ############################ \n\n");
      printLevelOrder(root);printf("\n\n");
      printf(" ######################   Lexical analysis - Symbol table   ######################\n\n");
      print_table();
      printf("\n\n");
    }
    return 0;
}
 
int yyerror(const char *msg)
{
  printf("\n\n  !!!!!!!!!!!!!!  Parsing Failed !!!!!!!!!!!!!! \n\nLine Number: %d %s\n\n",countn,msg);
  success = 0;
  return 0;
}

void print(){
    printf("\n#####################  Intermediate Code Generation #####################\n\n");
}


void print_table(){
   printf("Name\t  type\t     DataType  LineNum\n");
   int i=0;
   for(i=0;i<token_num;i++){
     printf("%s\t%s\t%s\t%d\n",symbolTable[i].token_name,symbolTable[i].token_type,symbolTable[i].token_dataType,symbolTable[i].token_lineNum);
    }
}


struct ptokens_util* newPtoken(int x,float f,char* str,char c){
	  struct ptokens_util* newPtoken1=(struct ptokens_util*)malloc(sizeof(struct ptokens_util));
	  newPtoken1->itype=x;
	  newPtoken1->ftype=f;
	  strcpy(newPtoken1->str,str);
	  newPtoken1->ctype=c;
    newPtoken1->index=-1; /* using -1 to get error if know if value is updated or not in lex phase, thinking only to use for IDs */
	  return newPtoken1;
  }


struct treeNode* newNode(int c,char* name,struct treeNode* child[]){
  	struct treeNode* newTreeNode=(struct treeNode*)malloc(sizeof(struct treeNode));
  	newTreeNode->child=c;
  	strcpy(newTreeNode->NT,name);
  	newTreeNode->ptoken=newPtoken(0,0.0,"",'$');
  	int i;
  	for(i=0;i<c;i++) newTreeNode->children[i]=child[i];
  	return newTreeNode;
  }

  struct treeNode* newLeafNode(char* name){
  	struct treeNode* newTreeNode=(struct treeNode*)malloc(sizeof(struct treeNode));
  	newTreeNode->child=0;
  	newTreeNode->ptoken=newPtoken(0,0.0,"",'$');
  	strcpy(newTreeNode->NT,name);
  	return newTreeNode;
  }


  void reverse(char str[], int length)
{
    int start = 0;
    int end = length -1;
    while (start < end)
    {
        char c=*(str+start);
        *(str+start)= *(str+end);
        *(str+end)=c;
        start++;
        end--;
    }
}
 

char* itoa(int num, char* str, int base)
{
    int i = 0;
    int isNegative = 0;
    if (num == 0)
    {
        str[i++] = '0';
        str[i] = '\0';
        return str;
    }
 
    if (num < 0 && base == 10)
    {
        isNegative = 1;
        num = -num;
    }

    while (num != 0)
    {
        int rem = num % base;
        str[i++] = (rem > 9)? (rem-10) + 'a' : rem + '0';
        num = num/base;
    }
 
    if (isNegative)
        str[i++] = '-';
 
    str[i] = '\0';
    reverse(str, i);
 
    return str;
}


void printAST(struct treeNode* root){
	if(root!=NULL){
		for(int i=0;i<root->child;i++){
			printAST(root->children[i]);
		}
		printf("%s ",root->NT);
	}
}
