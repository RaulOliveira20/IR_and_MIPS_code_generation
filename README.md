# IR_and_MIPS_code_generation

This project is divided into two different parts and it involves turning the abstract syntax tree of a TACL program into IR code and then into MIPS assembly code, which should be runnable on the MARS MIPS simulator (MARS simulates a 32 bit MIPS system). 

The first one takes the abstract syntax tree represented in prolog terms. The program written in SWI-Prolog reads this tree from input and outputs intermediate representation (IR) code.

The second one picks up the output of the first one, the IR code generated, reads it with a parser written using flex+bison tools and generates MIPS assembly code with a program written in C.

# TACL language

TACL is an imperative programming language, with a syntax similar to C (and Java), although with some differences. A program in this language consists of a non empty sequence of variable, function and procedure declarations.

# IR generation

