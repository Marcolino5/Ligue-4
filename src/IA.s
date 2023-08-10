IA:
	
	li t0, 4
	beq s2, t0, IAultrafacil
	li t0, 3
	beq s2, t0, IAfacil
	li t0, 2
	beq s2, t0, IAmedio
	li t0, 1
	beq s2, t0, IAdificil

IAultrafacil:
	# Calculo de tempo, instruções e ciclos
	csrr s5, instret
	csrr s6, cycle
	csrr s7, time
	
	la t0, EASYIA
    	lb a0,0(t0)
    	li t1,7
    	mv t2,a0
    	addi t2,t2,1
	rem t1,t2,t1
    	sb t1,0(t0)
    	
    	# Calculo de tempo, instruções e ciclos
	csrr t0, time
	csrr t2, cycle
	csrr t1, instret
	
	sub s7, t0, s7	# s7 = tempo
	sub s5, t1, s5	# s5 = instruçoes
	sub s6, t2, s6 # s6 = ciclos
	
    	j COLOCApeca_IA
IAfacil:
	# Calculo de tempo, instruções e ciclos
	csrr s5, instret
	csrr s6, cycle
	csrr s7, time
	
	# IA
	csrr t4, time
	li t1, 7
	rem a0, t4, t1
	
	# Calculo de tempo, instruções e ciclos
	csrr t0, time
	csrr t2, cycle
	csrr t1, instret
	
	sub s7, t0, s7	# s7 = tempo
	sub s5, t1, s5	# s5 = instruçoes
	sub s6, t2, s6 # s6 = ciclos
	
	j COLOCApeca_IA
	
IAmedio:
	addi sp, sp, -4
	sw ra, (sp)
	
	# Calculo de tempo, instruções e ciclos
	csrr s5, instret
	csrr s6, cycle
	csrr s7, time
	
	li a5, 0	# contador de peças
	li a4, 0	# maior número entre as peças
	IAmedio_start:
	la s3, MATRIZ
	li t2, 0	# contador adicional
	
	IAmedio_for:
		li t1, 7
		bge a5, t1, IAmedio_end
		# argumentos: s3 = matriz atual, a2 = cor da peça a ser verificada, a5 = posição da peça (0-6)
		# formar uma linha de 4 -> 3 -> 2 -> aleatorio
		
		add s3, s3, a5		# coloca s3 na posição inicial
		
		la t1, MATRIZ
		addi t1, t1, 41
		bgt s3, t1, IAmedio_end
			
		lb t1, (s3)		# recebe valor na posição
		
		bnez t1, forIAmedio	# verifica se há 0 na posição (é uma posição possível para a peça?)	
		
		IAmedio_forCONT:
				
		li a2, 1
		bne s1, a2, IAmedio_forCONT2
		li a2, 2
		IAmedio_forCONT2:
		
		li a6, 1		# determina que é verificação da IA 
		call VERIFICAtabuleiroIA # retorna em a0 a coluna com maior probabilidade de vitória
		
		addi a5, a5, 1
		j IAmedio_start
		
		forIAmedio:
			sub s3, s3, a5
			addi s3, s3, 7
			
			li t1, 6
			addi t2, t2, 1	# aumenta no contador
			
			bne t1, t2, IAmedio_for
			addi a5, a5, 1
			
			j IAmedio_start
IAmedio_end:
	
	# Calculo de tempo, instruções e ciclos
	csrr t0, time
	csrr t2, cycle
	csrr t1, instret
	
	sub s7, t0, s7	# s7 = tempo
	sub s5, t1, s5	# s5 = instruçoes
	sub s6, t2, s6 # s6 = ciclos
	
	lw ra, (sp)
	addi sp, sp, 4
		
	j COLOCApeca_IA
	
IAdificil:
	# evitar que o jogador ganhe
	# formar uma linha de 4 -> 3 -> 2 -> centralizado
	
	addi sp, sp, -4
	sw ra, (sp)
	
	# Calculo de tempo, instruções e ciclos
	csrr s5, instret
	csrr s6, cycle
	csrr s7, time
	
	li a5, 0	# contador de peças
	li a4, 0	# maior número entre as peças
	li a7, 1	# define que não fez modificação por possibilidade de vitória do usuário
	IAdificil_start:
	la s3, MATRIZ
	li t2, 0	# contador adicional
	
	IAdificil_for:
		li t1, 7
		bge a5, t1, IAdificil_end
		# argumentos: s3 = matriz atual, a2 = cor da peça a ser verificada, a5 = posição da peça (0-6)
		# formar uma linha de 4 -> 3 -> 2 -> aleatorio
		
		add s3, s3, a5		# coloca s3 na posição inicial
		
		la t1, MATRIZ
		addi t1, t1, 41
		bgt s3, t1, IAdificil_end
		
		lb t1, (s3)		# recebe valor na posição
		
		bnez t1, forIAdificil	# verifica se há 0 na posição (é uma posição possível para a peça?)	
		
		IAdificil_forCONT:
				
		li a2, 1
		bne s1, a2, IAdificil_forCONT2
		li a2, 2
		IAdificil_forCONT2:
		
		li a6, 1		# determina que é verificação da IA 
		call VERIFICAtabuleiroIA# retorna em a0 a coluna com maior probabilidade de vitória para IA, focando no centro
		
		add a2, s1, zero
		li a6, 0		# determina que é verificação do usuário
		call VERIFICAtabuleiroIA# faz verificação do usuário -> se IA não ganha nessa rodada e o usuário ganha na próxima,
					# a posição de vitória do usuário tem prioridade. retorna a0 a coluna
		
		addi a5, a5, 1
		j IAdificil_start
		
		forIAdificil:
			sub s3, s3, a5
			addi s3, s3, 7
			
			li t1, 6
			addi t2, t2, 1	# aumenta no contador
			bne t1, t2, IAdificil_for
			addi a5, a5, 1
			
			j IAdificil_start
IAdificil_end:

	# Calculo de tempo, instruções e ciclos
	csrr t0, time
	csrr t2, cycle
	csrr t1, instret
	
	sub s7, t0, s7	# s7 = tempo
	sub s5, t1, s5	# s5 = instruçoes
	sub s6, t2, s6 # s6 = ciclos
	
	lw ra, (sp)
	addi sp, sp, 4
	
	j COLOCApeca_IA
	
COLOCApeca_IA:
	
	mv t4, a0
	addi s5, s5, -4		# retira erro da quantidade de instrucoes
	addi s6, s6, -10	# retira erro da quantidade de ciclos
	
	fcvt.s.w ft1, s5	# instrucoes em float
	fcvt.s.w ft2, s6 	# ciclos em float
	fcvt.s.w ft0, s7	# tempo em float
	
	add a0, s5, zero
	li a1, 155
	li a3, 255
	li a4, 1
	li a2, 42
	li a7, 101
	ecall
	add a0, s7, zero
	li a1, 155
	li a2, 62
	ecall
	add a0, s6, zero
	li a1, 155
	li a2, 22
	ecall
	
	fdiv.s fa0, ft2, ft1	# CPI media (ciclos por instrucoes)
	li a1, 155
	li a3, 255
	li a4, 1
	li a2, 82
	li a7, 102
	ecall
	
	mv a0, t4
	
	la s3, MATRIZ
	li t2, 0
	li t4, 0xFF00FB56
	
	COLOCApeca_IAcont:
		li t1, 40
		add t3, a0, zero
		mul t3, t3, t1
		add t4, t4, t3
		
		add s3, s3, a0
		lb t1, (s3)	# recebe o valor na coluna
		
		bnez t1, forIA
		
		addi sp, sp, -8
		sw ra, (sp)
		sw a0, 4(sp)
		
		li t1, 1
		la a0, PeçaAmarela
		li a2, 1
		bne s1, t1, poeIAcont
		li t1, 2
		la a0, PeçaVermelha
		li a2, 2
		poeIAcont:
		sb t1, (s3)
		
		
		call poePEÇA	# poe peça
		
		mv a1, t4	# coloca endereço em a1
		li a4, 36
		li a6, 36
		call PRINTh	# imprime peça na tela na posição especificada
		
		lw ra, (sp)
		lw a0, 4(sp)
		addi sp, sp, 8
		
		ret
		forIA:
			sub s3, s3, a0
			addi s3, s3, 7
			
			li t1, 40
			add t3, a0, zero
			mul t3, t3, t1
			sub t4, t4, t3
			
			li t1, -12800
			add t4, t4, t1
			
			addi t2, t2, 1
			li t3, 6
			bne t2, t3, COLOCApeca_IAcont
			j IA

# argumentos: s3 = matriz atual, a2 = cor da peça a ser verificada, a5 = posição da peça (0-6)
# retorna a0 = posição 0-6 onde será jogada a peça (maior número de peças)
VERIFICAtabuleiroIA:
	VERIFICAhorizontalIA:
		
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0	# inicia contador de peças
		
		li a1, 1
		li a3, 0	# para de contar quando chega na posição 6 da matriz
		li t1, 6
		beq a5, t1, IAesquerda
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
		
	IAesquerda:	
		li a1, -1
		li a3, 1	# para de contar quando chega na posição 7 da matriz
		beqz a5, VERIFICAverticalIA
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
		
	VERIFICAverticalIA:
		li t0, 0	# limpa contador de peças
		
		li a1, 7
		li a3, 2	# não para de contar -> sem problemas com barreira
		call VERIFICAtabuleiro_forIA
		
		li a1, -7
		li a3, 2	# não para de contar -> sem probelmas com barreira
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
		
	VERIFICAdiagonalIA:
		li t0, 0	# limpa contador de peças
		
		li a1, 6
		li a3, 1	# para de contar quando chega na posição 7 da matriz
		beqz a5, IAdiagonal1
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
		
		IAdiagonal1:
		li a1, -6
		li a3, 0	# para de contar quando chega na posição 6 da matriz
		li t1, 6
		beq a5, t1, IAdiagonal2
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
		
		IAdiagonal2:
		
		li t0, 0	# limpa contador de peças
		
		li a1, 8
		li a3, 0	# para de contar quando chega na posição 6 da matriz
		li t1, 6
		beq a5, t1, IAdiagonal3
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
		
		IAdiagonal3:
		
		li a1, -8
		li a3, 1	# para de contar quando chega na posição 7 da matriz
		beqz a5, VERIFICAfinalIA
		call VERIFICAtabuleiro_forIA
		call VERIFICAquantidadeIA
	VERIFICAfinalIA:
		
		call VERIFICAquantidadeIA
		
		lw ra, (sp)
		addi sp, sp, 4
		ret
	
	VERIFICAquantidadeIA:
		li t1, 2
		beqz a6, VERIFICAquantidadeIAdU		# se estiver verificando o usuário, vai para VERIFICAquantidadeIAdU
		beq s2, t1, VERIFICAquantidadeIAm	# se for do nível médio, vai para verifica quantidade (nível médio)
		beq t0, a4, VERIFICAquantidadeIAd	# se for do nível difícil e t0 = a4, vai para nível difícil
		j VERIFICAquantidadeIAm			# caso t0 > a4 ou t0 < a4, funciona da mesma forma que nível médio
		
	VERIFICAquantidadeIAd:	# prioridades -> 3 > 4 > 2 > 5 > 1 > 6 > 0
		bnez a7, VERIFICAquantidadeIAd_cont	# se a7 é 0 e entrou, encontrou uma coluna que permite a vitória imediata da IA
		li a7, 1				# redefine a7 para 1
		j VERIFICAquantidadeIA_altera
	VERIFICAquantidadeIAd_cont:
		li t1, 3
		beq a0, t1, VERIFICAquantidadeIA_ret	# se já tem 3, não muda nada
		beq a5, t1, VERIFICAquantidadeIA_altera	# não tem 3 e a5 tem 3, portanto deve alterar
		li t1, 4
		beq a0, t1, VERIFICAquantidadeIA_ret	# se não tem 3 e já tem 4, não muda nada
		beq a5, t1, VERIFICAquantidadeIA_altera # não tem 3, não tem 4 e a5 é 4, logo muda para 4
		li t1, 2				# mesmo processo em diante...
		beq a0, t1, VERIFICAquantidadeIA_ret
		beq a5, t1, VERIFICAquantidadeIA_altera
		li t1, 5
		beq a0, t1, VERIFICAquantidadeIA_ret
		beq a5, t1, VERIFICAquantidadeIA_altera
		li t1, 1
		beq a0, t1, VERIFICAquantidadeIA_ret
		beq a5, t1, VERIFICAquantidadeIA_altera
		li t1, 6
		beq a0, t1, VERIFICAquantidadeIA_ret
		beq a5, t1, VERIFICAquantidadeIA_altera
		li t1, 0
		beq a0, t1, VERIFICAquantidadeIA_ret
		beq a5, t1, VERIFICAquantidadeIA_altera
		ret
	VERIFICAquantidadeIAm:
		li t1, 3
		bge t0, t1, VERIFICAquantidadeIA_altera
		bge t0, a4, VERIFICAquantidadeIA_altera
		ret
	VERIFICAquantidadeIAdU:
		li t1, 3
		bge a4, t1, VERIFICAquantidadeIA_ret		# se já foi definido uma posição de vitória para a IA, não muda
		beqz a7, VERIFICAquantidadeIA_ret		# se já encontrou uma posição de vitória para o usuário, não muda
		li a7, 0					# define que houve uma alteração por vitória do usuário
		beq t0, t1, VERIFICAquantidadeIA_altera		# caso contrário, se usuário vai vencer na próxima rodada, altera
		li a7, 1					# redefine que não houve
		ret

	VERIFICAquantidadeIA_altera:
		add a4, t0, zero	# define novo maior valor
		add a0, a5, zero	# muda a0 para a5 (posição sendo verificada)
	VERIFICAquantidadeIA_ret:	
		ret
		
	# a2 = cor da peça
	VERIFICAtabuleiro_forIA:
		li t5, 0		# contador adicional
		add t3, s3, zero	# coloca matriz atual em t3
		add t3, t3, a1		# vai para próxima posição
		VERIFICAtabuleiro_loopIA:
			la t1, MATRIZ
			blt t3, t1, VERIFICAtabuleiro_endIA
			addi t1, t1, 41
			bgt t3, t1, VERIFICAtabuleiro_endIA	# verifica se t3 está dentro do limite da matriz
			
			lb t1, (t3)
			bne t1, a2, VERIFICAtabuleiro_endIA	# se encontra um valor diferente da peça, termina contagem
			addi t0, t0, 1				# aumenta 1 na quantidade de peças
			
			beqz a3, VERIFICArem6IA			# verifica se chegou ao fim do tabuleiro (direita) caso a3 = 0
			li t1, 1
			beq a3, t1, VERIFICArem7IA		# verifica se chegou ao fim do tabuleiro (esquerda) caso a3 = 1
			
			VERIFICAtabuleiro_loopCONTIA:	
			add t3, t3, a1				# vai para próxima posição	
			addi t5, t5, 1				# aumenta 1 no contador
			li t1, 4	
			bne t5, t1, VERIFICAtabuleiro_loopIA	# loop enquanto não conta 4 peças
			
	VERIFICAtabuleiro_endIA:
		li t1, 3
		bge t0, t1, VERIFICAfinalIA
		ret
	VERIFICArem6IA:
		la t4, MATRIZ
		sub t4, t3, t4
		VERIFICArem6_loopIA:
			li t1, 6
			beq t4, t1, VERIFICAtabuleiro_endIA
			li t1, 7
			sub t4, t4, t1
			bgtz t4, VERIFICArem6_loopIA
		j VERIFICAtabuleiro_loopCONTIA
		
	VERIFICArem7IA:
		la t4, MATRIZ
		sub t4, t3, t4
	
		li t1, 7
		rem t1, t4, t1
		beqz t1, VERIFICAtabuleiro_endIA
		j VERIFICAtabuleiro_loopCONTIA	

