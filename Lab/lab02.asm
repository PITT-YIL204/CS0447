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

	.data
	.align	2
	.word	less, less, less, less, less, less, less, less
cases:	.word	win, greater, greater, greater, greater, greater, greater, greater, greater
prompt:	.asciiz "\n\n Enter a number between 0 and 9: "
low:	.asciiz	"\n your guess is too low."
high:	.asciiz "\n your guess is too high."
congrat:.asciiz	"\n\n Congratulation! You win!."
comfort:.asciiz "\n\n You lose. The number was "
	.text
	li	$v0, 30
	syscall
	li	$v0, 40
	move	$a1, $a0
	move	$a0, $0
	syscall
	li	$v0, 42
	move	$a0, $0
	li	$a1, 10
	syscall
	move	$s0, $a0
	la	$a1, cases
	li	$t0, 3
loop:	beqz	$t0, lose
	li	$v0, 4
	la	$a0, prompt
	syscall
	li	$v0, 5
	syscall
	blez	$v0, loop
	bgt	$v0, 9, loop
	sub	$v0, $v0, $s0 
	sll	$t1, $v0, 2
	add	$t1, $a1, $t1
	lw	$t2, 0($t1)
	addi	$t0, $t0, -1
	li	$v0, 4
	jr	$t2
less:	la	$a0, low
	syscall
	b	loop
greater:la	$a0, high
	syscall
	b	loop
win:	la	$a0, congrat
	syscall
	b	end
lose:	la	$a0, comfort
	syscall
	li	$v0, 1
	move	$a0, $s0
	syscall
end:	li	$v0, 10
	syscall
	