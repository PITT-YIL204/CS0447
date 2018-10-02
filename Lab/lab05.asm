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
		sw	$a0, rev
		li	$a0, %alloc
		addiu	$a0, $a0, 4
		subu	$sp, $sp, $a0
		sw	$fp, 0($sp)
		lw	$a0, rev
		move	$a0, %arg0
		move	$a1, %arg1
		move	$a2, %arg2
		move	$a3, %arg3
		jal	%label
		.end_macro
		.macro	calr (%reg, %arg0, %arg1, %arg2, %arg3, %alloc)
		extend_stack
		move	$t9, %reg
		sw	$a0, rev
		li	$a0, %alloc
		addiu	$a0, $a0, 4
		subu	$sp, $sp, $a0
		sw	$fp, 0($sp)
		lw	$a0, rev
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
		.data
		rev:		.space	32
		sumTitle:	.asciiz	"Summation: sum(n)\n"
		integer_n:	.asciiz	"Please enter an integer (greater than or equal to 0): "
		sumResult:	.asciiz	"sum("
		powTitle:	.asciiz	"Power: pow(x,y)\n"
		integer_x:	.asciiz	"Please enter an integer for x (greater than or equal to 0): "
		integer_y:	.asciiz	"Please enter an integer for y (greater than or equal to 0): "
		powResult:	.asciiz "pow("
		comma:		.asciiz	","
		fTitle:		.asciiz	"Fibonacci: F(n)\n"
		fResult:	.asciiz	"F("
		isMsg:		.asciiz	") is "
		period:		.asciiz ".\n"
		.text
		# Sum
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, sumTitle		# Set $a0 to sumTitle
		syscall				# Print "Summation..."
		la   $a0, integer_n		# Set $a0 to integer_n
		syscall				# Print "Please..."
		addi $v0, $zero, 5		# Syscall 5: Read integer
		syscall				# Read an integer
		add  $s0, $zero, $v0		# $s0 is n
		add  $a0, $zero, $s0		# Set argument for _sum
		call (_sum, $a0, $0, $0, $0, 0)	# Call the _sum function
		collect ($s1, $0)		# $s1 = sum(n)
		# Print result (sum)
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, sumResult		# Set $a0 to sumResult
		syscall				# Print "sum("
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s0		# Set $a0 to n
		syscall				# Print n
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, isMsg			# Set $a0 to isMsg
		syscall				# Print ") is "
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s1		# Set $a0 to result of sum
		syscall				# Print result
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, period		# Set $a0 to period
		syscall				# Print ".\n"

		# Power
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, powTitle		# Set $a0 to powTitle
		syscall				# Print "Summation..."
		la   $a0, integer_x		# Set $a0 to integer_x
		syscall				# Print "Please..."
		addi $v0, $zero, 5		# Syscall 5: Read integer
		syscall				# Read an integer
		add  $s0, $zero, $v0		# $s0 is x
		addi $v0, $zero, 4		# Syscall 4: Print string	
		la   $a0, integer_y		# Set $a0 to integer_y
		syscall				# Print "Please..."
		addi $v0, $zero, 5		# Syscall 5: Read integer
		syscall				# Read an integer
		add  $s1, $zero, $v0		# $s1 is y
		add  $a0, $zero, $s0		# Set argument x for _pow
		add  $a1, $zero, $s1		# Set argument y for _pow
		call (_pow, $a0, $a1, $0, $0, 0)# Call the _pow function
		collect ($s2, $0)		# $s2 = pow(x,y)
		# Print result (pow)
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, powResult		# Set $a0 to powResult
		syscall				# Print "pow("
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s0		# Set $a0 to x
		syscall				# Print x
		addi $v0, $zero, 4		# Syscal 4: Print string
		la   $a0, comma			# Set $a0 to comma
		syscall				# Print ","
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s1		# Set $a0 to y
		syscall				# Print y
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, isMsg			# Set $a0 to isMsg
		syscall				# Print ") is "
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s2		# Set $a0 to result of pow
		syscall				# Print result
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, period		# Set $a0 to period
		syscall				# Print ".\n"

		# Fibonacci
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, fTitle		# Set $a0 to fTitle
		syscall				# Print "Fibonacci..."
		la   $a0, integer_n		# Set $a0 to integer_n
		syscall				# Print "Please..."
		addi $v0, $zero, 5		# Syscall 5: Read integer
		syscall				# Read an integer
		add  $s0, $zero, $v0		# $s0 is n
		add  $a0, $zero, $s0		# Set argument for _fibonacci
		call (_fibonacci, $a0, $0, $0, $0, 0)# Call the _fabonacci function
		collect ($s1, $0)		# $s1 = fibonacci(n)
		# Print result (fibonacci)
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, fResult		# Set $a0 to sumResult
		syscall				# Print "F("
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s0		# Set $a0 to n
		syscall				# Print n
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, isMsg			# Set $a0 to isMsg
		syscall				# Print ") is "
		addi $v0, $zero, 1		# Syscall 1: Print integer
		add  $a0, $zero, $s1		# Set $a0 to result of fibonacci
		syscall				# Print result
		addi $v0, $zero, 4		# Syscall 4: Print string
		la   $a0, period		# Set $a0 to period
		syscall				# Print ".\n"
		# Terminate Program
		addi $v0, $zero, 10		# Syscall 10: Terminate program
		syscall				# Terminate Program

# _sum
#
# Recursively calculate summation of a given number
#   sum(n) = n + sum(n - 1)
# where n >= 0 and sum(0) = 0.
#
# Argument:
#   $a0 - n
# Return Value:
#   $v0 = sum(n)
_sum:
		move	$v0, $0
		beqz	$a0, zero
		addu	$v0, $v0, $a0
		subiu	$a0, $a0, 1
		call (_sum, $a0, $0, $0, $0, 0)
		collect ($t0, $0)
		addu	$v0, $v0, $t0
zero:		return
# _pow
#
# Recursively calculate x^y
#   x^y = x * (x^(y - 1))
# where x >= 0 and y >= 0
#
# Arguments:
#   - $a0 - x
#   - $a1 - y
# Return Value
#   - $v0 = x^y
_pow:		
		li	$v0, 1
		beqz	$a1, zero1
		mulu	$v0, $v0, $a0
		subiu	$a1, $a1, 1
		call (_pow, $a0, $a1, $0, $0, 0)
		collect ($t0, $0)
		mulu	$v0, $v0, $t0
zero1:		return

# _fibonacci
#
# Calculate a Fibonacci number (F) where
#   F(0) = 0
#   F(1) = 1
#   F(n) = F(n - 1) + F(n - 2)
# Argument:
#   $a0 = n
# Return Value:
#   $v0 = F(n)
_fibonacci:
		move	$v1, $0
		li	$v0, 1
		beq	$a0, $v0, head
		subu	$a0, $a0, 1
		call (_fibonacci, $a0, $0, $0, $0, 0)
		collect ($v1, $v0)
		addu	$v0, $v0, $v1
head:		return
	