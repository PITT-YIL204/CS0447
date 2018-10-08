		.macro	tensor (%label)
		m_extend_stack
		la	$v0, %label
		call (_tensor, $v0, $0, $0, $0, 0)
		m_shrink_stack
		.end_macro	
		.macro	iter (%addr, %label, %dir, %step)
		addiu	%dir, %dir, 2
		sll	%dir, %dir, 2
		lw	%dir, %label(%dir)
		mulu	%dir, %dir, %step
		addu	%addr, %addr, %dir
		.end_macro	
		.data
Tensor:		.word	4, 3, 33, 2, 233		#tensor-lable:	align, dim, l1, l2, l3
		.text
_tensor:	lw	$t0, 4($a0)
		lw	$t1, 0($a0)
		move	$t3, $a0
_tensor_lp:	beqz	$t0, _tensor_set
		subiu	$t0, $t0, 1
		addiu	$t3, $t3, 4
		lw	$t2, 0($t3)
		sw	$t1, 0($t3)
		mulu	$t1, $t1, $t2
		b	_tensor_lp
_tensor_set	sw	$t1, 4($a0)
		return