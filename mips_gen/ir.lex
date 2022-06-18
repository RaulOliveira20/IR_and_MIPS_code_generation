%{
#include "ir.tab.h"
%}

/* avoid `input' and `yyunput' not used warnings */
%option noinput
%option nounput

%%

fun			return FUN;

id 			return ID_W;

function	return FUNC;

var			return VAR;

int			return INT;

bool 		return BOOL;

void		return VOID;

i_aload		return I_ALOAD;
i_astore	return I_ASTORE;

i_lload		return I_LLOAD;
i_lstore	return I_LSTORE;

i_gload		return I_GLOAD;
i_gstore	return I_GSTORE;

i_add		return I_ADD;
i_sub		return I_SUB;
i_mul		return I_MUL;
i_div		return I_DIV;
i_inv		return I_INV;
mod			return MOD;

i_eq		return I_EQ;
i_lt 		return I_LT;
i_ne 		return I_NE;
i_le 		return I_LE;
not 		return NOT;

i_copy		return I_COPY;
i_value		return I_VALUE;

jump 		return JUMP;
cjump 		return CJUMP;

i_call 		return I_CALL;
call 		return CALL;

i_return	return I_RETURN;
b_return    return B_RETURN;
return		return RETURN;

i_print 	return I_PRINT;
b_print 	return B_PRINT;

i_read		return I_READ;
b_read  	return B_READ;

,			return COMMA;
:			return COLON;
"("			return OPPAR;
")"			return CLPAR;
"["			return OPRECPAR;
"]"			return CLRECPAR;

\-			return MINUS;
\<-			return ARROW;
\@			return AT;


[_a-zA-Z][_a-zA-Z0-9]*	{
							yylval.string = strdup(yytext);

			 	 			return ID;
						}


[0-9]+	{
			yylval.integer = atoi(yytext);

	  		return INT_LIT;
		}

#.*		; /* ignore comments */

[ \t\n]+	; /* and whitespace */

.		{
		  fprintf(stderr, "unrecognised character: `%c'\n", *yytext);

		  return ERROR;
		}
