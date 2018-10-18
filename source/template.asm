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
		subiu 	$sp, $sp 28
		sw	$v0, -4($fp)
		sw	$v1, -8($fp)
		sw	$a0, -12($fp)
		sw	$a1, -16($fp)
		sw	$t1, -20($fp)
		sw	$t2, -24($fp)
		sw	$t3, -28($fp)
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
		lw	$fp, 0($fp)
		addiu	$sp, $sp, 32
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
		sw	$v0, _rev
		sw	$a0, _rev+4
		sw	$a1, _rev+8
		m_shrink_stack
		.end_macro
		.macro	print_char (%char)
		m_extend_stack
		addiu	$a0, $0, %char
		sys (11, $a0, $0)
		m_shrink_stack
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
		m_extend_stack
		move	$a1, %seed
		sys (40, $0, $a1)
		m_shrink_stack
		.end_macro	
		.macro	rand (%reg)
		sys (41, $0, $0)
		lw	%reg, _rev+4
		.end_macro	
		.macro randr (%u, %reg)
		sys (42, $0, %u)
		lw	%reg, _rev+4
		.end_macro	
		.macro	RAND_MAX
		0xffffffff
		.end_macro	
		.macro	sleep (%ms)
		sys (32, %ms, $0)
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
		nor	$v0, %r, %va
		m_shrink_stack
		collect (%r, $0)
		.end_macro	
		# macro start
		
		# macro end
		.data
_heap:		.word	0, 0, 0
_Meta:		.word	3, 3
_Meta_free:	.word	4
_Meta_prev:	.word	4
_Meta_size:	.word	4
_rev:		.space	32
		# data start
			#tensor-lable:	align, dim, l1, l2, l3
			
			#struct:	align, size	
			#struct_e1: 	l1 
			#struct_e2: 	l2	
			#align = 2^(align-1), size = in #elem -> in byte, l: ele size -> offset

		# data end
		.text
main:		# functions start

		# functions end
		exit
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
		
