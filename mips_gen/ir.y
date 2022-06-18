%{
#include <stdio.h>
#include "mips.c"

int yylex(void);
void yyerror(const char *);	// see below
%}

%error-verbose
%expect 0

%union {
  char*  string;
  int    integer;
}

%token <string> ID
%token ID_W FUN FUNC VAR
%token I_ALOAD
%token I_ASTORE
%token I_LLOAD
%token I_LSTORE
%token I_GLOAD
%token I_GSTORE
%token I_ADD
%token I_SUB
%token I_MUL
%token I_DIV
%token MOD
%token I_INV
%token I_EQ
%token I_LT
%token I_NE
%token I_LE
%token NOT
%token I_COPY
%token I_VALUE
%token JUMP
%token CJUMP
%token I_CALL
%token CALL
%token I_RETURN
%token B_RETURN
%token RETURN
%token I_PRINT
%token B_PRINT
%token I_READ
%token B_READ
%token OPPAR CLPAR OPRECPAR CLRECPAR
%token <integer> INT_LIT
%token <string> INT
%token <string> BOOL
%token VOID
%token COMMA
%token COLON
%token ARROW
%token AT
%token MINUS

%token ERROR		// for signalling lexical errors

%type <integer> load
%type <integer> store
%type <integer> exp
%type <integer> single
%type <integer> read
%type <integer> copy_inv_not
%type <string>	name
%type <string>  type
%type <integer> sign

%%

program : {f_head = NULL; data_usage = 0; fun_counter = 0; main_exist = 0; printf("    .include \"tacl-io.asm\"\n");} 
		  global_declarations {save_solo();} functions {check_main();};

global_declarations : global_declaration global_declarations |
					  global_declaration
					  ;

global_declaration : OPPAR unvardef CLPAR
				   | OPPAR invardef CLPAR
				   | OPPAR fundef CLPAR
				   ;

functions : function functions 
		  | function ;					

unvardef : ID_W AT ID VAR type					{global_var_in($3, -1, 0);}
		 ;

invardef : ID_W AT ID VAR type sign INT_LIT 	{global_var_in($3, $6, $7);}
		 ;

fundef : ID_W AT ID FUN fun_type {create_func($3); args_locals = 0;} formal_arguments {args_locals = 1;} formal_arguments
	   ;

sign : MINUS	{$$ = 1;}
	 |			{$$ = 0;}
	 ;

type : INT | BOOL ;

fun_type : INT | BOOL | VOID ;

formal_arguments : OPRECPAR formal_args CLRECPAR ;

formal_args : OPPAR formal_arg CLPAR formal_args
			|
			;

formal_arg : type AT ID 		{insert_var($3);}
		   ;	

function : FUNC AT name instructions	{epilogue($3);}
		 ;

name : ID {prologue($1); ini_reg(); $$ = $1; fun_counter++;}
	 ;

instructions : instruction instructions
			 | instruction 
			 ;

instruction : ID COLON {print_label($1);} inst
			| inst
			;

inst : ID ARROW I_VALUE INT_LIT			{inst_value($1, $4);}
	 | ID ARROW copy_inv_not ID 		{inst_copy_inv_not($1, $3, $4);}
	 | ID ARROW load AT ID 				{inst_load($1, $3, $5);}
	 | AT ID ARROW store ID 			{inst_store($2, $4, $5);}
	 | ID ARROW exp ID COMMA ID 		{inst_exp($1, $3, $4, $6);}
	 | CJUMP ID COMMA ID COMMA ID 		{inst_cjump($2, $4, $6);}
	 | single ID 						{inst_single($1, $2);}
	 | ID ARROW read 					{inst_read($1, $3);}
	 | RETURN
	 | ID ARROW I_CALL AT ID COMMA {save_regs($5);} OPRECPAR args CLRECPAR {inst_icall($1);}
	 | CALL AT ID COMMA {save_regs($3);} OPRECPAR args CLRECPAR {inst_call(-1);}
	 ;

args : ID COMMA args 	{call_args($1);}
	 | ID 				{call_args($1);}
	 |
	 ;

copy_inv_not : NOT 	 	{$$ = 1;}
	         | I_INV  	{$$ = 2;}
	         | I_COPY	{$$ = 3;}
	         ;

load : I_ALOAD  {$$ = 1;}
	 | I_LLOAD  {$$ = 2;}
	 | I_GLOAD  {$$ = 3;}
	 ;

store : I_ASTORE  {$$ = 1;}
	  | I_LSTORE  {$$ = 2;}
	  | I_GSTORE  {$$ = 3;}
	  ;

exp : I_ADD 	{$$ = 1;}
	| I_SUB 	{$$ = 2;}
	| I_MUL 	{$$ = 3;}
	| I_DIV 	{$$ = 4;}
	| MOD 		{$$ = 5;}
	| I_EQ 		{$$ = 6;}
	| I_LT 		{$$ = 7;}
	| I_NE 		{$$ = 8;}
	| I_LE 		{$$ = 9;}
	;

single : JUMP		{$$ = 1;}
	   | I_RETURN	{$$ = 2;}
	   | B_RETURN	{$$ = 3;}
	   | I_PRINT	{$$ = 4;}
	   | B_PRINT	{$$ = 5;}
	   ;

read : I_READ	{$$ = 1;}
	 | B_READ	{$$ = 2;}
	 ;




%%

/* called when there is a syntax error */
void yyerror(const char *msg)
{
  fprintf(stderr, "error: %s\n", msg);
}

int main()
{
  yyparse();
}