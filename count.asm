######################################################################
#Pei-Yun Tseng
#CS3340
#This program allows the user to enter a string of text and outputs the number of words and characters
######################################################################

.data
	
charCount:	.word 0	
wordCount:	.word 0
UsrMsg: 	.space 40
MsgtoUsr: 	.asciiz "Enter some text"
space:		.asciiz " "
		.align 2
goodbye:	.asciiz "Goodbye"
words:		.asciiz " words "
chars:		.asciiz " characters"
newline:	.asciiz "\n"


.text
	lw	$t3, newline
	lw 	$t2, space
	
askUser:
	#Dialog box prompts user to enter a string
	la	$a0, MsgtoUsr
	la	$a1, UsrMsg
	li	$a2, 40
	li	$v0, 54
	syscall
	
	#if user cancels or leaves field empty, exit
	beq	$a1, -2, leaveMsg
	beq	$a1, -3, leaveMsg
	
	#otherwise continue
	la 	$a1, UsrMsg
	la	$a3, UsrMsg
 	
 	
	jal	charloop #call charloop function
	jal	wordloop #call the wordloop fuction
	
output:
 	la	$a0, UsrMsg #output the user message
 	li	$v0, 4
 	syscall
 	
 	lw	$a0, wordCount #number of words
 	li	$v0, 1
 	syscall
 	
 	la	$a0, words #string words
 	li	$v0, 4
 	syscall
 	
 	lw	$a0, charCount #number of characters
 	li	$v0, 1
 	syscall
 	
 	la	$a0, chars #string characters
 	li	$v0, 4
 	syscall
 	
 	la	$a0, newline #newline
 	li	$v0, 4
 	syscall
 	
 	
 	j	askUser
 	
leaveMsg: 	
	la	$a0, goodbye #goodbye message
	li	$v0, 59
	syscall
	
exit:	li	$v0, 10
	syscall
	

###############################################################################

charloop:
	lb   $t0, 0($a1)
    	beq  $t0, $t3, storeChar
    	addi $a1,$a1,1		#add 1 to the address to move to next byte
    	addi $t4,$t4,1		#add 1 to $t4 to keep count of chars
    	j     charloop
	
	
wordloop: 	
	lb  $t1, 0($a3)
	beq $t1, $t3, storeWord #if character in $t1 is a newline then store the wordcount
	beq $t1, $t2, incrementWord #if character in $t1 is a space then increment word
nextChar:
	addi $a3, $a3, 1	#moves to the next character
	j 	wordloop
	
incrementWord:
	add 	$v1, $v1, 1	#adds one to the wordcount
	j	nextChar
    	
storeChar: 
  	move	$v0, $t4	#stores the charcount from $t4 to $v0
 	sw	$v0, charCount
 	move	$t4, $0		#clear the register $t4 for the next loop
	jr	$ra
	
storeWord:
	addi	$v1, $v1, 1 #add 1 to the number of spaces to get the number of words
	sw	$v1, wordCount
	move	$v1, $0
	jr	$ra
	
	

	
	
	
	
	
