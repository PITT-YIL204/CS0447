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
		lw	$v0, -4($fp)
		lw	$v1, -8($fp)
		lw	$a0, -12($fp)
		lw	$a1, -16($fp)
		lw	$t1, -20($fp)
		lw	$t2, -24($fp)
		lw	$t3, -28($fp)
		lw	$fp, 0($fp)
		addiu	$sp, $sp, 30
		.end_macro
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
		.macro	sys (%code, %arg0, %arg1)
		m_extend_stack
		li	$v0, %code
		li	$a0, %arg0
		li	$a1, %arg1
		syscall
		sw	$v0, rev
		sw	$a0, rev+4
		sw	$a1, rev+8
		m_shrink_stack
		.end_macro	
		.macro	sbrk (%byte, %reg)
		sys (9, %byte, 0)
		collect (%reg, $0, $0)
		.end_macro	
		.data
rev:		.space	32
		.text
		.globl	malloc
		.globl	free
		.globl	realloc
initialize:	
