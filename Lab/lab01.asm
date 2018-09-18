		.text
		li	$v0, 32
		li	$a0, 500
		li 	$s0, 0
		li	$t1, 3
loop:		div 	$s0, $t1
		mfhi	$s1
		addi	$t9, $s1, -1
		addi	$s0, $s0, 1
		syscall
		b 	loop