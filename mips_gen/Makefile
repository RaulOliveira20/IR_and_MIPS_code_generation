CC = gcc -Wall
YACC = bison -d
LEX = flex


ir : ir.tab.c lex.yy.c
	$(CC) $^ -o $@ -lfl

ir.tab.c : ir.y
	$(YACC) $^

lex.yy.c : ir.lex
	$(LEX) $^

run : ir
	@./ir

run-1 : ir
	@echo '[twice.ir2]'
	@./ir < ../examples-2/twice.ir2

run-2 : ir
	@echo '[fig-9.ir2]'
	@./ir < ../examples-2/fig-9.ir2

run-3 : ir
	@echo '[even.ir2]'
	@./ir < ../examples-2/even.ir2

run-4 : ir
	@echo '[arith.ir2]'
	@./ir < ../examples-2/arith.ir2

run-5 : ir
	@echo '[triangular.ir2]'
	@./ir < ../examples-2/triangular.ir2

run-6: ir
	@echo '[or.ir2]'
	@./ir < ../examples-2/or.ir2

run-7: ir
	@echo '[calls.ir2]'
	@./ir < ../examples-2/calls.ir2

run-8: ir
	@echo '[example.ir2]'
	@./ir < ../examples-2/example.ir2

run-9: ir
	@echo '[factorial.ir2]'
	@./ir < ../examples-2/factorial.ir2

clean :
	@$(RM) ir
	@$(RM) ir.tab.c ir.tab.h
	@$(RM) lex.yy.c
