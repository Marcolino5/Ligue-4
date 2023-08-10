CONVERT:
	addi sp, sp, -4
	sw t1, (sp)
	
	li t1, 48
	ble a0, t1, CONVERTend
	li t1, 56 
	bge a0, t1, CONVERTend
	Convert1:
		li t1, 49
		bne a0, t1, Convert2
		li a0, 1
		j CONVERTreturn	
	Convert2:
		li t1, 50
		bne a0, t1, Convert3
		li a0, 2
		j CONVERTreturn	
	Convert3:
		li t1, 51
		bne a0, t1, Convert4
		li a0, 3
		j CONVERTreturn	
	Convert4:
		li t1, 52
		bne a0, t1, Convert5
		li a0, 4
		j CONVERTreturn	
	Convert5:
		li t1, 53
		bne a0, t1, Convert6
		li a0, 5
		j CONVERTreturn	
	Convert6:
		li t1, 54
		bne a0, t1, Convert7
		li a0, 6
		j CONVERTreturn	
	Convert7:
		li t1, 55
		li a0, 7
		j CONVERTreturn	
CONVERTend:
	li a0, 0
CONVERTreturn:
	lw t1, (sp)
	addi sp, sp, 4
	ret
