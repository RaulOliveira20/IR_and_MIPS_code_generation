#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ORI_MAX 65536

//estrutura onde se guarda as funcoes, com os seus respetivos argumentos e variaveis locais
struct fun_info
{
	char name[50];
	int num_args;
	int num_locals;
	struct var *args;
	struct var *locals;
	struct fun_info *next;
};

//estrutura dos argumentos e variaveis locais
struct var
{
	char id[50];
	struct var *next;
};

struct fun_info *f_head;	//head da lista ligada de funcoes
struct fun_info *f_tail;	//tail da lista ligada de funcoes

int data_usage;		//ve se ".data" ja foi escrito
int args_locals;	//ver o q esta a guardar: 0 para args, 1 para locals
int fun_counter;	//numero da funcao aonde o programa se encontra no momento
int main_exist;		//ve se a funcao "main" existe, 1 se sim, 0 se nao
char solo_func[50];	//se o programa nao tiver main, significa que so tem uma funcao, esta variavel guarda o respetivo nome

int reg_array[10];	//array dos registos, cada posiçao corresponde a um registo (posiçao 0-9 => $t0-$t9).
					//em cada posiçao guarda-se o inteiro do temporario correspondente.
					//exemplo: se t5 corresponde ao registo $t3, o valor 5 fica na posicao 3 do array

//cria uma estrutura funcao
struct fun_info *new_func(char *id)
{
	struct fun_info *f = malloc(sizeof(struct fun_info));

	strcpy(f->name, id);
	f->num_args = 0;
	f->num_locals = 0;
	f->args = NULL;
	f->locals = NULL;
	f->next = NULL;

	return f;
}

//insere uma funcao na lista ligada onde se encontram as funcoes
void insert_fun(struct fun_info *f)
{
	if(f_head == NULL && f_tail == NULL)
	{
		f_head = f;
		f_tail = f;
	}
	else
	{
		struct fun_info *n = f_head;

		while(n->next != NULL)
			n = n->next;

		n->next = f;
		f_tail = f;
	}
}

//cria e insere uma funcao na lista ligada de funcoes
void create_func(char id[50])
{
	struct fun_info *fun;

	if(strcmp(id, "main") == 0)
	{
		main_exist = 1;

		id[0] = '\0';
		strcpy(id, "not_main");
	}
	
	fun = new_func(id);
	insert_fun(fun);
}

//cria uma estrutura var (que guarda um argumento ou variavel local)
struct var *new_var(char id[50])
{
	struct var *v = malloc(sizeof(struct var));

	strcpy(v->id, id);
	v->next = NULL;

	return v;
}

//insere um argumento ou var. local na estrutura da respetiva funcao
void insert_arg_local(struct var *v, int a)
{
	if(a == 0 && f_tail->args == NULL)	//se for um argumento
	{
		f_tail->args = v;
		return;
	}
	else if(a == 1 && f_tail->locals == NULL) //se for uma variavel local
	{
		f_tail->locals = v;
		return;
	}

	struct var *t;

	if (a == 0)				//se for um argumento
		t = f_tail->args;
	else					//se for uma variavel local
		t = f_tail->locals;

	if(t == NULL)
		t = v;
	else
	{
		while(t->next != NULL)
			t = t->next;

		t->next = v;
	}
}

//cria e insere uma estrutura var na respetiva funcao
void insert_var(char id[50])
{
	struct var *v;

	v = new_var(id);

	if(args_locals == 0)
		f_tail->num_args++;
	else
		f_tail->num_locals++;

	insert_arg_local(v, args_locals);
}

//trata da instrucao i_value
void inst_value(char *t, int lit)
{
	t++;					//remove primeiro char da string
	int temp = atoi(t);		//converte para inteiro
	int i = 0;
	int lui = 0;

	while(reg_array[i] != -1)		//procura um registo disponivel
		i++;

	reg_array[i] = temp;		//associa temp ao registo i

	if(lit >= ORI_MAX)	//se o valor for maior ou igual a "ORI_MAX" = 2 elevado a 16 = 65536
	{
		lui = lit / ORI_MAX;
		lit = lit % ORI_MAX;

		printf("    lui   $t%d, %d\n", i, lui);
		printf("    ori   $t%d, $t%d, %d\n", i, i, lit);
	}
	else
		printf("    ori   $t%d, $0, %d\n", i, lit);
}

//trata das instrucoes: i_copy, i_inv e not
void inst_copy_inv_not(char *t1, int c, char *t2)
{
	int i = 0, j;
	t1++; t2++;
	int temp1 = atoi(t1);
	int temp2 = atoi(t2);

	while(reg_array[i] != temp2)	//procura onde esta temp guardado
		i++;

	reg_array[i] = -1;		//esvazia esse registo
	j = i;
	i = 0;

	while(reg_array[i] != -1)		//procura um registo disponivel
		i++;

	reg_array[i] = temp1; 		//e guarda o resultado nesse novo registo

	if(c == 1) 			//not
		printf("    nor   $t%d, $t%d, $t%d", i, j, j);
	else if(c == 2)		//i_inv
		printf("    subu  $t%d, $0, $t%d\n", i, j);
	else 				//i_copy
		printf("    or    $t%d, $0, $t%d\n", i, j);
}

//procura um argumento/variavel local especifico e retorna o respetivo offset
//para usar nos prints de store e load
int pass_args_locals(struct var *a, int k, char *var)
{
	while(strcmp(a->id, var) != 0 && a->next != NULL)
	{
		a = a->next;
		k++;
	}

	k *= 4;

	return k;
}

//procura e retorna a estrutura funcao corrente atraves do fun_counter
//se fun_counter = 1, funcao é head;
//se fun_counter = 2, funcao é head->next; etc..
struct fun_info *find_curr_func()
{
	int j = 1;
	struct fun_info *f = f_head;

	while(j != fun_counter)
	{
		f = f->next;
		j++;
	}

	return f;
}

//trata da instrucao store
void inst_store(char *var, int store, char *t)
{
	int i = 0, k;

	t++;
	int temp = atoi(t);

	while(reg_array[i] != temp)		//ve qual o registo associado ao temporario
		i++;

	reg_array[i] = -1;		//o respetivo registo fica livre para voltar a ser usado

	if(store == 3)		//gstore
	{
		printf("    sw    $t%d, %s\n", i, var);

		return;
	}

	struct fun_info *f = find_curr_func();

	if(store == 1)		//astore
	{
		struct var *a = f->args;
		k = pass_args_locals(a, 1, var);

		printf("    sw    $t%d, %d($fp)\n", i, k);
	}
	else if(store == 2)		//lstore
	{
		struct var *l = f->locals;
		k = pass_args_locals(l, 2, var);

		printf("    sw    $t%d, -%d($fp)\n", i, k);
	}
}

//trata da instrucao load
void inst_load(char *t, int load, char *var)
{
	int i = 0, k;

	t++;
	int temp = atoi(t);

	while(reg_array[i] != -1)	//procura registo vazio
		i++;

	reg_array[i] = temp;	//guarda temp nesse registo

	if(load == 3)		//gload
	{
		printf("    lw    $t%d, %s\n", i, var);

		return;
	}

	struct fun_info *f = find_curr_func();

	if(load == 1)		//aload
	{
		struct var *a = f->args;
		k = pass_args_locals(a, 1, var);

		printf("    lw    $t%d, %d($fp)\n", i, k);
	}
	else if(load == 2)		//lload
	{
		struct var *l = f->locals;
		k = pass_args_locals(l, 2, var);

		printf("    lw    $t%d, -%d($fp)\n", i, k);
	}
}

//trata das instrucoes das seguintes expressoes:
//i_add, i_sub, i_mul, i_div, mod, i_eq, i_lt, i_ne, i_le
void inst_exp(char *t1, int exp, char *t2, char *t3)
{
	int i = 0;
	int first, second, res;
	t1++; t2++; t3++;
	int temp1 = atoi(t1);
	int temp2 = atoi(t2);
	int temp3 = atoi(t3);

	while(reg_array[i] != temp2 && reg_array[i] != temp3)
		i++;

	if(reg_array[i] == temp2) 	//registo do primeiro operando encontrado
		first = i;			
	else
		second = i;

	reg_array[i] = -1;		//mete registo livre

	while(reg_array[i] != temp2 && reg_array[i] != temp3)
		i++;

	if(reg_array[i] == temp3) 	//registo do segundo operando encontrado
		second = i;
	else
		first = i;

	reg_array[i] = -1;		//mete registo livre

	i = 0;
	while(reg_array[i] != -1)	//procura registo vazio
		i++;

	reg_array[i] = temp1;		
	res = i;			//guarda o registo aonde fica o resultado da operacao

	if(exp == 1)		//i_add
	{
		printf("    addu  $t%d, $t%d, $t%d\n", res, first, second);
	}
	else if(exp == 2)		//i_sub
	{
		printf("    subu  $t%d, $t%d, $t%d\n", res, first, second);	
	}
	else if(exp == 3)		//i_mul
	{
		printf("    mult  $t%d, $t%d\n", first, second);
		printf("    mflo  $t%d\n", res);	
	}
	else if(exp == 4)		//i_div
	{
		printf("    div   $t%d, $t%d\n", first, second);
		printf("    mflo  $t%d\n", res);
	}
	else if(exp == 5)		//mod
	{
		printf("    div   $t%d, $t%d\n", first, second);
		printf("    mfhi  $t%d\n", res);
	}
	else if(exp == 6)		//i_eq
	{
		printf("    xor   $t%d, $t%d, $t%d\n", res, first, second);
		printf("    sltiu $t%d, $t%d, 1\n", res, res);
	}
	else if(exp == 7)		//i_lt
	{
		printf("    slt   $t%d, $t%d, $t%d\n", res, first, second);
	}
	else if(exp == 8)		//i_ne
	{
		printf("    xor   $t%d, $t%d, $t%d\n", res, first, second);
	}
	else if(exp == 9)		//i_le
	{
		printf("    slt   $t%d, $t%d, $t%d\n", res, second, first);
		printf("    sltiu $t%d, $t%d, 1\n", res, res);
	}
}

//trata da instrucao cjump
void inst_cjump(char *t, char *l1, char *l2)
{
	int i = 0;
	t++; l1++; l2++;
	int temp = atoi(t);
	int lab1 = atoi(l1);
	int lab2 = atoi(l2);

	while(reg_array[i] != temp)		//procura o registo onde temp esta
		i++;

	reg_array[i] = -1;		//mete o registo livre

	printf("    beq   $t%d, $0, l$%d\n", i, lab2);
	printf("    j     l$%d\n", lab1);
}

//trata das seguintes instrucoes:
//jump, i_return, b_return, i_print, b_print
void inst_single(int sing, char *t)
{
	t++;
	int i = 0;
	int temp = atoi(t);

	if(sing != 1)
	{
		while(reg_array[i] != temp)		//procura o registo onde esta temp
			i++;

		reg_array[i] = -1;		//mete o registo livre
	}

	if(sing == 1)		//jump
		printf("    j     l$%d\n", temp);
	else if(sing == 2 || sing == 3)		//i_return || b_return
		printf("    or    $v0, $0, $t%d\n", i);
	else if(sing == 4 || sing == 5)		//i_print || b_print
	{
		char str[8];

		if(sing == 4)
			strcpy(str, "i_print");
		else				
			strcpy(str, "b_print");

		printf("    %s$ $t%d\n", str, i);
	}
}

//trata das instrucoes i_read e b_read
void inst_read(char *t, int read)
{
	int i = 0;
	t++;
	int temp = atoi(t);

	while(reg_array[i] != -1)
		i++;

	reg_array[i] = temp;

	if(read == 1)
		printf("    i_read$ $t%d\n", i);
	else
		printf("    b_read$ $t%d\n", i);
}

//guarda os registos a serem utilizados nas instrucoes i_call e call
void save_regs(char *func)
{
	for(int i = 0; i < 10; i++)		//guarda todos os registos em uso
	{
		if(reg_array[i] != -1)
		{
			printf("    addiu $sp, $sp, -4\n");
			printf("    sw    $t%d, 0($sp)\n", i);
		}
	}

	printf("    jal   %s\n", func);
}

//depois de guardar os registos, ver quais desses tinham os argumentos
//do i_call/call e mete-os livres
void call_args(char *t)
{
	int i = 0;
	t++;
	int temp = atoi(t);

	while(reg_array[i] != temp)		//procura o temporario do argumento
		i++;

	reg_array[i] = -1; 		//mete o registo livre
}

//trata da instrucao call (e i_call)
void inst_call(int t)
{
	for(int i = 9; i >= 0; i--)
	{
		if(i == t)		//nao se esvazia o registo onde esta o valor de retorno (no caso do i_call)
			continue;

		if(reg_array[i] != -1)
		{
			printf("    lw    $t%d, 0($sp)\n", i);
			printf("    addiu $sp, $sp, 4\n");
		}
	}
}

//trata da instrucao i_call
void inst_icall(char *t)
{
	int i = 0;
	t++;
	int temp = atoi(t);

	while(reg_array[i] != -1)	//procura registo vazio
		i++;

	reg_array[i] = temp;	//guarda o temp no registo vazio encontrado

	printf("    or    $t%d, $0, $v0\n", i);

	inst_call(i);	//chama com o valor do registo utilizado para o valor retornado
}

//trata das variaveis globais (escreve a parte do ".data")
void global_var_in(char *name, int sign, int lit)
{
	if(data_usage == 0)
	{
		printf("\n    .data\n");

		data_usage = 1;
	}

	strcat(name, ":");

	if(sign == -1)		//se a variavel nao estiver inicializada
		printf("%-5s %s\n", name, ".space 4");
	else if(sign == 0)		//se a variavel estiver inicializada
		printf("%-5s %s %d\n", name, ".word", lit);
	else					//se a variavel estiver inicializada com um valor negativo
		printf("%-5s %s -%d\n", name, ".word", lit);
}

//trata do prologue de uma respetiva funcao
void prologue(char *name)
{
	struct fun_info *f = f_head;
	int local; 

	if(strcmp(name, "main") == 0)
	{
		name[0] = '\0';
		strcpy(name, "not_main");
	}

	printf("\n    .text\n"); 
	printf("%s:\n", name);

	while(f != NULL)
	{
		if(strcmp(f->name, name) == 0)
			break;

		f = f->next;
	}

	local = f->num_locals * 4 + 4;

	printf("    sw    $fp, -4($sp)\n");
	printf("    addiu $fp, $sp, -4\n");
	printf("    sw    $ra, -4($fp)\n");
	printf("    addiu $sp, $fp, -%d\n", local);
}

//trata do epilogue de uma respetiva funcao
void epilogue(char name[50])
{
	struct fun_info *f = f_head;
	int arg;

	if(strcmp(name, "main") == 0)
	{
		name[0] = '\0';
		strcpy(name, "not_main");
	}

	while(f != NULL)
	{
		if(strcmp(f->name, name) == 0)
			break;

		f = f->next;
	}

	arg = f->num_args * 4 + 4;

	printf("    lw    $ra, -4($fp)\n");
	printf("    addiu $sp, $fp, %d\n", arg);
	printf("    lw    $fp, 0($fp)\n");
	printf("    jr    $ra\n");
}

//print das labels
void print_label(char *l)
{
	l++;
	char label_str[6];

	strcpy(label_str, "l$");
	strcat(label_str, l);
	strcat(label_str, ":");

	printf("%-5s", label_str);
}

//inicializaçao do array dos registos a -1 (vazio)
void ini_reg()
{
	for(int i = 0; i < 10; i++)
	{
		reg_array[i] = -1;
	}
}

//guarda o nome da primeira funcao
//(necessario se nao houver main, o que pode acontecer quando so existe uma funcao)
void save_solo()
{
	struct fun_info *f = f_head;

	if(f != NULL)
		strcpy(solo_func, f->name);
}

//ve se a funcao main existe,
//se sim, muda o seu nome para not_main e cria uma nova main que chama o not_main,
//se nao, quer dizer que so existe uma funcao (guardada na variavel "solo_func") e cria um main que chama essa funcao.
//Este main é para o programa correr sem erros no MARS MIPS simulator
void check_main()
{
	char name[50];

	if(main_exist == 1)
		strcpy(name, "not_main");
	else
		strcpy(name, solo_func);

	printf("\n    .globl main\n");
	printf("main:\n");
	printf("    jal %s\n", name);
	printf("    li $v0, 10\n");
	printf("    syscall\n");
}
