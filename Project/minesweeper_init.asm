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

		.macro	_cpy_4 (%opr, %off)
		lw	$t2, %off($t3)
		sw	$t2, %off($t4)
		%opr	$t3, $t3, 4
		%opr	$t4, $t4, 4
		.end_macro	
		.macro	_clr_4 (%opr, %off)
		sw	$0, %off($t3)
		%opr	$t3, $t3, 4
		.end_macro
		.macro	_set_4 (%opr, %off)
		sw	$t5, %off($t3)
		%opr	$t3, $t3, 4
		.end_macro		
		.macro	_cpy_32 (%op, %of, %form)
		%form (%op, %of)
		%form (%op, %of)
		%form (%op, %of)
		%form (%op, %of)
		%form (%op, %of)
		%form (%op, %of)
		%form (%op, %of)
		%form (%op, %of)
		.end_macro	
		.macro	_cpy_256 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		_cpy_32 (%op, %of, %form)
		.end_macro	
		.macro	_cpy_1024 (%op, %of, %form)
		_cpy_256 (%op, %of, %form)
		_cpy_256 (%op, %of, %form)
		_cpy_256 (%op, %of, %form)
		_cpy_256 (%op, %of, %form)
		.end_macro
		.macro	_set_meta (%addr, %free, %prev, %size)
		sw	%free, 0(%addr)
		sw	%prev, 4(%addr)
		sw	%size, 8(%addr)
		.end_macro	
		.macro	m_extend_stack
		subiu 	$sp, $sp 4
		sw   	$fp, 0($sp)
		move 	$fp, $sp
		subiu 	$sp, $sp 32
		sw	$v0, -4($fp)
		sw	$v1, -8($fp)
		sw	$a0, -12($fp)
		sw	$a1, -16($fp)
		sw	$t1, -20($fp)
		sw	$t2, -24($fp)
		sw	$t3, -28($fp)
		sw	$t0, -32($fp)
		.end_macro	
		.macro	m_shrink_stack
		sw	$v0, _rev
		sw	$v1, _rev+4
		lw	$v0, -4($fp)
		lw	$v1, -8($fp)
		lw	$a0, -12($fp)
		lw	$a1, -16($fp)
		lw	$t1, -20($fp)
		lw	$t2, -24($fp)
		lw	$t3, -28($fp)
		lw	$t0, -32($fp)
		lw	$fp, 0($fp)
		addiu	$sp, $sp, 36
		.end_macro
		.macro	extend_stack
		subiu 	$sp, $sp 4
		sw   	$fp, 0($sp)
		move 	$fp, $sp
		subiu 	$sp, $sp 60
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
		lw	$sp, 0($sp)
		addiu	$sp, $sp, 4
		lw 	$fp, 0($fp)
		.end_macro
		.macro	call (%label, %arg0, %arg1, %arg2, %arg3, %alloc)
		extend_stack
		sw	%arg0, _rev
		sw	%arg1, _rev+4
		sw	%arg2, _rev+8
		sw	%arg3, _rev+12
		li	$a0, %alloc
		addiu	$a0, $a0, 4
		subu	$sp, $sp, $a0
		sw	$fp, 0($sp)
		lw	$a0, _rev
		lw	$a1, _rev+4
		lw	$a2, _rev+8
		lw	$a3, _rev+12
		jal	%label
		.end_macro
		.macro	calr (%reg, %arg0, %arg1, %arg2, %arg3, %alloc)
		extend_stack
		sw	%arg0, _rev
		sw	%arg1, _rev+4
		sw	%arg2, _rev+8
		sw	%arg3, _rev+12
		li	$a0, %alloc
		addiu	$a0, $a0, 4
		subu	$sp, $sp, $a0
		sw	$fp, 0($sp)
		lw	$a0, _rev
		lw	$a1, _rev+4
		lw	$a2, _rev+8
		lw	$a3, _rev+12
		jalr	$t9
		.end_macro	
		.macro	return
		la	$a0, _rev
		sw	$v0, 0($a0)
		sw	$v1, 4($a0)
		shrink_stack
		jr	$s7
		.end_macro	
		.macro	collect (%reg0, %reg1)
		la	%reg0, _rev
		lw	%reg1, 4(%reg0)
		lw	%reg0, 0(%reg0)
		.end_macro
		.macro	sys (%code, %arg0, %arg1)
		m_extend_stack
		move	$a0, %arg0
		move	$a1, %arg1
		li	$v0, %code
		syscall
		move	$v1, $a0
		sw	$a1, _rev+8
		m_shrink_stack
		.end_macro
		.macro	print_c (%c)
		sys (11, %c, $0)
		.end_macro	
		.macro	print_char (%char)
		m_extend_stack
		addiu	$a0, $0, %char
		sys (11, $a0, $0)
		m_shrink_stack
		.end_macro
		.macro	print_s (%s)
		sys (4, %s, $0)
		.end_macro	
		.macro	print_i (%reg)
		sys (1, %reg, $0)
		.end_macro		
		.macro	print_u (%reg)
		sys (36, %reg, $0)
		print_char (10)
		.end_macro
		.macro	print_hex (%reg)
		sys (34, %reg, $0)
		print_char (10)
		.end_macro		
		.macro time(%offset, %reg)
		sys (30, $0, $0)
		lw	%reg, _rev+4
		addiu	%reg, %reg, %offset
		.end_macro
		.macro srand (%seed)
		sys (40, $0, %seed)
		.end_macro	
		.macro	rand (%reg)
		sys (41, $0, $0)
		lw	%reg, _rev+4
		.end_macro	
		.macro	RAND_MAX
		0xffffffff
		.end_macro
		.macro randr (%u, %reg)
		sys (42, $0, %u)
		lw	%reg, _rev+4
		.end_macro		
		.macro	sleep (%ms)
		addiu	$s7, $0, %ms
		sys (32, $s7, $0)
		.end_macro
		.macro exit
		sys (10, $0, $0)
		.end_macro	
		.macro struct (%label)
		m_extend_stack
		la	$a0, %label
		call (_struct, $a0, $0, $0, $0, 0)
		m_shrink_stack
		.end_macro
		.macro	sizeof (%struct, %reg)
		lw	%reg, %struct+4
		.end_macro	
		.macro	sizeofv (%struct, %reg)
		lw	%reg, 4(%struct)
		.end_macro	
		.macro	elem (%tag, %addr, %reg)
		lw	%reg, %tag
		addu	%reg, %reg, %addr
		.end_macro
		.macro	tensor (%label)
		m_extend_stack
		la	$v0, %label
		call (_tensor, $v0, $0, $0, $0, 0)
		m_shrink_stack
		.end_macro	
		.macro	iter (%addr, %label, %dir, %step)
		sw	%dir, _rev
		addiu	%dir, %dir, 2
		sll	%dir, %dir, 2
		lw	%dir, %label(%dir)
		mulu	%dir, %dir, %step
		addu	%addr, %addr, %dir
		lw	%dir, _rev
		.end_macro
		.macro	iterv (%addr, %tens, %dir, %step)
		sw	%dir, _rev
		addiu	%dir, %dir, 2
		sll	%dir, %dir, 2
		addu	%dir, %dir, %tens
		lw	%dir, 0(%dir)
		mulu	%dir, %dir, %step
		addu	%addr, %addr, %dir
		lw	%dir, _rev
		.end_macro
		.macro	tensor_get (%addr, %label, %index)
		m_extend_stack
		move	$v0, %addr
		move	$v1, %index
		la	$a0, %label
		call (_tensor_get, $v0, $a0, $v1, $0, 0)
		collect ($v0, $0)
		m_shrink_stack
		.end_macro	
		.macro	tens_get (%addr, %tens, %index)
		m_extend_stack
		move	$v0, %addr
		move	$v1, %index
		move	$a0, %tens
		call (_tensor_get, $v0, $a0, $v1, $0, 0)
		collect ($v0, $0)
		m_shrink_stack
		.end_macro	
		.macro	tensor_index (%addr, %label, %ele, %index)
		m_extend_stack
		move	$v0, %index
		move	$v1, %ele
		move	$a0, %addr
		la	$a1, %label
		call (_tensor_index, $a0, $a1, $v1, $v0, 0)
		m_shrink_stack
		.end_macro	
		.macro	tens_index (%addr, %tens, %ele, %index)
		m_extend_stack
		move	$v0, %index
		move	$v1, %ele
		move	$a0, %addr
		move	$a1, %tens
		call (_tensor_index, $a0, $a1, $v1, $v0, 0)
		m_shrink_stack
		.end_macro
		.macro	sbrk (%byte, %reg)
		lw	%reg, _heap+8
		sw	%reg, _heap
		sys (9, %byte, $0)
		collect (%reg, $0)
		sw	%reg, _heap+8
		.end_macro
		.macro compare (%n0, %n1)
		m_extend_stack
		slt	$v0, %n0, %n1
		subiu	$v0, $v0, 1
		and	$v1, $v0, %n1
		slt	$v0, %n1, %n0
		subiu	$v0, $v0, 1
		and	$v0, $v0, %n0
		addu	$v0, $v0, $v1
		addu	$v1, %n0, %n1
		subu	$v1, $v1, $v0
		m_shrink_stack
		.end_macro	
		.macro	inverse (%reg)
		nor	%reg, %reg, $0
		addiu	%reg, %reg, 2
		.end_macro
		.macro	inrange (%va, %lo, %hi, %r)
		m_extend_stack
		slt	%r, %va, %lo
		slt	%va, %hi, %va
		or	$v0, %r, %va
		inverse ($v0)
		m_shrink_stack
		collect (%r, $0)
		.end_macro
		.macro	get_rc (%reg, %r, %c)
		andi	%r, %reg, 0xff00
		srl	%r, %r, 8
		andi	%c, %reg, 0xff
		.end_macro
		.macro	get_cmd (%reg, %cmd)
		andi	%cmd, %reg, 0xf0000000
		srl	%cmd, %cmd, 28
		subiu	%cmd, %cmd, 6
		slt	%cmd, %cmd, $0
		.end_macro	
		.macro	get_mine (%reg, %mine)
		andi	%mine, %reg, 0xff0000
		srl	%mine, %mine, 16
		.end_macro		
		.data
_heap:		.word	0, 0, 0
_Meta:		.word	3, 3
_Meta_free:	.word	4
_Meta_prev:	.word	4
_Meta_size:	.word	4
_rev:		.space	32
board_table:	.word	board_8, board_12, board_16
board_8:	.word	1, 3, 8, 8, 2
board_12:	.word	1, 3, 12, 12, 2
board_16:	.word	1, 3, 16, 16, 2
mines:		.space	84
board:		.word	0
tmp:		.space	64
lr:		.ascii	"LR"
click1:		.asciiz	"-Click at row "
click2:		.asciiz	" column "
item:		.ascii	"N123456780M"
		.text
main:		call (init, $0, $0, $0, $0, 0)
		call (game, $0, $0, $0, $0, 0)
		exit
init:		la	$s0, 0xffff8000
		time (0, $t0)
		srand ($t0)
		addiu	$s1, $0, 8
		addiu	$s2, $0, 10
		addiu	$s3, $0, 1
		addiu	$t9, $0, 1
		tensor (board_8)
		tensor (board_12)
		tensor (board_16)
		addiu	$t0, $0, 256
		call (malloc, $t0, $0, $0, $0, 0)
		collect ($t0, $0)
		sw	$t0, board
		call (reset, $0, $0, $0, $0, 0)
		return
game:		sw	$0, tmp
		sw	$0, tmp+4
		sw	$0, tmp+8
		la	$t1, tmp
		lw	$t0, board
		move	$t2, $s4
		tens_get ($t0, $t2, $t1)
		collect ($t2, $0)
		li	$t1, 0xff
game_loop:	call (memset, $t2, $s5, $t1, $0, 0)
		call (draw_board, $0, $0, $0, $0, 0)
		move	$t9, $0
game_wait:	sleep (200)
		beqz	$t9, game_wait
		call (click, $t9, $0, $0, $0, 0)
		b	game_loop
		return
click:		get_cmd ($a0, $t0)
		addu, $t1, $0, $0
		bnez	$t0, click_set
		andi	$t2, $a0, 0x0f000000
		slt	$t2, $0, $t2
		addu	$t1, $t1, $t2
		get_rc ($a0, $t3, $t4)
		lw	$t0, board
		sw	$t3, tmp
		sw	$t4, tmp+4
		sw	$s3, tmp+8
		la	$t5, tmp
		tens_get ($t0, $s4, $t5)
		collect ($t5, $0)
		lb	$t5, 0($t5)
		lb	$t5, item($t5)
		lb	$t1, lr($t1)
		la	$t6, click1
		la	$t7, click2
		print_c ($t1)
		print_s ($t6)
		print_i ($t3)
		print_s ($t7)
		print_i ($t4)
		print_char (32)
		print_char (58)
		print_char (32)
		print_c ($t5)
		print_char (10)
		return
click_set:	get_rc ($a0, $s1, $0)
		get_mine ($a0, $s2)
		call (reset, $0, $0, $0, $0, 0)
		return
draw_board:	move	$t0, $0
		move	$t1, $0
		subiu	$t8, $s0, 1
		li	$t6, 2
		sw	$0, tmp+8
		la	$t2, tmp
		lw	$t3, board
draw_column:	beq	$t0, $s1, draw_dn
		sw	$t0, tmp
		addiu	$t0, $t0, 1
draw_row:	beq	$t1, $s1, draw_rdn
		sw	$t1, tmp+4
		addiu	$t1, $t1, 1
		addiu	$t8, $t8, 1
		lb	$t4, 0($t8)
		bnez	$t4, draw_rdn
		tens_get ($t3, $s4, $t2)
		collect ($t4, $0)
		lb	$t5, 0($t4)
		iterv ($t4, $s4, $t6, 1)
		lb	$t7, 0($t4)
		and	$t5, $t5, $t7
		slti	$t4, $t5, 1
		mulu	$t4, $t4, 9
		addu	$t5, $t5, $t4
		sb	$t5, 0($t8)
		b	draw_row
draw_rdn:	move	$t1, $0
		b	draw_column
draw_dn:	return
reset:		lw	$t0, board
		subiu	$t1, $s1, 8
		lw	$t1, board_table($t1)
		move	$s4, $t1
		mulu	$s5, $s1, $s1
		sizeofv ($t1, $t2)
		call (memclr, $s0, $s5, $0, $0, 0)
		call (memclr, $t0, $t2, $0, $0, 0)
		call (setmine, $t0, $t1, $0, $0, 0)
		return
setmine:	addiu	$t1, $0, 1
		sw	$t1, tmp+8
		la	$t1, tmp
		la	$t0, mines
		move	$t2, $s2
setmine_lp:	beqz	$t2, setmine_dn
		randr ($s1, $t3)
		randr ($s1, $t4)
		sw	$t3, tmp
		sw	$t4, tmp+4
		tens_get ($a0, $a1, $t1)
		collect ($t5, $0)
		lb	$t6, 0($t5)
		bnez	$t6, setmine_lp
		addiu	$t6, $t6, 0xA
		sb	$t6, 0($t5)
		addu	$t5, $0, $t3
		sll	$t5, $t5, 8
		addu	$t5, $t5, $t4
		sw	$t5, 0($t0)
		addiu	$t0, $t0, 4
		subiu	$t2, $t2, 1
		b	setmine_lp
setmine_dn:	la	$t0, mines
		move	$t2, $s2
setsur_lp:	beqz	$t2, setsur_dn
		lw	$t1, 0($t0)
		addiu	$t0, $t0, 4
		get_rc ($t1, $t3, $t4)
		subiu	$t2, $t2, 1
		call (place_mine, $t3, $t4, $s4, $0, 0)
		b	setsur_lp
setsur_dn:	return
place_mine:	la	$t5, tmp
		subiu	$t8, $s1, 1
		addiu	$t0, $0, 1
		sw	$t0, 8($t5)
		lw	$t6, board
		addiu	$a3, $a3, 3
		subiu	$t0, $a1, 1
		inrange ($t0, $0, $t8, $t2)
		addiu	$t1, $a1, 1
		inrange ($t1, $0, $t8, $t3)
		subiu	$a0, $a0, 1
place_lp:	beqz	$a3, place_dn
		subiu	$a3, $a3, 1
		sw	$a0, tmp
		inrange ($a0, $0, $t8, $t4)
		addiu	$a0, $a0, 1
		beqz	$t4, place_lp
		sw	$a1, tmp+4
		tens_get ($t6, $a2, $t5)
		collect ($t7, $0)
		lb	$t4, 0($t7)
		beq	$t4, 0xA, place_l
		addiu	$t4, $t4, 1
		sb	$t4, 0($t7)
place_l:	beqz	$t2, place_r
		sw	$t0, tmp+4
		tens_get ($t6, $a2, $t5)
		collect ($t7, $0)
		lb	$t4, 0($t7)
		beq	$t4, 0xA, place_r
		addiu	$t4, $t4, 1
		sb	$t4, 0($t7)
place_r:	beqz	$t3, place_lp
		sw	$t1, tmp+4
		tens_get ($t6, $a2, $t5)
		collect ($t7, $0)
		lb	$t4, 0($t7)
		beq	$t4, 0xA, place_lp
		addiu	$t4, $t4, 1
		sb	$t4, 0($t7)
		b	place_lp
place_dn:	return
malloc:		lw	$t0, _heap
		bnez	$t0, _minitd
		struct (_Meta)
		sbrk ($0, $t0)
		sw	$t0, _heap
		sw	$t0, _heap+8
_minitd:	srl	$a0, $a0, 2
		addiu	$a0, $a0, 1
		sll	$a0, $a0, 2
		lw	$t1, _heap+4
		sizeof (_Meta, $t6)
		bnez	$t1, _mff_lp
_mextend:	addu	$v0, $a0, $t6
		sbrk ($a0, $v0)
		_set_meta ($v0, $0, $t0, $a0)
		addu	$v0, $v0, $t6
		return
_mff_lp:	lw	$t0, 0($t1)
		elem (_Meta_size, $t0, $t1)
		lw	$t1, 0($t1)
		slt	$t7, $t1, $a0
		bnez	$t7, _mff_fd
		move	$t5, $t0
		elem (_Meta_free, $t0, $t1)
		lw	$t1, 0($t1)
		beqz	$t1, _mextend
		b	_mff_lp
_mff_fd:	call (_mfission, $t0, $a0, $t5, $0, 0)
		addu	$v0, $t0, $t6
		return
_mfission:	lw	$t0, 0($a0)
		sw	$t0, 0($a2)
		lw	$t6, 4($a0)
		lw	$t7, 8($a0)
		sw	$0, 0($a0)
		elem (_Meta_size, $a0, $t0)
		sizeof (_Meta, $t1)
		addu	$t2, $a1, $t1
		slt	$t3, $t2, $t0
		beqz	$t3, _mfissd
		addu	$t3, $a0, $t2
		sw	$a1, 8($a0)
		lw	$t5, _heap+4
		subu	$t4, $t7, $a1
		subu	$t4, $t4, $t1
		_set_meta ($t3, $t5, $a0, $t4)
		sw	$t3, _heap+4
_mfissd:	return
free:		sizeof (_Meta, $t0)
		subu	$t1, $a0, $t0
		lw	$t5, _heap
		lw	$t4, 4($t1)
		beq	$t4, $t5, _mfused
		lw	$t3, 0($t4)
		beqz	$t3, _mfused
		lw	$t3, 8($t4)
		addu	$t3, $t3, $t2
		sw	$t3, 8($t4)
		return
_mfused:	lw	$t6, _heap+4
		sw	$t6, 0($t1)
		sw	$t1, _heap+4
		return
realloc:	move	$v0, $a0
		sizeof (_Meta, $t0)
		subu	$t1, $a0, $t0
		lw	$t2, 8($t1)
		slt	$t3, $t2, $a1
		beqz	$t3, _menough
		slt	$v0, $a1, $t2
		subiu	$v0, $v0, 1
		and	$v1, $v0, $t2
		slt	$v0, $t2, $a1
		subiu	$v0, $v0, 1
		and	$v0, $v0, $a1
		addu	$v0, $v0, $v1
		call (malloc, $a1, $0, $0, $0, 0)
		collect ($t3, $0)
		call (memcpy, $t3, $a0, $v0, $0, 0) 
		call (free, $a0, $0, $0, $0, 0)
		move	$v0, $t3
_menough:	return	
_struct:	lw	$t0, 0($a0)
		lw	$t1, 4($a0)
		subiu	$t0, $t0, 1
		addiu	$t2, $a0, 8
		move	$t3, $0
_struct_lp:	beqz	$t1, _struct_setd
		lw	$t4, 0($t2)
		subiu	$t4, $t4, 1
		srlv	$t4, $t4, $t0
		addiu	$t4, $t4, 1
		sllv	$t4, $t4, $t0
		sw	$t3, 0($t2)
		addu	$t3, $t3, $t4
		addiu	$t2, $t2, 4
		subiu	$t1, $t1, 1
		b	_struct_lp
_struct_setd:	sw	$0, 0($a0)
		sw	$t3, 4($a0)
		return
_tensor:	lw	$t0, 4($a0)
		lw	$t1, 0($a0)
		sw	$t0, 0($a0)
		addiu	$t3, $a0, 4
_tensor_lp:	beqz	$t0, _tensor_set
		subiu	$t0, $t0, 1
		addiu	$t3, $t3, 4
		lw	$t2, 0($t3)
		sw	$t1, 0($t3)
		mulu	$t1, $t1, $t2
		b	_tensor_lp
_tensor_set:	sw	$t1, 4($a0)
		return
_tensor_get:	lw	$t0, 0($a1)
		addiu	$t1, $a1, 8
		move	$v0, $0
_tens_glp:	beqz	$t0, _tens_getd
		subiu	$t0, $t0, 1
		lw	$t2, 0($t1)
		addiu	$t1, $t1, 4
		lw	$t3, 0($a2)
		addiu	$a2, $a2, 4
		mulu	$t3, $t3, $t2
		addu	$v0, $v0, $t3
		b	_tens_glp
_tens_getd:	addu	$v0, $v0, $a0
		return
_tensor_index:	lw	$t0, 0($a1)
		addiu	$t1, $a1, 4
		sll	$t2, $t0, 2
		addu	$t1, $t1, $t2
		addu	$v0, $v0, $t2
		subiu	$v0, $v0, 4
		addu	$v0, $v0, $a3
		subu	$t3, $a2, $a0
_tens_ilp:	beqz	$t0, _tens_iset
		subiu	$t0, $t0, 1
		lw	$t2, 0($t1)
		subiu	$t1, $t1, 4
		divu	$t3, $t2
		mflo	$t4
		sw	$t4, 0($v0)
		subiu	$v0, $v0, 4
		mfhi	$t3
		b	_tens_ilp
_tens_iset:	return
memset:		move	$v0, $a0
		move	$t4, $a2
		mulu	$t5, $t4, 0x01010101
		subiu	$t3, $a0, 4
		srl	$t0, $a1, 10
		sll	$t2, $t0, 10
		subu	$t1, $a1, $t2
_set_loop1:	beqz	$t0, _set_loop2
		_cpy_1024 (addiu, 4, _set_4)
		subiu	$t0, $t0, 1
		b	_set_loop1
_set_loop2:	beqz	$t1, _set_done
		sb	$t4, 4($t3)
		addiu	$t3, $t3, 1
		subiu	$t1, $t1, 1
		b	_set_loop2
_set_done:	return
memclr:		move	$v0, $a0
		subiu	$t3, $a0, 4
		srl	$t0, $a1, 10
		sll	$t2, $t0, 10
		subu	$t1, $a1, $t2
_clr_loop1:	beqz	$t0, _clr_loop2
		_cpy_1024 (addiu, 4, _clr_4)
		subiu	$t0, $t0, 1
		b	_clr_loop1
_clr_loop2:	beqz	$t1, _clr_done
		sb	$0, 4($t3)
		addiu	$t3, $t3, 1
		subiu	$t1, $t1, 1
		b	_clr_loop2
_clr_done:	return
memcpy:		move	$v0, $a0
		srl	$t0, $a2, 10
		move	$t4, $a0
		sll	$t2, $t0, 10
		subu	$t1, $a2, $t2
		addu	$t3, $a1, $a2
		slt	$t2, $a0, $t3
		bnez	$t2, _adoverlap
		subiu	$t3, $a1, 4
		subiu	$t4, $t4, 4
_cpy_loop1:	beqz	$t0, _cpy_loop2
		_cpy_1024 (addiu, 4, _cpy_4)
		subiu	$t0, $t0, 1
		b	_cpy_loop1
_cpy_loop2:	beqz	$t1, _cpy_done
		lb	$t2, 0($t3)
		sb	$t2, 0($t4)
		addiu	$t3, $t3, 1
		addiu	$t4, $t4, 1
		subiu	$t1, $t1, 1
		b	_cpy_loop2
_adoverlap:	addu	$t4, $t4, $a2
_cpy_loop3:	beqz	$t0, _cpy_loop4
		_cpy_1024 (subiu, -4, _cpy_4)
		subiu	$t0, $t0, 1
		b	_cpy_loop3
_cpy_loop4:	beqz	$t1, _cpy_done
		lb	$t2, -1($t3)
		sb	$t2, -1($t4)
		subiu	$t3, $t3, 1
		subiu	$t4, $t4, 1
		subiu	$t1, $t1, 1
		b	_cpy_loop2
_cpy_done:	return
		
