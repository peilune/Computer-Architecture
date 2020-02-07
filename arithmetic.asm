.data
#input variables
a: 	.word 0
b:	.word 0
c: 	.word 0

#output variables
ans1:	.word 0
ans2:	.word 0
ans3: 	.word 0

name: 	.space 20

#messages
msgname:	.asciiz "What is your name? "
msginteger:	.asciiz "Please enter an integer between 1-100: "
results:	.asciiz "Your answers are: "
space: 		.asciiz " "

.text
main:

	#prompt user for name
	la	$a0, msgname
	li 	$v0, 4
	syscall
	
	#get name from user
	la	$a0, name
	la	$a1, 20
	li	$v0, 8
	syscall
	
	#First -ask user for integer
	la	$a0, msginteger
	li 	$v0, 4
	syscall
	
	#read integer from user
	li 	$v0, 5
	syscall
	sw	$v0, a
	
	#Second - ask user for integer
	la	$a0, msginteger
	li 	$v0, 4
	syscall
	
	#read and store integer from user
	li 	$v0, 5
	syscall
	sw	$v0, b
	
	#Third - ask user for integer
	la	$a0, msginteger
	li 	$v0, 4
	syscall
	
	#read and store integer from user
	li 	$v0, 5
	syscall
	sw	$v0, c
	
	#load integers in registers 
	lw	$t0, a
	lw	$t1, b
	lw	$t2, c
	
	#calculate 2a - b + 9
	add	$t3, $t0, $t0
	sub	$t3, $t3, $t1
	addi	$t3, $t3, 9
	sw	$t3, ans1
	
	#Calculate c - b + (a - 5)
	sub	$t3, $t0, 5
	sub	$t4, $t2, $t1
	add	$t4, $t4, $t3
	sw	$t4, ans2
	 
	#Calculate (a - 3) + (b + 4) - (c + 7)   
	sub	$t3, $t0, 3
	add	$t3, $t3, $t1
	addi	$t3, $t3, 4
	addi	$t4, $t2, 7
	sub	$t3, $t3, $t4
	sw	$t3, ans3	
	
	#echo data to user
	#print name of user
	la	$a0, name
	li	$v0, 4
	syscall
	
	la	$a0, results
	li 	$v0, 4
	syscall
	
	#answer 1
	lw	$a0, ans1
	li	$v0, 1
	syscall
	
	#space
	la	$a0, space
	li 	$v0, 4
	syscall
	
	#answer2
	lw	$a0, ans2
	li	$v0, 1
	syscall
	
	#space
	la	$a0, space
	li 	$v0, 4
	syscall
	
	#answer3
	lw	$a0, ans3
	li	$v0, 1
	syscall
	
	#program termination
	li $v0, 10
	syscall
	
#test values for a, b, c

#a = 34
#b = 45
#c = 33
#results: 32 17 40

#a = 99
#b = 22
#c =55
#results: 185 127 60
