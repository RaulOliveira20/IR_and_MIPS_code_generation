# IR_and_MIPS_code_generation

This project is divided into two different parts and it involves turning the abstract syntax tree of a TACL program into IR code and then into MIPS assembly code, which should be runnable on the MARS MIPS simulator (MARS simulates a 32 bit MIPS system). 

The first one takes the abstract syntax tree represented in prolog terms. The program written in SWI-Prolog reads this tree from a file as input and outputs intermediate representation (IR) code.

The second one picks up the output of the first one, the IR code generated, reads it with a parser written using flex+bison tools and generates MIPS assembly code using a program written in C.

# TACL language

This language was created by my advanced topics of compilation professor, which is based on other known languages.

TACL is an imperative programming language, with a syntax similar to C (and Java), although with some differences. A program in this language consists of a non empty sequence of variable, function and procedure declarations. A program example of this language which returns the factorial of a number n is shown here: 

```
fun real factorial(int n)
[
  var int r;

  r = 1;

  while (n > 0)
  [
    r = r * n;
    n = n - 1;
  ]

  ^ r
]
```

# IR generation

For the generation of the IR code, the AST (abstract syntax tree) in prolog terms of the program is taken as input. Using the factorial example, the AST in terms is the following:

```
fun(factorial, [arg(n, int)],
  body([
      local(r, int, nil)
    ], [
      assign(id(r,local,int), int_literal(1): int),
      while(
        gt(id(n,arg,int): int, int_literal(0): int): bool, [
          assign(id(r,local,int),
            times(id(r,local,int): int, id(n,arg,int): int): int),
          assign(id(n,arg,int),
            minus(id(n,arg,int): int, int_literal(1): int): int)
        ])
    ],
    id(r,local,int): int)).
```

Using the "TACL.pl" program, with the AST as a file input, the output should be the following IR code:

```
function @factorial
	t0 <- i_value 1
	@r <- i_lstore t0
l0:	t1 <- i_aload @n
	t2 <- i_value 0
	t3 <- i_lt t2, t1
	cjump t3, l1, l2
l1:	t4 <- i_lload @r
	t5 <- i_aload @n
	t6 <- i_mul t4, t5
	@r <- i_lstore t6
	t7 <- i_aload @n
	t8 <- i_value 1
	t9 <- i_sub t7, t8
	@n <- i_astore t9
	jump l0
l2:	t10 <- i_lload @r
	i_return t10
```

Running SWI-Prolog, we do these commands to run the program and generate the IR code:

```?- consult('TACL.pl').```

and then

```?- main('factorial.pl').```

where "factorial.pl" would have the AST in prolog terms of the factorial program, shown above.

NOTE: the input files cannot have empty lines after the last function, otherwise it will give an error.

# MIPS generation

In the folder "mips_gen", we have the parser which is used to read the IR code from input and the "mips.c" program helps in determining what output of MIPS assembly code to print. Using the IR code generated from the "TACL.pl" program, we can parse it and write the corresponding MIPS code. The IR code of the factorial program used as input is shown here:

```
(id @factorial fun int [(int @n)] [(int @r)])

function @factorial
	t0 <- i_value 1
	@r <- i_lstore t0
l0:	t1 <- i_aload @n
	t2 <- i_value 0
	t3 <- i_lt t2, t1
	cjump t3, l1, l2
l1:	t4 <- i_lload @r
	t5 <- i_aload @n
	t6 <- i_mul t4, t5
	@r <- i_lstore t6
	t7 <- i_aload @n
	t8 <- i_value 1
	t9 <- i_sub t7, t8
	@n <- i_astore t9
	jump l0
l2:	t10 <- i_lload @r
	i_return t10
```

Which is the same as the one gathered earlier, but with the addition of the global variables, functions and procedures declared at the top.

With bison+flex (and gcc) installed, running the following commands would parse and print the MIPS assembly code:

```
$ make ir
$ ./ir < factorial.ir2
```

where "factorial.ir2" would have the IR code of the factorial program (with the declarations at the top), like shown above.

Using the IR code of the factorial example shown above, the MIPS code output should be the following:

```
	.include "tacl-io.asm"
	
	.text
factorial:
	sw    $fp, -4($sp)
	addiu $fp, $sp, -4
	sw    $ra, -4($fp)
	addiu $sp, $fp, -8
	ori   $t0, $0, 1
	sw    $t0, -8($fp)
l$0:	lw    $t0, 4($fp)
	ori   $t1, $0, 0
	slt   $t0, $t1, $t0
	beq   $t0, $0, l$2
	j     l$1
l$1:	lw    $t0, -8($fp)
	lw    $t1, 4($fp)
	mult  $t0, $t1
	mflo  $t0
	sw    $t0, -8($fp)
	lw    $t0, 4($fp)
	ori   $t1, $0, 1
	subu  $t0, $t0, $t1
	sw    $t0, 4($fp)
	j     l$0
l$2:	lw    $t0, -8($fp)
	or    $v0, $0, $t0
	lw    $ra, -4($fp)
	addiu $sp, $fp, 8
	lw    $fp, 0($fp)
	jr    $ra

    .globl main
main:
    jal factorial
    li $v0, 10
    syscall
```

It also includes the file "tacl-io.asm" which contains macros for reading and printing values.

At the end, the command:

```
$ make clean
```

can be used to eliminate the files generated previously.
