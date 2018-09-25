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
	numString:	.asciiz	"How many strings do you have?: "
	enterString:	.asciiz	"Please enter a string: "
	theString1:	.asciiz	"The string at index "
	theString2:	.asciiz	" is \""
	theString3:	.asciiz "\"\n"
	result1:	.asciiz "The index of the string \""
	result2:	.asciiz "\" is "
	result3:	.asciiz	".\n"
	notFound1:	.asciiz	"Could not find the string \""
	notFound2:	.asciiz "\".\n"
	buffer:	.space	100
.text
	# Ask for the number of strings
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, numString		# Set the string to print to numString
	syscall				# Print "How many..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read integer
	add  $s0, $zero, $v0		# $s0 is the number of strings
	# Allocate memory for an array of strings
	addi $v0, $zero, 9		# Syscall 9: Allocate memory
	sll  $a0, $s0, 2		# number of bytes = number of strings * 4
	syscall				# Allocate memeory
	add  $s1, $zero, $v0		# $s1 is the address of the array of strings
	# Loop n times reading strings
	add  $s2, $zero, $zero		# $s2 counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
readStringLoop:
	beq  $s2, $s0, readStringDone	# Check whether $s2 == number of strings
	add  $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, enterString		# Set the string to print to enterString
	syscall				# Print "Please enter..."
	jal  _readString		# Call _readString function
	sw   $v0, 0($s3)		# Store the address of a string into the array of strings
	addi $s3, $s3, 4		# Increase the address of the array of strings by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    readStringLoop		# Go back to readStringLoop
readStringDone:
	# Print all strings
	add  $s2, $zero, $zero		# $s2 - counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
printStringLoop:
	beq  $s2, $s0, printStringDone	# Check whether $s2 == number of strings
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, theString1		# Set the string to print to theString1
	syscall				# Print "The string..."
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s2		# Set the integer to print to counter (index)
	syscall				# Print the current index
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, theString2		# Set the address of the string to print to theString2
	syscall				# Print " is ""
	lw   $a0, 0($s3)		# Set the address by loading the address from the array of string
	syscall				# Print the string
	la   $a0, theString3		# Set the address of the string to print to theString3
	syscall				# Print ""\n"
	addi $s3, $s3, 4		# Increase the address of the array of string by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    printStringLoop		# Go back to printStringLoop
printStringDone:
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, enterString		# Set the address of the string to print to enterString
	syscall				# Print "Please enter..."
	jal  _readString			# Call the _readString function
	add  $s4, $zero, $v0		# $s4 is the address of a new string
	# Search for the index of a given string
	add  $s2 $zero, $zero		# $s2 - counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
	addi $s5, $zero, -1		# Set the initial result to -1
searchStringLoop:
	beq  $s2, $s0, searchStringDone	# Check whether $s2 == number of strings
	lw   $a0, 0($s3)		# $a0 is a string in the array of strings
	add  $a1, $zero, $s4		# $s1 is a string the a user just entered
	jal  _strCompare		# Call the _strCompare function
	beq  $v0, $zero, found		# Check whether the result is 0 (found)
	addi $s3, $s3, 4		# Increase the address by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    searchStringLoop		# Go back to searchStringLoop
found:
	add  $s5, $zero, $s2		# Set the result to counter
	# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, result1		# Set the address of the string to print to result1
	syscall				# Print "The index ..."
	add  $a0, $zero, $s4		# Set the address of the string to print to the string that a user jsut entered
	syscall				# Print the string that a user just entered
	la   $a0, result2		# Set the address of the string to print to result2
	syscall				# Print " is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s5		# Set the integer to print
	syscall				# Print index
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, result3		# Set the address of the string to print to result3
	syscall				# Print ".\n"
	j    terminate
searchStringDone:
	# Not found
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, notFound1		# Set the address of the string to print to notFound1
	syscall				# Print "Could not..."
	add  $a0, $zero, $s4		# Set the address of the string to print to a new string
	syscall				# Print the new string
	la   $a0, notFound2		# Set the address of the string to print to notFound2
	syscall
terminate:
	addi $v0, $zero, 10		# Syscall 10: Terminate Program
	syscall				# Terminate Program

# _readString
#
# Read a string from keyboard input using syscall # 5 where '\n' at
# the end will be eliminated. The input string will be stored in
# heap where a small region of memory has been allocated. The address
# of that memory is returned.
#
# Argument:
#   - None
# Return Value
#   - $v0: An address (in heap) of an input string
_readString:
	li	$a0, 128
	li	$v0, 9
	syscall
	subiu	$a1, $a0, 8
	addiu	$a0, $v0, 8
	li	$v0, 8
	syscall
	li	$t0, 0
	move	$v0, $a0
	move	$t1, $v0
	lb	$t2, 0($t1)
inprocess:
	addu	$t0, $t0, $t2
	mulu	$t0, $t0, 33
	addiu	$t1, $t1, 1
	lb	$t2, 0($t1)
	bnez	$t2, inprocess
	sw	$t0, -8($v0)
	subu	$t0, $t1, $v0
	subiu	$t1, $t1, 1
	sb	$0, 0($t1)
	subiu	$t0, $t0, 1
	sw	$t0, -4($v0)
	jr   $ra
		
# _strCompare
#
# Compare two null-terminated strings. If both strings are idendical,
# 0 will be returned. Otherwise, -1 will be returned.
#
# Arguments:
#   - $a0: an address of the first null-terminated string
#   - $a1: an address of the second null-terminated string
# Return Value
#   - $v0: 0 if both string are identical. Otherwise, -1
_strCompare:
	lw	$t1, -8($a0)
	lw	$t2, -8($a1)
	seq	$t0, $t1, $t2
	subiu	$v0, $t0, 1
	jr   $ra

# _strCopy
#
# Copy from a source string to a destination.
#
# Arguments:
#   - $a0: An address of a destination
#   - $a1: An address of a source
# Return Value:
#   None
_strCopy:
	move	$t0, $a0
	move	$t1, $a1
	lw	$t2, -4($a0)
	lw	$t3, -4($a1)
	slt	$t4, $t2, $t3
	nor	$t4, $t4, $0
	addiu	$t4, $t4, 1
	and	$t5, $t4, $t2
	addiu	$t4, $t4, 1
	nor	$t4, $t4, $0
	addiu	$t4, $t4, 1
	and	$t6, $t4, $t3
	add	$t4, $t5, $t6
	addu	$t9, $t1, $t4
	slt	$t8, $t0, $t9
	slt	$t9, $t1, $t0
	and	$t9, $t8, $t9
	divu	$t5, $t4, 4
	bnez	$t9, overlap
	subu	$t4, $t4, $t5
loop1:	beqz	$t5, loop4
	subiu	$t5, $t5, 1
	lw	$t9, 0($t1)
	sw	$t9, 0($t0)
	addiu	$t1, $t1, 4
	addiu	$t0, $t0, 4
	b	loop1
loop4:	beqz	$t4, cpdone
	subiu	$t4, $t4, 1
	lb	$t9, 0($t1)
	sb	$t9, 0($t0)
	addiu	$t1, $t1, 1
	addiu	$t0, $t0, 1
	b	loop4
overlap:addu	$t0, $t0, $t4
	addu	$t1, $t1, $t4
	subu	$t4, $t4, $t5
loop2:	beqz	$t5, loop3
	subiu	$t5, $t5, 1
	lw	$t9, -4($t1)
	sw	$t9, -4($t0)
	subiu	$t1, $t1, 4
	subiu	$t0, $t0, 4
	b	loop2
loop3:	beqz	$t4, cpdone
	subiu	$t4, $t4, 1
	lb	$t9, -1($t1)
	sb	$t9, -1($t0)
	subiu	$t1, $t1, 1
	subiu	$t0, $t0, 1
	b	loop3
cpdone:	jr   $ra

# _strLength
#
# Measure the length of a null-terminated input string (number of characters).
#
# Argument:
#   - $a0: An address of a null-terminated string
# Return Value:
#   - $v0: An integer represents the length of the given string
_strLength:
	lw	$v0, -4($a0)
	jr   $ra
