.data # 0 -> sem peça, 1 -> peça amarela, 2 -> peça vermelha
MATRIZ:.byte 0, 0, 0, 0, 0, 0, 0,
	     0, 0, 0, 0, 0, 0, 0,
	     0, 0, 0, 0, 0, 0, 0,
	     0, 0, 0, 0, 0, 0, 0,
	     0, 0, 0, 0, 0, 0, 0,
	     0, 0, 0, 0, 0, 0, 0
EASYIA:.byte 0, 0
FREQUENCIA: .string "FREQUENCIA =       2.5000E+1 MHz"
CICLOS: .string "CICLOS = "
INSTRUCOES: .string "INSTRUCOES ="
TEMPO1: .string "TEMPO MEDIDO =               ms"
CPI: .string "CPI MEDIA ="
TEMPO2: .string "TEMPO CALCULADO =  1.0400E-3 ms"

.include "img/press1Menu.s"
.include "img/press2Menu.s"

.include "img/Dificuldade.s"
.include "img/tileTabuleiro.s"

#################################

.include "img/PeçaAmarela.s"
.include "img/PeçaVermelha.s"

.include "img/Vitória.s"
.include "img/Derrota.s"
.include "img/Empate.s"

.text
.include "src/MACROSv21.s"
###############################
# s1 = cor do usuário         #
# s2 = dificuldade            #
# s3 = endereço atual matriz  #
# s4 = posição escolhida (0-6)#
###############################
MAIN:
	
	call LIMPAmatriz
	li a1, 0xFF000000
	call LIMPAtela
	li a1, 0xFF100000
	call LIMPAtela
	li a7, 104
	la a0, FREQUENCIA
	li a4, 1
	li a3, 255
	li a1, 2
	li a2, 2
	ecall
	la a0, CICLOS
	li a1, 2
	li a2, 22
	ecall
	la a0, INSTRUCOES
	li a1, 2
	li a2, 42
	ecall
	la a0, TEMPO1
	li a1, 2
	li a2, 62
	ecall
	la a0, CPI
	li a1, 2
	li a2, 82
	ecall
	la a0, TEMPO2
	li a1, 2
	li a2, 102
	ecall
	
	
	MENU:	
		la a0, press1Menu	# carrega endereço de menu em a0
		li a1, 0xFF0070B4	# define início da impressão de press1Menu
		li a4, 80		# largura da imagem
		li a6, 76		# altura da imagem
		call PRINT		# imprime menu na tela
		
		la a0, press2Menu	# carrega endereço de menu em a0
		li a1, 0xFF007140	# define início da impressão de menu
		li a4, 80		# largura da imagem
		li a6, 76		# altura da imagem
		call PRINT		# imprime menu na tela
		
		call INPUT		# recebe input do usuário
		
		li t0, 49			
		beq a0, t0, AMARELO	# se input = 1, cor é amarelo
		li t0, 50
		beq a0, t0, VERMELHO	# se input = 2, cor é vermelho
		
		j MENU
	AMARELO:
		li s1, 2	# define cor do usuário como amarelo
		li a0, 0
		j DIFICULDADE
		
	VERMELHO:
		li s1, 1	# define cor do usuário como vermelho
		li a0, 0
		j DIFICULDADE
	
	DIFICULDADE:
		la a0, Dificuldade	# carrega endereço de escolha de dificuldade em a0
		li a1, 0xFF000534	# define início da impressão da escolha
		li a4, 220
		li a6, 220
		call PRINT		# imprime escolha de dificuldade na tela
		
		call INPUT		# recebe input do usuário
		
		li t0, 52
		beq a0, t0, ULTRAFACIL	# se input = 4, selecionou ultrafacil (secreto)
		li t0, 51	
		beq a0, t0, FACIL	# se input = 3, selecionou fácil
		li t0, 50		
		beq a0, t0, MEDIO	# se input = 2, selecionou médio
		li t0, 49
		beq a0, t0, DIFICIL	# se input = 1, selecionou difícil
		
		j DIFICULDADE
		
	.include "src/IA.s"
	ULTRAFACIL:
		li s2, 4	# define dificuldade como ultrafácil
		li a0, 0
		j SETUP
	FACIL:
		li s2, 3	# define dificuldade como fácil
		li a0, 0
		J SETUP
	MEDIO:
		li s2, 2	# define dificuldade como médio
		li a0, 0
		j SETUP
	DIFICIL:
		li s2, 1	# define dificuldade como difícil
		li a0, 0
		j SETUP
	
	SETUP:
		call PRINTtabuleiro
	
	GAME:
	
	call INPUT		# recebe input do usuário (1-7)
  	call CONVERT		# converte o código ascii em inteiro
	
	beqz a0, GAMEcont	# verifica se a entrada é válida
	add s4, a0, zero
	addi s4, s4, -1		# guarda posição da peça (0-6)
	
	call COLOCApeca		# coloca peça do usuário
	add a2, s1, zero	# coloca cor da peça em a2
	call VERIFICAtabuleiro	# verifica se usuário ganhou
	beq a0, zero, VITÓRIA	# se usuário ganhou, vai para vitórial
	
	call IA 		# faz movimento da IA de acordo com dificuldade escolhida
	add s4, a0, zero	# guarda posição da peça (0-6)
	
	call VERIFICAtabuleiro	# verifica se IA ganhou
	beq a0, zero, DERROTA	# se IA ganhou, vai para derrota
	
	call VERIFICAmatriz
	beq a0, zero, EMPATE
	
	GAMEcont:
	li a0, 0
	j GAME
	
COLOCApeca:
	la s3, MATRIZ
	li t2, 0 	# contador de linhas
	li t4, 0xFF00FB56
	
	COLOCApeca_cont:
		li t1, 40	# espaçamento entre peças
		addi t3, a0, -1	# define t3 como a0-1 (converte 7-1 em 6-0)
		mul t3, t3, t1	# calcula espaçamento total
		add t4, t4, t3	# adiciona espaçamento ao endereço
		
		add s3, s3, a0	# adiciona a0 na matriz
		addi s3, s3, -1 # converte 7-1 em 6-0
		lb t1, (s3)	# recebe o valor da posição
		
		bnez t1, FOR	# caso não tenha valor 0 (sem peça), vai para FOR
		
		addi sp, sp, -8	# salva ra e a0
		sw ra, (sp)
		sw a0, 4(sp)
		
		add a2, a0, zero
		# t4 = endereço inicial do print
		call achaPEÇA	# define cor da peça com base na escolha do usuário
		call poePEÇA	# poe peça
		
		mv a1, t4	# coloca endereço em a1
		li a4, 36
		li a6, 36
		call PRINTh	# imprime peça na tela na posição especificada
		
		lw ra, (sp)
		lw a0, 4(sp)
		addi sp, sp, 8	# retorna valor antigo de ra e a0
		
		sb s1, (s3)	# coloca peça na matriz
		
		ret
		FOR:
			sub s3, s3, a0
			addi s3, s3, 1	# retorna à posição antiga de s3
			
			li t1, 40
			addi t3, a0, -1
			mul t3, t3, t1
			sub t4, t4, t3	# retorna à posição antiga de t4
			
			li t1, -12800
			add t4, t4, t1	# sobe uma casa do tabuleiro para t4
			
			addi s3, s3, 7	# sobe uma linha na matriz para s3
			
			addi t2, t2, 1	# incrementa contador
			li t3, 6
			bne t2, t3, COLOCApeca_cont	# se chega a 6, não coloca mais peças naquela coluna
			
			j GAMEcont
poePEÇA:
	li t1, 320
	remu t1, t4, t1
	li t3, 0xFF000000
	add t3, t3, t1		# t3 = endereço inicial
	add a5, t3, zero	# guarda em a5 o endereço inicial -> todas as funções salvam o valor de a5
	mv a1, t3
	
	addi sp, sp, -4
	sw ra, (sp)
	poePEÇA_loop:
		add t3, t4, zero
		li a4, 36
		li a6, 36
		call PRINTh
		add t4, t3, zero
		
		csrr t1, time
		addi t1, t1, 3
		poePEÇA_loop2:
			csrr t5, time
			sltu t2, t5, t1
			bne t2, zero, poePEÇA_loop2
		
		mv a3, a0		# a3 pega valor em a0
		add a0, a1, zero	# a0 recebe valor em a1
		add t3, t4, zero	# t3 pega valor em t4
		
		add a1, a5, zero	# a1 recebe o endereço inicial
		addi a1, a1, -2
		call PRINTtabuleiro_column # limpa rastro
		
		add t4, t3, zero	# t4 recebe de volta t3
		add a1, a0, zero	# a1 recebe de volta valor em a0
		mv a0, a3		# a0 recebe de volta a3
		
		addi a1, a1, 320
		blt a1, t4, poePEÇA_loop
	lw ra, (sp)
	addi sp, sp, 4
	
	ret

achaPEÇA:
	li t1, 1
	beq s1, t1, achaAMARELO		# se 1, utiliza peça amarela
	li t1, 2
	beq s1, t1, achaVERMELHO	# se 2, utiliza peça vermelha
	achaAMARELO:
		la a0, PeçaAmarela
		ret
	achaVERMELHO:
		la a0, PeçaVermelha
		ret
		
# Retorna input em a0			
INPUT:
	addi sp, sp, -8
	sw t0, 0(sp)
	sw t1, 4(sp)
	
	li t1,0xFF200000
	lw t0,0(t1)
	andi t0,t0,1
   	beq t0,zero,INPUTend
  	lw a0,4(t1)
  	
  	INPUTend:
  	lw t0, 0(sp)
  	lw t1, 4(sp)
  	addi sp, sp, 8
  	ret


# Argumentos: a0 (endereço da imagem), a1 (endereço inicial)
PRINTtabuleiro_column:
	addi sp, sp, -32
	sw a2, (sp)
	sw a4, 4(sp)
	sw a5, 8(sp)
	sw a6, 12(sp)
	sw a0, 16(sp)
	sw a1, 20(sp)
	sw a3, 24(sp)
	sw ra, 28(sp)
	
	PRINTtabuleiro_columnLoop1:
		la a0, tileTabuleiro	# carrega tile do tabuleiro em a0
		li a4, 40
		li a6, 40
		call PRINTh		# imprime tile do tabuleiro na tela
	PRINTtabuleiro_columnLoop2:
		li t0, 12800
		add a1, a1, t0		# vai para o proximo endereço de impressão
		blt a1, t3, PRINTtabuleiro_columnLoop1	# enquanto não imprime a quantidade certa de linhas, continua a imprimir
				
		lw a2, (sp)
		lw a4, 4(sp)
		lw a5, 8(sp)
		lw a6, 12(sp)
		lw a0, 16(sp)
		lw a1, 20(sp)
		lw a3, 24(sp)
		lw ra, 28(sp)
		addi sp, sp, 32
		ret

# Argumentos: a0 (endereço da imagem), a1 (endereço início de impressão), a4 (largura da imagem), a6 (altura da imagem)
PRINT:
	addi sp, sp, -28
	sw a2, (sp)
	sw a4, 4(sp)
	sw a5, 8(sp)
	sw a6, 12(sp)
	sw a0, 16(sp)
	sw a1, 20(sp)
	sw a3, 24(sp)

	add a5, a1, zero        # Guarda valor do endereço inicial em a5
	
	li t5,1                  # Inicializa contador
	li t6,320                # 320 p/ usar em contas
	
	# Conta p/ conseguir o endereço final
	addi a2,a6,-1
	mul a2,a2,t6
	add a2,a2,a4
	add a2,a2,a1
	
	print_LOOP1:
		add t4,a5,zero           # Guarda valor do endereço inicial em t4	
		mul t0,t6,t5             # Faz 320 * contador
		add t4,t4,t0             # Define qual será o próximo endereço
	
		add a3,a1,zero           # Guarda valor do endereço inicial em a3
		add a3,a3,a4             # Soma o endereço inicial à largura
	
	print_LOOP2:
		beq a1,a3, print_EXIT # Sai quando tiver printado valor correspondente à largura
		lw t1,0(a0)              # Lê 4 pixels
		sw t1,0(a1)              # Escreve a word na memória
		addi a1,a1,4             # Soma 4 ao inicial
		addi a0,a0,4             # Soma 4 ao endereço da imagem
		j print_LOOP2
	
	print_EXIT:	
		addi t5,t5,1              # Adiciona 1 ao contador	
		add a1,t4,zero            # Coloca o próximo endereço
		blt a1,a2,print_LOOP1 	  # Faz branch enquanto não alcança o endereço final
		
		lw a2, (sp)
		lw a4, 4(sp)
		lw a5, 8(sp)
		lw a6, 12(sp)
		lw a0, 16(sp)
		lw a1, 20(sp)
		lw a3, 24(sp)
		addi sp, sp, 28
		ret

PRINTh:
	addi sp, sp, -28
	sw a2, (sp)
	sw a4, 4(sp)
	sw a5, 8(sp)
	sw a6, 12(sp)
	sw a0, 16(sp)
	sw a1, 20(sp)
	sw a3, 24(sp)

	add a5, a1, zero        # Guarda valor do endereço inicial em a5
	
	li t5,1                  # Inicializa contador
	li t6,320                # 320 p/ usar em contas
	
	# Conta p/ conseguir o endereço final
	addi a2,a6,-1
	mul a2,a2,t6
	add a2,a2,a4
	add a2,a2,a1
	
	printh_LOOP1:
		add t4,a5,zero           # Guarda valor do endereço inicial em t4	
		mul t0,t6,t5             # Faz 320 * contador
		add t4,t4,t0             # Define qual será o próximo endereço
	
		add a3,a1,zero           # Guarda valor do endereço inicial em a3
		add a3,a3,a4             # Soma o endereço inicial à largura
	
	printh_LOOP2:
		beq a1,a3, printh_EXIT # Sai quando tiver printado valor correspondente à largura
		lh t1,0(a0)              # Lê 2 pixels
		sh t1,0(a1)              # Escreve a word na memória
		addi a1,a1,2             # Soma 2 ao inicial
		addi a0,a0,2             # Soma 2 ao endereço da imagem
		j printh_LOOP2
	
	printh_EXIT:	
		addi t5,t5,1              # Adiciona 1 ao contador	
		add a1,t4,zero            # Coloca o próximo endereço
		blt a1,a2,printh_LOOP1 	  # Faz branch enquanto não alcança o endereço final
		
		lw a2, (sp)
		lw a4, 4(sp)
		lw a5, 8(sp)
		lw a6, 12(sp)
		lw a0, 16(sp)
		lw a1, 20(sp)
		lw a3, 24(sp)
		addi sp, sp, 28
		ret

VERIFICAmatriz:
	la t0, MATRIZ
	li t1, 0	# contador
	li t2, 0	# contador de 0s
	li t3, 42
	VERIFICAmatriz_for:
		beq t1, t3, VERIFICAmatriz_end
		lb a0, (t0)
		
		addi t0, t0, 1
		addi t1, t1, 1
		
		bnez a0, VERIFICAmatriz_for
		addi t2, t2, 1
		
		j VERIFICAmatriz_for
VERIFICAmatriz_end:
	li a0, 1
	bnez t2, VERIFICAmatriz_ret  
	li a0, 0
VERIFICAmatriz_ret:
	ret

# argumentos: s3 = matriz atual, a2 = cor da peça
# retorna a0 = 0 - houve conexão de 4 peças, 1 - não houve conexão
VERIFICAtabuleiro:
	VERIFICAhorizontal:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0	# inicia contador de peças
		
		li a1, 1
		li a3, 0	# para de contar quando chega na posição 6 da matriz
		li t1, 6
		beq s4, t1, ESQUERDA
		call VERIFICAtabuleiro_for
	
		ESQUERDA:
		li a1, -1
		li a3, 1	# para de contar quando chega na posição 7 da matriz
		beqz s4, VERIFICAvertical
		call VERIFICAtabuleiro_for
		
	VERIFICAvertical:
		li t0, 0	# limpa contador de peças
		
		li a1, 7
		li a3, 2	# não para de contar -> sem problemas com barreira
		call VERIFICAtabuleiro_for
		
		li a1, -7
		li a3, 2	# não para de contar -> sem probelmas com barreira
		call VERIFICAtabuleiro_for
		
	VERIFICAdiagonal:
		li t0, 0	# limpa contador de peças
		
		li a1, 6
		li a3, 1	# para de contar quando chega na posição 7 da matriz
		beqz s4, DIAGONAL1
		call VERIFICAtabuleiro_for
		
		DIAGONAL1:
		li a1, -6
		li a3, 0	# para de contar quando chega na posição 6 da matriz
		li t1, 6
		beq s4, t1, DIAGONAL2
		call VERIFICAtabuleiro_for
		
		DIAGONAL2:
		li t0, 0	# limpa contador de peças
		
		li a1, 8
		li a3, 0	# para de contar quando chega na posição 6 da matriz
		li t1, 6
		beq s4, t1, DIAGONAL3
		call VERIFICAtabuleiro_for
		
		DIAGONAL3:
		li a1, -8
		li a3, 1	# para de contar quando chega na posição 7 da matriz
		beqz s4, VERIFICAfinal
		call VERIFICAtabuleiro_for
	VERIFICAfinal:
		lw ra, (sp)
		addi sp, sp, 4
		
		li t1, 3
		bge t0, t1, VERIFICAconectou
		li a0, 1	# retorna 1 em a0 -> houve conexão de 4 peças
		ret
	VERIFICAconectou:
		li a0, 0	# retorna 0 em a0 -> houve conexão de 4 peças
		ret
	
	VERIFICAtabuleiro_for:
		li t2, 0		# contador adicional
		add t3, s3, zero	# coloca matriz atual em t3
		VERIFICAtabuleiro_loop:
			la t1, MATRIZ
			blt t3, t1, VERIFICAtabuleiro_end
			addi t1, t1, 41
			bgt t3, t1, VERIFICAtabuleiro_end	# verifica se t3 está dentro do limite da matriz
			
			lb t1, (t3)
			bne t1, a2, VERIFICAtabuleiro_end	# se encontra um valor diferente da peça, termina contagem
			addi t0, t0, 1				# aumenta 1 na quantidade de peças
			
			beqz a3, VERIFICArem6			# verifica se chegou ao fim do tabuleiro (direita) caso a3 = 0
			li t1, 1
			beq a3, t1, VERIFICArem7		# verifica se chegou ao fim do tabuleiro (esquerda) caso a3 = 1
			
			VERIFICAtabuleiro_loopCONT:	
			add t3, t3, a1				# vai para próxima posição	
			addi t2, t2, 1				# aumenta 1 no contador
			li t1, 4	
			bne t2, t1, VERIFICAtabuleiro_loop	# loop enquanto não conta 4 peças
			
	VERIFICAtabuleiro_end:
		addi t0, t0, -1		# decrementa 1 de t0 (posição inicial)
		
		li t1, 3
		bge t0, t1, VERIFICAfinal
		ret
	VERIFICArem6:
		la t4, MATRIZ
		sub t4, t3, t4
		VERIFICArem6_loop:
			li t1, 6
			beq t4, t1, VERIFICAtabuleiro_end
			li t1, 7
			sub t4, t4, t1
			bgtz t4, VERIFICArem6_loop
		j VERIFICAtabuleiro_loopCONT
		
	VERIFICArem7:
		la t4, MATRIZ
		sub t4, t3, t4
	
		li t1, 7
		rem t1, t4, t1
		beqz t1, VERIFICAtabuleiro_end
		j VERIFICAtabuleiro_loopCONT	
	
LIMPAmatriz:
	la t0, MATRIZ
	li t1, 0	# contador
	li t2, 42
	LIMPAmatriz_for:
		beq t1, t2, LIMPAmatriz_end
		li t3, 0
		sb t3, (t0)
		
		addi t0, t0, 1
		addi t1, t1, 1
		
		j LIMPAmatriz_for
LIMPAmatriz_end:
	la t0, EASYIA
    	sb zero, 0(t0)
	ret

VITÓRIA:
	la a0, Vitória
	li a1, 0xFF007D3C
	li a4, 192
	li a6, 44
	call PRINT
	
	csrr t1, time
	addi t1, t1, 1500
	VITÓRIA_loop:
		csrr t0, time
		blt t0, t1, VITÓRIA_loop
	
	li a0, 0
	j MAIN
	
DERROTA:
	la a0, Derrota
	li a1, 0xFF007D3C
	li a4, 192
	li a6, 44
	call PRINT
	
	csrr t1, time
	addi t1, t1, 1500
	DERROTA_loop:
		csrr t0, time
		blt t0, t1, DERROTA_loop
	
	li a0, 0
	j MAIN
	
EMPATE:
	
	la a0, Empate
	li a1, 0xFF007D3C
	li a4, 192
	li a6, 44
	call PRINT
	
	csrr t1, time
	addi t1, t1, 1500
	EMPATE_loop:
		csrr t0, time
		blt t0, t1, EMPATE_loop
	li a0, 0
	j MAIN
	
LIMPAtela:
	addi sp, sp, -24
	sw a2, (sp)
	sw a4, 4(sp)
	sw a5, 8(sp)
	sw a6, 12(sp)
	sw a0, 16(sp)
	sw a1, 20(sp)
	
	li a4, 320
	li a6, 240
	add a5, a1, zero        # Guarda valor do endereço inicial em a5
	
	li t5,1                  # Inicializa contador
	li t6,320                # 320 p/ usar em contas
	
	# Conta p/ conseguir o endereço final
	addi a2,a6,-1
	mul a2,a2,t6
	add a2,a2,a4
	add a2,a2,a1
	
	LIMPAtela_LOOP1:
		add t4,a5,zero           	# Guarda valor do endereço inicial em t4	
		mul t0,t6,t5             	# Faz 320 * contador
		add t4,t4,t0             	# Define qual será o próximo endereço
	
		add a3,a1,zero           	# Guarda valor do endereço inicial em a3
		add a3,a3,a4             	# Soma o endereço inicial à largura
	
	LIMPAtela_LOOP2:
		beq a1,a3, LIMPAtela_EXIT 	# Sai quando tiver printado valor correspondente à largura
		mv t1, zero
		sw t1,0(a1)              	# Escreve a word na memória
		addi a1,a1,4            	# Soma 4 ao inicial
		j LIMPAtela_LOOP2
	
	LIMPAtela_EXIT:	
		addi t5,t5,1              	# Adiciona 1 ao contador	
		add a1,t4,zero            	# Coloca o próximo endereço
		blt a1,a2,LIMPAtela_LOOP1 	# Faz branch enquanto não alcança o endereço final
		
		lw a2, (sp)
		lw a4, 4(sp)
		lw a5, 8(sp)
		lw a6, 12(sp)
		lw a0, 16(sp)
		lw a1, 20(sp)
		addi sp, sp, 24
		ret
	
.include "src/Convert.asm"

PRINTtabuleiro:
	addi sp, sp, -4
	sw ra, (sp)
	li a1, 0xFF000014	# define início da impressão
	addi a2, a1, 280	# define final da impressão da linha
	mv a3, zero		# inicia contador
	
	PRINTtabuleiro_loop1:
		la a0, tileTabuleiro	# carrega tile do tabuleiro em a0
		li a4, 40
		li a6, 40
		call PRINT		# imprime tabuleiro na tela
		addi a1, a1, 40
		blt a1, a2, PRINTtabuleiro_loop1
	PRINTtabuleiro_loop2:
		addi a3, a3, 1		# soma ao contador
		li t0, 0xFF000000
		li t1, 12800
		mul t2, t1, a3		# põe a linha certa
		addi t2, t2, 20		# soma com 20
		add t2, t2, t0
		
		mv a1, t2		# define início da impressão
		addi a2, a1, 280	# define final da impressão da linha
		li t0, 6
		bne a3, t0, PRINTtabuleiro_loop1	# enquanto não imprime 6 linhas, continua
		
		lw ra, (sp)
		addi sp, sp, 4
		ret

.include "src/SYSTEMv21.s"
