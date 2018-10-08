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
		sw	$v0, rev
		sw	$v1, rev+4
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
		.macro	sys (%code, %arg0, %arg1)
		m_extend_stack
		li	$v0, %code
		move	$a0, %arg0
		move	$a1, %arg1
		syscall
		sw	$v0, rev
		sw	$a0, rev+4
		sw	$a1, rev+8
		m_shrink_stack
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
		.macro	elem (%tag, %addr, %reg)
		m_extend_stack
		#la	$v0, %struct
		#addiu	$v0, $v0, 8
		#li	$t0, %pos
		#sll	$t0, $t0, 2
		#addu	$v0, $v0, $t0
		lw	$v0, %tag
		addu	$v0, $v0, %addr
		m_shrink_stack
		collect (%reg, $0)
		.end_macro	
		.data
rev:		.space 32
#struct:	.word	align, size, l1, l2, l3		#align = 2^(align-1), size = in #elem -> in byte, l: ele size -> offset
Test:		.word	3, 3
Test_ele1:	.word	1 
Test_ele2:	.word	4 
Test_ele3:	.word	2
		.text
main:		struct (Test)
		sizeof (Test, $s0)
		sys (36, $s0, $0)
		sys (9, $s0, $0)
		collect ($s1, $0)
		sb	$s0, 0($s1)
		elem (Test_ele2, $s1, $t0)
		sw	$s1, 0($t0)
		elem (Test_ele3, $s1, $t0)
		sh	$0, 0($t0)
		sys (10, $0, $0)
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
		
