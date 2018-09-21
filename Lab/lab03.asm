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
		addi 	$sp, $sp -4
		sw   	$fp, 0($sp)
		move 	$fp, $sp
		addi 	$sp, $sp -4
		sw   	$ra  -4($fp)
		.end_macro	
		.macro	shrink_stack
		lw 	$ra, -4($fp)
		lw 	$fp, 0($fp)
		addi 	$sp, $sp, 8
		.end_macro	
		.macro	print_number (%reg)
		li	$v0, 36
		move	$a0, %reg
		syscall	
		.end_macro
		.macro	print_char (%ascii)
		li	$v0, 11
		li	$a0, %ascii
		syscall
		.end_macro
		.macro	print_prompt (%addr)
		li	$v0, 4
		la	$a0, %addr
		syscall
		.end_macro
		.macro	print_arith (%ascii)
		print_char (10)
		print_number ($s0)
		print_char (%ascii)
		print_number ($s1)
		print_char (61)
		print_number ($s2)
		.end_macro
		.macro	scan (%code)
		li	$v0, %code
		syscall
		.end_macro
		.macro reverse_bit_step (%index, %reg)
		li	$t9, %index
		sll	$t9, $t9, 2
		la	$t8, revtable
		addu	$t8, $t8, $t9
		lw	$t8, 0($t8)
		li	$t9, 1
		sll	$t9, $t9, %index
		and	$t7, %reg, $t8
		sllv	$t7, $t7, $t9
		srlv	%reg, %reg, $t9
		and	%reg, %reg, $t8
		or	%reg, %reg, $t7
		.end_macro	
		.macro	reverse_bit (%reg)
		reverse_bit_step (0, %reg)
		reverse_bit_step (1, %reg)
		reverse_bit_step (2, %reg)
		reverse_bit_step (3, %reg)
		reverse_bit_step (4, %reg)
		.end_macro	
		.macro	square (%reg)
		move	$a0, %reg
		move	$a1, %reg
		jal	multiply
		move	%reg, $v0
		.end_macro	
		.macro	mul_bit_step
		sll	$v0, $v0, 1
		andi	$t1, $a1, 1
		nor	$t1, $t1, $0
		addiu	$t1, $t1, 1
		and	$t1, $t1, $a0
		addu	$v0, $v0, $t1
		srl	$a1, $a1, 1
		.end_macro
		.macro	mul_byte
		mul_bit_step
		mul_bit_step
		mul_bit_step
		mul_bit_step
		mul_bit_step
		mul_bit_step
		mul_bit_step
		mul_bit_step
		.end_macro
		.macro mul_word
		mul_byte
		mul_byte
		mul_byte
		mul_byte
		.end_macro
		.macro	exp_bit_step
		andi	$t2, $a3, 1
		nor	$t2, $t2, $0
		addiu	$t2, $t2, 1
		and	$t2, $t2, $a2
		move	$a0, $t3
		move	$a1, $t2
		slti	$a1, $a1, 1
		subi	$t4, $a1, 1
		and	$t4, $t4, $t2
		addu	$a1, $a1, $t4
		jal	multiply
		move	$t3, $v0
		square ($a2)
		srl	$a3, $a3, 1
		.end_macro	
		.macro	exp_word
		exp_bit_step
		exp_bit_step
		exp_bit_step
		exp_bit_step
		exp_bit_step
		.end_macro 		
		.data
prompt1:	.asciiz	"\n\nPlease enter a positive integer: "
prompt2:	.asciiz "\n\nPlease enter another positive integer: "
warning:	.asciiz "\nA negative integer is not allowed."
revtable:	.word	0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF, 0xFFFFFFFF
		.text
		la	$t9, get_nums
		jal	get_nums
		move	$s0, $v1
		move	$s1, $v0
		move	$a0, $s0
		move	$a1, $s1
		jal	multiply
		move	$s2, $v0
		print_arith (42)
		move	$a0, $s0
		move	$a1, $s1
		jal	exponent
		move	$s2, $v0
		print_arith (94)
		j	end
get_nums:	print_prompt (prompt1)
		scan (5)
		srl	$t1, $v0, 31
		bnez	$t1, negative
		move	$v1, $v0
		la	$t9, get_num2
get_num2:	print_prompt (prompt2)
		scan (5)
		srl	$t1, $v0, 31
		bnez	$t1, negative
		jr	$ra
negative:	print_prompt (warning)
		jr	$t9
multiply:	move	$v0, $0
		reverse_bit ($a1)
		mul_word
		jr	$ra
exponent:	extend_stack
		move	$a2, $a0
		move	$a3, $a1
		li	$t3, 1
		exp_word
skip:		move	$v0, $t3
		shrink_stack
		jr	$ra
end:		li	$v0, 10
		syscall
