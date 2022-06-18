# IR_and_MIPS_code_generation

This project is divided into two different parts and it involves turning the abstract syntax tree of a TACL program into IR code and then into MIPS assembly code, which should be runnable on the MARS MIPS simulator (MARS simulates a 32 bit MIPS system). 

The first one takes the abstract syntax tree represented in prolog terms. The program written in SWI-Prolog reads this tree from input and outputs intermediate representation (IR) code.

The second one picks up the output of the first one, the IR code generated, reads it with a parser written using flex+bison tools and generates MIPS assembly code with a program written in C.

# TACL language

This language was created by my advanced topics of compilation professor, which is based on other known languages.

TACL is an imperative programming language, with a syntax similar to C (and Java), although with some differences. A program in this language consists of a non empty sequence of variable, function and procedure declarations. A program example of this language which returns the factorial of a number n is shown here: 

```
fun int factorial(int n)
[
  var int r = 1;

  if (n > 0)
    r = n * factorial(n - 1);

  ^ r
]
```

# IR generation

For the generation of the IR code, the AST (abstract syntax tree) in prolog terms of the program is taken as input. Using the factorial example, the AST in terms is the following:

```
fun(factorial, [arg(n, int)],
  body([
      local(r, int, int_literal(1): int)
    ], 
    if(
      gt(id(n,arg,int): int, int_literal(0): int): bool, 
      assign(id(r,local,int),
        times(id(n,arg,int): int,
          call(factorial, [
              minus(id(n,arg,int): int, int_literal(1): int): int
            ]): int): int), 
      nil),
    id(r,local,int): int)).
```





