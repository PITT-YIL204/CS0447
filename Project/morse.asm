# MIT License
# 
# Copyright (c) 2018 Yilin Liu
# 
# No permission is granted to any person obtaining copies of any assembly 
# program and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

		.macro	extend_stack
		subiu 	$sp, $sp 4
		sw   	$fp, 0($sp)
		move 	$fp, $sp
		subiu 	$sp, $sp 68
		sw   	$ra, -4($fp)
		sw	$v0, -8($fp)
		sw	$v1, -12($fp)
		sw	$a0, -16($fp)
		sw	$a1, -20($fp)
		sw	$a2, -24($fp)
		sw	$a3, -28($fp)
		sw	$t0, -32($fp)
		sw	$t1, -36($fp)
		sw	$t2, -40($fp)
		sw	$t3, -44($fp)
		sw	$t4, -48($fp)
		sw	$t5, -52($fp)
		sw	$t6, -56($fp)
		sw	$t7, -60($fp)
		sw	$t8, -64($fp)
		sw	$t9, -68($fp)
		.end_macro
		.macro shrink_stack
		move   	$s7, $ra
		lw	$ra, -4($fp)
		lw	$v0, -8($fp)
		lw	$v1, -12($fp)
		lw	$a0, -16($fp)
		lw	$a1, -20($fp)
		lw	$a2, -24($fp)
		lw	$a3, -28($fp)
		lw	$t0, -32($fp)
		lw	$t1, -36($fp)
		lw	$t2, -40($fp)
		lw	$t3, -44($fp)
		lw	$t4, -48($fp)
		lw	$t5, -52($fp)
		lw	$t6, -56($fp)
		lw	$t7, -60($fp)
		lw	$t8, -64($fp)
		lw	$t9, -68($fp)
		lw	$sp, 0($sp)
		addiu	$sp, $sp, 4
		lw 	$fp, 0($sp)
		.end_macro	
		.macro	call (%label, %arg0, %arg1, %arg2, %arg3, %alloc)
		extend_stack
		li	$a0, %alloc
		addiu	$a0, $a0, 4
		subu	$sp, $sp, $a0
		sw	$fp, 0($sp)
		move	$a0, %arg0
		move	$a1, %arg1
		move	$a2, %arg2
		move	$a3, %arg3
		jal	%label
		.end_macro
		.macro	calr (%reg, %arg0, %arg1, %arg2, %arg3, %alloc)
		extend_stack
		move	$t9, %reg
		li	$a0, %alloc
		addiu	$a0, $a0, 4
		subu	$sp, $sp, $a0
		sw	$fp, 0($sp)
		move	$a0, %arg0
		move	$a1, %arg1
		move	$a2, %arg2
		move	$a3, %arg3
		jalr	$t9
		.end_macro	
		.macro	return
		la	$a0, rev
		sw	$v0, 0($a0)
		sw	$v1, 4($a0)
		shrink_stack
		jr	$s7
		.end_macro	
		.macro	collect (%reg0, %reg1)
		la	%reg0, rev
		lw	%reg1, 4(%reg0)
		lw	%reg0, 0(%reg0)
		.end_macro	
		.macro	push_hash_entries (%key, %hash)
		li	$t0, %key
		sb	$t0, %hash($v0)
		li	$t1, %hash
		sll	$t0, $t0, 1
		addu	$t0, $t0, $v0
		sh	$t1, 0($t0)
		.end_macro
		.macro	print_s (%reg)
		sw	$a0, rev
		la	$a0, rev
		sw	$v0, 4($a0)
		li	$v0, 4
		move	$a0, %reg
		syscall
		la	$v0, rev
		lw	$a0, 0($v0)
		lw	$v0, 4($v0)
		.end_macro
		.macro	print_str (%addr)
		sw	$a0, rev
		la	$a0, rev
		sw	$v0, 4($a0)
		li	$v0, 4
		la	$a0, %addr
		syscall
		la	$v0, rev
		lw	$a0, 0($v0)
		lw	$v0, 4($v0)
		.end_macro
		.macro	print_c (%reg)
		sw	$a0, rev
		la	$a0, rev
		sw	$v0, 4($a0)
		li	$v0, 11
		move	$a0, %reg
		syscall
		la	$v0, rev
		lw	$a0, 0($v0)
		lw	$v0, 4($v0)
		.end_macro
		.macro	print_char (%ascii)
		sw	$a0, rev
		la	$a0, rev
		sw	$v0, 4($a0)
		li	$v0, 11
		li	$a0, %ascii
		syscall
		la	$v0, rev
		lw	$a0, 0($v0)
		lw	$v0, 4($v0)
		.end_macro
		.macro	print_addr (%reg)
		sw	$a0, rev
		la	$a0, rev
		sw	$v0, 4($a0)
		move	$a0, %reg
		li	$v0, 36
		syscall	
		la	$v0, rev
		lw	$a0, 0($v0)
		lw	$v0, 4($v0)
		.end_macro
		.macro	get_int
		sw	$v0, rev+4
		li	$v0, 5
		syscall
		sw	$v0, rev
		lw	$v0, rev+4
		.end_macro
		.macro	get_line (%addr, %max)
		sw	$a0, rev
		sw	$a1, rev+4
		sw	$v0, rev+8
		li	$v0, 8
		la	$a0, %addr
		li	$a1, %max
		syscall
		lw	$a0, rev
		sw	$v0, rev
		lw	$a1, rev+4
		lw	$v0, rev+8
		.end_macro	
		.macro	inverse (%reg)
		nor	%reg, %reg, $0
		addiu	%reg, %reg, 2
		.end_macro	
		.data
rev:		.space	16
hashtable:	.space	4
buffer:		.space	100
cache:		.space	5
menu:		.asciiz "\n\nMain Menu\n=========\n  1. String to Morse code\n  2. Morse code to string\n  3. Exit program"
main_prompt:	.asciiz "\nWhat do you want to do? (1, 2 or 3): "
warning:	.asciiz	"\nInvalid operation."
str_prompt:	.asciiz	"\nPlease enter a string: "
mor_prompt:	.asciiz	"\nPlease enter a morse code: "
illegal:	.asciiz "\nIllegal characters involved."
operations:	.word	0, str2morse, morse2str
		.text
		.globl	main
main:		call (initialize, $0, $0, $0, $0, 0)
		call (entrance, $0, $0, $0, $0, 0)
		j	exit
initialize:	li	$s0, 3
		li	$s1, 1
		li	$s2, 32
		li	$s3, 10
		li	$s4, 45
		li	$s5, 46
		li	$v0, 9
		li	$a0, 1386
		syscall
		sw	$v0, hashtable
		push_hash_entries (0, 274)
		push_hash_entries (1, 1364)
		push_hash_entries (2, 1360)
		push_hash_entries (3, 636)
		push_hash_entries (4, 92)
		push_hash_entries (5, 1376)
		push_hash_entries (6, 632)
		push_hash_entries (7, 1380)
		push_hash_entries (8, 276)
		push_hash_entries (9, 1366)
		push_hash_entries (10, 634)
		push_hash_entries (11, 1372)
		push_hash_entries (12, 270)
		push_hash_entries (13, 272)
		push_hash_entries (14, 630)
		push_hash_entries (15, 1368)
		push_hash_entries (16, 1354)
		push_hash_entries (17, 640)
		push_hash_entries (18, 644)
		push_hash_entries (19, 90)
		push_hash_entries (20, 642)
		push_hash_entries (21, 1378)
		push_hash_entries (22, 638)
		push_hash_entries (23, 1362)
		push_hash_entries (24, 1358)
		push_hash_entries (25, 1356)
		return
entrance:	call (welcome, $0, $0, $0, $0, 0)
		collect ($t0, $0)
		beqz	$t0, over
		sll	$t0, $t0, 2
		la	$t1, operations
		addu	$t0, $t1, $t0
		lw	$t0, 0($t0)
		calr ($t0, $0, $0, $0, $0, 0)
		b	entrance
over:		return
welcome:	print_str (menu)
re1:		print_str (main_prompt)
		get_int
		collect ($v0, $0)
		call (inrange, $v0, $s1, $s0, $0, 0)
		collect ($t1, $0)
		bnez	$t1, legal1
		print_str (warning)
		b	re1
legal1:		div	$v0, $s0
		mfhi	$v0
		return
str2morse:	print_str (str_prompt)
		get_line (buffer, 100)
		la	$t0, buffer
		call (clean_str, $t0, $0, $0, $0, 0)
		collect ($t1, $0)
		bnez	$t1, legal2
		print_str (illegal)
		b	str2morse
legal2:		call (translate, $t0, $0, $0, $0, 0)
		return
morse2str:	print_str (mor_prompt)
		get_line (buffer, 100)
		la	$t0, buffer
		call (check_morse, $t0, $0, $0, $0, 0)
		collect ($t1, $0)
		bnez	$t1, loop3
		print_str (illegal)
		b	morse2str
loop3:		call (fetch_char, $t0, $0, $0, $0, 0)
		collect ($t1, $t2)
		print_c ($t2)
		beqz	$t1, complete
		move	$t0, $t1
		b	loop3
complete:	print_char (10)
		return
check_morse:	subiu	$a0, $a0, 1
loop4:		addiu	$a0, $a0, 1
		lbu	$t4, 0($a0)
		beq	$t4, $s3, true2
		beq	$t4, $s2, loop4
		beq	$t4, $s5, loop4
		beq	$t4, $s4, loop4
		move	$v0, $0
		return
true2:		li	$v0, 1
		return
fetch_char:	move	$v0, $a0
		move	$v1, $0
		subiu	$v0, $v0, 1
loop5:		addiu	$v0, $v0, 1
		lbu	$t4, 0($v0)
		beq	$t4, $s3, nline
		beq	$t4, $s2, space
		addu	$v1, $v1, $t4
		sll	$v1, $v1, 1
		b	loop5
nline:		move	$v0, $0
		beqz	$v1, complete3
		call (get_key, $v1, $0, $0, $0, 0)
		collect ($v1, $0)
		addiu	$v1, $v1, 65
complete3:	return
space:		bnez	$v1, continue4
		move	$v1, $s2
		addiu	$v0, $v0, 1
		return
continue4:	call (get_key, $v1, $0, $0, $0, 0)
		collect ($v1, $0)
		addiu	$v1, $v1, 65
		addiu	$v0, $v0, 1
		return
get_key:	lw	$t0, hashtable
		addu	$t0, $t0, $a0
		lbu	$v0, 0($t0)
		return
clean_str:	li	$t1, 65
		li	$t2, 90
		li	$t3, 97
		li	$t4, 122
		li	$t9, 10
		li	$t8, 32
loop1:		lbu	$t0, 0($a0)
		beq	$t0, $s3, true1
		bne	$t0, $s2, continue1
		mulu 	$t0, $t0, 3
		sb	$t0, 0($a0)
		addiu	$a0, $a0, 1
		b	loop1
continue1:	call (inrange, $t0, $t1, $t2, $0, 0)
		collect ($t5, $0)
		beqz	$t5, lower
		subiu	$t0, $t0, 65
		sb	$t0, 0($a0)
		addiu	$a0, $a0, 1
		b	loop1
lower: 		call (inrange, $t0, $t3, $t4, $0, 0)
		collect ($t5, $0)
		beqz	$t5, false1
		subiu	$t0, $t0, 97
		sb	$t0, 0($a0)
		addiu	$a0, $a0, 1
		b	loop1
false1:		move	$v0, $0
		return
true1:		mulu	$t0, $t0, 3
		sb	$t0, 0($a0)
		li	$v0, 1
		return
translate:	li	$t3, 30
		lb	$t0, 0($a0)
		bne	$t0, $t3, continue2
		print_char (10)
		return
continue2:	sltiu	$t1, $t0, 27
		bnez	$t1, continue3
		divu	$t0, $t0, 3
		print_c ($t0)
		print_char (32)
		addiu	$a0, $a0, 1
		b	translate
continue3:	call (put_morse, $t0, $0, $0, $0, 0)
		print_char (32)
		addiu	$a0, $a0, 1
		b	translate
put_morse:	li	$t8, 45
		li	$t7, 46
		la	$t9, cache
		addiu	$t9, $t9, 5
		sb	$0, 0($t9)
		lw	$t0, hashtable
		sll	$a0, $a0, 1
		addu	$a0, $a0, $t0
		lh	$t1, 0($a0)
loop2:		subiu	$t9, $t9, 1
		srl	$t1, $t1, 1
		andi	$t2, $t1, 1
		beqz	$t2, dot
		sb	$t8, 0($t9)
		subu	$t1, $t1, $t8
		bnez	$t1, loop2
		b	output
dot:		sb	$t7, 0($t9)
		subu	$t1, $t1, $t7
		bnez	$t1, loop2
		b	output
output:		print_s ($t9)
		return
inrange:	addiu	$a2, $a2, 1
		slt	$t1, $a0, $a1
		slt	$t2, $a0, $a2
		inverse ($t2)
		or	$v0, $t1, $t2
		inverse ($v0)
		return
exit:		li	$v0, 10
		syscall