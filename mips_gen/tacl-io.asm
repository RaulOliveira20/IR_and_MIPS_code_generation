	# print an integer
	.macro i_print$ (%int)
	or    $a0, $0, %int
	ori   $v0, $0, 1
	syscall
	ori   $a0, $0, '\n'
	ori   $v0, $0, 11
	syscall
	.end_macro

	# read an integer
	.macro i_read$ (%reg)
	ori   $v0, $0, 5
	syscall
	or    %reg, $0, $v0
	.end_macro

	.data
	.align 4
true:	.asciiz "true\n"
	.align 4
false:  .asciiz "false\n"
bool$:  .word false true

	# print a boolean value
	.macro b_print$ (%bool)
	la    $a0, bool$
	sll   $v0, %bool, 2
	addu  $a0, $a0, $v0
	lw    $a0, 0($a0)
	ori   $v0, $0, 4
	syscall
	.end_macro

	.data
buffer$: .space 16
berror$: .asciiz "Error: invalid boolean input: "

	# read a boolean
	.macro b_read$ (%reg)
	la    $a0, buffer$
	ori   $a1, 8
	ori   $v0, $0, 8
	syscall
	la    $a1, true		# check for true
	lw    $a2, 0($a0)
	lw    $a3, 0($a1)
	xor   $v0, $a2, $a3
	lh    $a2, 4($a0)
	lh    $a3, 4($a1)
	xor   $a2, $a2, $a3
	or    $v0, $v0, $a2
	ori   %reg, $0, 1
	beq   $v0, $0, done$
	la    $a1, false	# check for false
	lw    $a2, 0($a0)
	lw    $a3, 0($a1)
	xor   $v0, $a2, $a3
	lh    $a2, 4($a0)
	lh    $a3, 4($a1)
	xor   $a2, $a2, $a3
	or    $v0, $v0, $a2
	lb    $a3, 6($a0)
	or    $v0, $v0, $a3
	ori   %reg, $0, 0
	beq   $v0, $0, done$
	la    $a0, berror$	# invalid value read
	ori   $v0, $0, 4
	syscall
	la    $a0, buffer$
	syscall
	teq   $0, $0		# trap
done$:
	.end_macro
