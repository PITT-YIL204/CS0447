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
		.macro	tensor_get (%addr, %label, %index)
		m_extend_stack
		move	$v0, %addr
		move	$v1, %index
		la	$a0, %label
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
		.data
Tensor:		.word	4, 3, 33, 2, 233		#tensor-lable:	align, dim, l1, l2, l3
		.text
_tensor:	lw	$t0, 4($a0)
		lw	$t1, 0($a0)
		sw	$t1, 0($a0)
		move	$t3, $a0
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



















