.data

arr: 	.word	3, 8, 12, -1

	.text
	li	$s3, 0
	la 	$s6, arr
	li	$s5, -1
	
loop:	sll 	$t1, $s3, 2
	add	$t1, $t1, $s6
	lw	$t0, ($t1)
	beq	$t0, $s5, exit 
	addi	$s3, $s3, 1
	j	loop
	
exit: 	li	$v0, 10
	syscall