
%dependendo do tipo e genero da variavel, faz o load respetivo
check_type_and_genre_load(T, arg, ID) :- (T = int; T = bool), write('i_aload '), write('@'), write(ID), nl.
check_type_and_genre_load(T, arg, ID) :- T = real, write('r_aload '), write('@'), write(ID), nl.

check_type_and_genre_load(T, local, ID) :- (T = int; T = bool), write('i_lload '), write('@'), write(ID), nl.
check_type_and_genre_load(T, local, ID) :- T = real, write('r_lload '), write('@'), write(ID), nl.

check_type_and_genre_load(T, var, ID) :- (T = int; T = bool), write('i_gload '), write('@'), write(ID), nl.
check_type_and_genre_load(T, var, ID) :- T = real, write('r_gload '), write('@'), write(ID), nl.

%dependendo do tipo e genero da variavel, faz o store respetivo
check_type_and_genre_store(T, arg, Temp) :- (T = int; T = bool), write('i_astore '), write(Temp), nl.
check_type_and_genre_store(T, arg, Temp) :- T = real, write('r_astore '), write(Temp), nl.

check_type_and_genre_store(T, local, Temp) :- (T = int; T = bool), write('i_lstore '), write(Temp), nl.
check_type_and_genre_store(T, local, Temp) :- T = real, write('r_lstore '), write(Temp), nl.

check_type_and_genre_store(T, var, Temp) :- (T = int; T = bool), write('i_gstore '), write(Temp), nl.
check_type_and_genre_store(T, var, Temp) :- T = real, write('r_gstore '), write(Temp), nl.

%todos os statements possiveis
statement(Stat) :- assign(Stat);
				   call_proc(Stat, []);
				   print(Stat);
				   id_read(Stat);
				   if(Stat);
				   while(Stat).

%todas as expressoes possiveis
expression(Exp) :- literal(Exp);
				   id(Exp);
				   or(Exp);
				   and(Exp);
				   eq(Exp);
				   ne(Exp);
				   lt(Exp);
				   le(Exp);
				   gt(Exp);
				   ge(Exp);
				   plus(Exp);
				   minus(Exp);
				   times(Exp);
				   div(Exp);
				   mod(Exp);
				   not(Exp);
				   inv(Exp);
				   true_false(Exp);
				   call_func(Exp, []);
				   toreal(Exp).

%procedure call
call_proc(call(ID, Ex), Lista) :- (Ex = [E], expression(E), save_temp(E, A), append(Lista, [A], NewLista);
								  Ex = [], NewLista = []), wr(),
								  write('call @'), write(ID), write(', '), write(NewLista), nl.

call_proc(call(ID, [E|L]), Lista) :- expression(E), save_temp(E, A), append(Lista, [A], NewLista),
									 call_proc(call(ID, L), NewLista).

%function call
call_func(call(ID, Ex): T, Lista) :- (Ex = [E], expression(E), save_temp(E, A), append(Lista, [A], NewLista);
									 Ex = [], NewLista = []), save_curr_and_inc(_: T, Temp),
							         ((T = int; T = bool), Call = i_call; T = real, Call = r_call),
							         wr(), write(Temp), write(' <- '), write(Call),
							         write(' @'), write(ID), write(','), write(' '), write(NewLista), nl.

call_func(call(ID, [E|L]): T, Lista) :- expression(E), save_temp(E, A), append(Lista, [A], NewLista),
							   		  	call_func(call(ID, L): T, NewLista).

%se a operacao for: lt, le, gt ou ge
compare_op(X, Y, Temp1, Temp2, MM) :- expression(X), type(X, T1), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2),
					    	          save_curr_and_inc(_: bool, Temp), 
					    	          (MM = lt, (T1 = int, M = i_lt; T1 = real, M = r_lt);
					    	          MM = le, (T1 = int, M = i_le; T1 = real, M = r_le)),
					    	          wr(), write(Temp), write(' <- '), write(M), write(' ').

if_then([], _, n).
if_then([], Lab, y) :- wr(), write('jump '), write(Lab), nl.
if_then([T|L], Lab, X) :- statement(T), if_then(L, Lab, X).
if_then(Then, _, n) :- statement(Then).
if_then(Then, Lab, y) :- statement(Then), wr(), write('jump '), write(Lab), nl.

if_else(nil).
if_else([]).
if_else([T|L]) :- statement(T), if_else(L).
if_else(Else) :- statement(Else).

%trata do statement if
if(if(C, Then, Else)) :- (C = C1:_, functor(C1, I, _),
						 (I \= and, I \= or, expression(C);
						 I = and, or_and(C1, and, y, Lab1, Lab2); I = or, or_and(C1, or, y, Lab1, Lab2))),
						 save_temp(C, CTemp), nb_getval(lc, L), NL is L+3, nb_setval(lc, NL),
						 LL is L+1, TL is L+2, atom_concat(l, L, L1), atom_concat(l, LL, L2), atom_concat(l, TL, L3),
						 wr(), write('cjump '), write(CTemp), write(', '),
						 (
						 (I = or, write(Lab1); I = and, write(Lab2)), write(', '), write(L1), nl,
						 write(Lab1), write(':'), nb_setval(lb, 1), 
						 (Else \= nil, if_then(Then, L2, y); Else = nil, if_then(Then, L2, n)),
						 write(L1), write(':'), nb_setval(lb, 1),
						 if_else(Else), write(L2), write(':'), nb_setval(lb, 1);

						 I \= and, I \= or, write(L1), write(', '), write(L2), nl, write(L1), write(':'), nb_setval(lb, 1), 
						 (Else \= nil, if_then(Then, L3, y); Else = nil, if_then(Then, L3, n)), 
						 write(L2), write(':'), nb_setval(lb, 1),
						 (Else \= nil, if_else(Else), write(L3), write(':'), nb_setval(lb, 1); Else = nil)
						 ).

while_exp([], Lab) :- wr(), write('jump '), write(Lab), nl.
while_exp([T|L], Lab) :- statement(T), while_exp(L, Lab).
while_exp(T, Lab) :- statement(T), wr(), write('jump '), write(Lab), nl.

%trata do statement while
while(while(C, E)) :- nb_getval(lc, L), atom_concat(l, L, L1), KL is L+1, nb_setval(lc, KL),
					  write(L1), write(':'), nb_setval(lb, 1),
					  (C = C1:_, functor(C1, I, _),
					  (I \= and, I \= or, expression(C);
					  I = and, or_and(C1, and, w, Lab1, Lab2); I = or, or_and(C1, or, w, Lab1, Lab2))),
					  save_temp(C, CTemp), NL is L+3, nb_setval(lc, NL),
					  LL is L+1, TL is L+2, atom_concat(l, LL, L2), atom_concat(l, TL, L3), atom_concat(l, NL, L4),
					  wr(), write('cjump '), write(CTemp), write(', '),
					  (
					  (I = or, write(Lab1); I = and, write(Lab2)), write(', '), write(L4), nl,
					  (I = or, write(Lab1); I = and, write(Lab2)), write(':'), nb_setval(lb, 1), 
					  while_exp(E, L1),
					  write(L4), write(':'), nb_setval(lb, 1);

					  I \= and, I \= or, write(L2), write(', '), write(L3), nl, 
					  write(L2), write(':'), nb_setval(lb, 1), 
					  while_exp(E, L1), 
					  write(L3), write(':'), nb_setval(lb, 1)
					  ).

or_and(C, and, F, L1, L2) :- C = and(X, Y), or_and(X, Y, and, F, L1, L2).
or_and(C, or, F, L1, L2) :- C = or(X, Y), or_and(X, Y, or, F, L1, L2).

%se or/and vem de um if ou while
or_and(X, Y, N, _, L1, L2) :- expression(X), save_temp(X, Temp1), wr(),
			    	   	      nb_getval(lc, L), NL is L+2, nb_setval(lc, NL), LL is L+1,
			    	          atom_concat(l, L, L1), atom_concat(l, LL, L2),
			    	          write('cjump '), write(Temp1), write(', '), write(L1), write(', '), write(L2), nl,
			    	          (N = and, write(L1); N = or, write(L2)), write(':'), nb_setval(lb, 1), 
			    	          expression(Y).

%se or/and nao vem de um if ou while
or_and(X, Y, N, n) :- expression(X), save_temp(X, Temp1), wr(),
		    	   	  nb_getval(lc, L), NL is L+2, nb_setval(lc, NL), LL is L+1,
		    	      atom_concat(l, L, L1), atom_concat(l, LL, L2),
		    	      write('cjump '), write(Temp1), write(', '), write(L1), write(', '), write(L2), nl,
		    	      (N = and, write(L1); N = or, write(L2)), write(':'), nb_setval(lb, 1), 
		    	      expression(Y), save_temp(Y, Temp2), wr(), 
		    	      write(Temp1), write(' <- i_copy '), write(Temp2), nl, nb_setval(copy, Temp1),
		    	      (N = and, write(L2); N = or, write(L1)), write(':'), nb_setval(lb, 1).

or(or(X, Y): _) :- or_and(X, Y, or, n).

and(and(X, Y): _) :- or_and(X, Y, and, n).

eq(eq(X, Y): _) :- expression(X), type(X, T1), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2),
		    	   save_curr_and_inc(_: bool, Temp), (T1 = int, M = i_eq; T1 = real, M = r_eq),
		    	   wr(), write(Temp), write(' <- '), write(M), write(' '),
				   write(Temp1), write(', '), write(Temp2), nl.

ne(ne(X, Y): _) :- expression(X), type(X, T1), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2),
		    	   save_curr_and_inc(_: bool, Temp), (T1 = int, M = i_ne; T1 = real, M = r_ne),
		    	   wr(), write(Temp), write(' <- '), write(M), write(' '),
				   write(Temp1), write(', '), write(Temp2), nl.

lt(lt(X, Y): _) :- compare_op(X, Y, Temp1, Temp2, lt), write(Temp1), write(', '), write(Temp2), nl.

le(le(X, Y): _) :- compare_op(X, Y, Temp1, Temp2, le), write(Temp1), write(', '), write(Temp2), nl.

gt(gt(X, Y): _) :- compare_op(X, Y, Temp1, Temp2, lt), write(Temp2), write(', '), write(Temp1), nl.

ge(ge(X, Y): _) :- compare_op(X, Y, Temp1, Temp2, le), write(Temp2), write(', '), write(Temp1), nl.

plus(plus(X, Y): T) :- expression(X), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2), 
					   save_curr_and_inc(_: T, Temp), (T = int, M = i_add; T = real, M = r_add),
					   wr(), write(Temp), write(' <- '), write(M), write(' '), write(Temp1), write(', '), write(Temp2), nl.

minus(minus(X, Y): T) :- expression(X), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2), 
						 save_curr_and_inc(_: T, Temp), (T = int, M = i_sub; T = real, M = r_sub),
					     wr(), write(Temp), write(' <- '), write(M), write(' '), write(Temp1), write(', '), write(Temp2), nl.

times(times(X, Y): T) :- expression(X), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2), 
						 save_curr_and_inc(_: T, Temp), (T = int, M = i_mul; T = real, M = r_mul),
					     wr(), write(Temp), write(' <- '), write(M), write(' '), write(Temp1), write(', '), write(Temp2), nl.

div(div(X, Y): T) :- expression(X), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2),
					 save_curr_and_inc(_: T, Temp), (T = int, M = i_div; T = real, M = r_div),
					 wr(), write(Temp), write(' <- '), write(M), write(' '), write(Temp1), write(', '), write(Temp2), nl.

mod(mod(X, Y): _) :- expression(X), save_temp(X, Temp1), expression(Y), save_temp(Y, Temp2),
					 save_curr_and_inc(_: int, Temp), wr(),
					 write(Temp), write(' <- mod '), write(Temp1), write(', '), write(Temp2), nl.

not(not(X): _) :- expression(X), save_temp(X, A), save_curr_and_inc(_: bool, Temp),
				  wr(), write(Temp), write(' <- not '), write(A), nl.

inv(inv(X): T) :- expression(X), save_temp(X, A), save_curr_and_inc(_: T, Temp),
				  (T = int, M = i_inv; T = real, M = r_inv),
				  wr(), write(Temp), write(' <- '), write(M), write(' '), write(A), nl.

toreal(toreal(X): _) :- expression(X), save_temp(X, A), save_curr_and_inc(_: real, Temp),
						wr(), write(Temp), write(' <- itor '), write(A), nl.


assign(assign(id(ID, Genre, Type), X)) :-
		expression(X), wr(), save_temp(_: Type, Temp),
		write('@'), write(ID), write(' <- '),
		check_type_and_genre_store(Type, Genre, Temp).

local(ID, T, L) :-
		expression(L), wr(), save_temp(_: T, Temp),
		write('@'), write(ID), write(' <- '),
		check_type_and_genre_store(T, local, Temp).

print(print(X: T)) :-	expression(X: T), save_temp(_: T, Temp),
						((T = int, M = i_print; T = bool, M = b_print);
						T = real, M = r_print),
						wr(), write(M), write(' '), write(Temp), nl.

id_read(read(id(ID, Gen, T))) :- save_curr_and_inc(_: T, Temp),
								 ((T = int, M = i_read; T = bool, M = b_read);
								 T = real, M = r_read), wr(),
								 write(Temp), write(' <- '), write(M), nl, wr(),
								 write('@'), write(ID), write(' <- '),
								 check_type_and_genre_store(T, Gen, Temp).

true_false(X: bool) :- save_curr_and_inc(_: bool, Temp), wr(),
					   (X = true, Int = 1; X = false, Int = 0),
					   write(Temp), write(' <- i_value '), write(Int), nl.

literal(L: T) :- (L = int_literal(X); L = real_literal(X)), save_curr_and_inc(_: T, Temp),
				 (T = int, V = 'i_value '; T = real, V = 'r_value '), wr(),
				 write(Temp), write(' <- '), write(V), write(X), nl.

id(id(ID, Gen, Type): T) :- T = Type, save_curr_and_inc(_: T, Temp),
						    ((T = int; T = bool); T = real), wr(),
							write(Temp), write(' <- '), check_type_and_genre_load(T, Gen, ID).

%serve para formatar as labels no output
wr :- nb_getval(lb, L), (L = 0, write('       '); L \= 0, write('    '), nb_setval(lb, 0)).

%devolva o tipo de uma expressao
type(_: T, Type) :- T = Type.

%retorna o temporario corrente e incrementa a respetiva variavel global
save_curr_and_inc(_: T, A) :- (T = int; T = bool), nb_getval(tc, C), atom_concat(t, C, A), NC is C+1, nb_setval(tc, NC).
save_curr_and_inc(_: T, A) :- T = real, nb_getval(fpc, C), atom_concat(fp, C, A), NC is C+1, nb_setval(fpc, NC).

%retorna o temporario anteriormente utilizado,
%se copy foi utilizado, o temporario retornado é o que
%se encontra na variavel global 'copy'
save_temp(_, A) :- nb_getval(copy, X), X \= 0, A = X, nb_setval(copy, 0), !.
save_temp(_: T, A) :- (T = int; T = bool), nb_getval(tc, V), NV is V-1, atom_concat(t, NV, A).
save_temp(_: T, A) :- T = real, nb_getval(fpc, V), NV is V-1, atom_concat(fp, NV, A).

declarations([]).
declarations([D|L]) :- D = local(ID, T, A), (A = nil; A \= nil, local(ID, T, A)),
					   declarations(L).

instructions([]).
instructions(nil).
instructions(S) :- statement(S).
instructions([S|L]) :- statement(S), instructions(L).

return_write(_: T) :- save_temp(_: T, Temp), 
					  ((T = int; T = bool), write('i_return ');
					  T = real, write('r_return ')),
					  write(Temp), nl.

return_expression(nil) :- wr(), write('return'), nl.
return_expression(R) :- expression(R), wr(), return_write(R).

id_fun(fun(ID, _, body(D, S, R))) :- write('function @'), write(ID), nl,
								     declarations(D),
								     instructions(S),
							         return_expression(R).


%tc e fpc sao os contadores para os temporarios t e fp, lc é o contador para as labels
%copy é para ver se a expressao copy foi usada, e se foi, guarda o temporario utilizado
%lb é 1 quando se faz o output de uma label ('lx:'), para corretamente formatar a instruçao à frente no procedimento 'wr'
file_data([]).
file_data([X|R]):- nb_setval(tc, 0), nb_setval(fpc, 0),	nb_setval(lc, 0),
				   nb_setval(copy, 0), nb_setval(lb, 0),
				   functor(X, A, _), (A = fun, nl, id_fun(X); A = var),
			       file_data(R).

%chamada principal,
%chamar com o nome do ficheiro input
%NOTA: o ficheiro input nao pode ter linhas vazias depois da ultima funcao (da erro se tiver)
main(File) :-
	open(File, read, S),
    read_file(S, L),
    close(S),
    file_data(L).

read_file(S, []) :-
    at_end_of_stream(S).

read_file(S, [X|L]) :-
    \+ at_end_of_stream(S),
    read(S, X),
    read_file(S, L).