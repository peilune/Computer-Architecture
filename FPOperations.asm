.data	
input:	.asciiz "input.txt"
error:	.asciiz "Error, no characters read"
space: .asciiz " "
before: .asciiz "The array before: "
newline: .asciiz "\n"
after: .asciiz "The array after: "
meanStr: .asciiz "The mean is: "
medianStr: .asciiz "The median is: "
stdevStr: .asciiz "The standard deviation is: "
mean: .float 0
median: .float 0
stdev: .float 0
wordCount:  .word 0
buffer: .space 80 
arr: 	.space 80


.text

	#Open the file for reading
	la $a0, input	#input file name	
	la $a1, 0   	#0 for reading
	li $v0, 13
	li $a2, 0 	#mode is ignored
	syscall
	move $s6, $v0	#save file descriptor
	
	jal readTxt	#go to the readTxt function
	
	ble $v0, 0, printError	#if $v0 value is <= 0, prints an error
	la $a2, buffer
	la $a0, arr
	li $a1, 20

	jal intToArr		#else extract integers from Array function
	
	la $a0, before
	li $v0, 4
	syscall
	
	la $s6, arr
	jal printArr
	
	la $s6, arr
	la $a0, arr #base address
	li $t3, 0 #counter for elements in array
	
	jal sortArr
	
	#print the array after sorting
	la $a0, newline
	li $v0, 4
	syscall

	la $a0, after
	li $v0, 4
	syscall
	
	la $s6, arr
	jal printArr
	
	#calculate the mean
	la $a0, arr
	li $a1, 20
	jal meanCalc
	swc1 $f0, mean
	
	#print out the mean
	la $a0, newline
	li $v0, 4
	syscall
	
	la $a0, meanStr
	li $v0, 4
	syscall 
	
	lwc1 $f12, mean #print out the mean
	li $v0, 2
	syscall
	
	#calculate the median
	la $a0, arr
	li $a1, 20
	jal medianCalc
	
	#print string for median
	la $a0, newline
	li $v0, 4
	syscall
	
	la $a0, medianStr
	li $v0, 4
	syscall
	
	beq $v1, 1, float
int:	#use this to print if median is int
	sw $v0, median
	lw $a0, median
	li $v0, 1
	syscall
	j standarddev
	
float:	#use this to print if median is float
	swc1 $f0, median #store median
	lwc1 $f12, median
	li $v0, 2
	syscall

standarddev:
	la $a0, arr
	li $a1, 20
	jal stdevCalc
	swc1 $f2, stdev #store from fp to memory
	
	#print the standard deviation
	la $a0, newline
	li $v0, 4
	syscall
	
	la $a0, stdevStr
	li $v0, 4
	syscall
	
	lwc1 $f12, stdev
	li $v0, 2
	syscall	
	
	j exit
	
	
	
#################################################################################
readTxt: 
	la $a0, ($s6)
	la $a1, buffer
	li $a2, 100
	li $v0, 14
	syscall
	j return
	
printError:
	la $a0, error
	li $v0, 4
	syscall
	j exit
	
intToArr:
	li $t3, 10
	li $t6, 0   	#accumulator of sum

loop:	lb $t1, 0($a2)	   #load char from buffer to array
	beq $t1, 0, return
	beq $t1, 10, newWord #check if byte is a newline character
	blt $t1, 48, ignore
	bgt $t1, 58, ignore #check if 47 < byte < 58
	bne $t6, 0, tens
cont:	subi $t1, $t1, 48    #subtract 48 from byte to get integer value
	add $t6, $t6, $t1
	addi $a2, $a2, 1	#increment memory address
	j loop

tens:	mult $t6, $t3
	mflo $t6
	j cont
	
			
newWord: 
	sw $t6, ($a0)	  #store $t1 to arr
	addi $a0, $a0, 4 #move to next word
	addi $a2, $a2, 1 #move to next byte
	j intToArr	 #jump to intToArr
		
ignore:
	addi $a1, $a1, 1
	j intToArr



printArr:	
	lw $a0, ($s6) #lw of address of base of array
	beq $a0, 0, return
	li $v0, 1
	syscall 	#print integer
	addi $s6, $s6, 4 #add 4 to the base address
	la $a0, space #print a space between the numbers
	li $v0, 4
	syscall
	j printArr

sortArr:
	beq, $t3, 20, return
	lw $t1, ($s6) #take first integer of arr
	la $s1, ($s6) #store the address of the current integer
nextInt:
	addi $s6, $s6, 4 #add 4 to the address for the next integer
	lw $t2, ($s6)  #store the next integer of array in $t2
	beq $t2, 0, store #branch if $t2 is 0
	bgt $t1, $t2, swap #if $t1 is larger than $t2, swap
	j nextInt	
swap:
	move $t1, $t2 #move the smaller integer to $t1
	move $s1, $s6 #keep track of the address of the smaller integer
	j nextInt

store:
	lw $t4, ($a0) #load from array [0] to arr[20] from the value of address
	sw $t4, ($s1) #store the value of array to the minimum integer address
	sw $t1, ($a0) #store the min value to array index 0 to 19
	addi $a0, $a0, 4 #increment the address to next word
	move $s6, $a0 #start checking loop at the next word
	addi $t3, $t3, 1 #increment the word counter b/c exit condition at 20
	j sortArr


meanCalc:
	li $t2, 0 #counter
	li $t0, 0 #sum of the integers
sum:	
	beq $t2, 20, div
	lw $t1, ($a0) #load the first int in register $t1
	add $t0, $t0, $t1 #sum the integers
	addi $a0, $a0, 4 #add 4 to loop through array
	add $t2, $t2, 1 #increment counter
	j sum

div:
	mtc1 $t0, $f0 #move the sum to fp register in c1
	cvt.s.w $f0, $f0 #convert sum to single precision
	mtc1 $a1, $f1 #move the length to fp reg. in c1
	cvt.s.w $f1, $f1 #convert 20 to float
	div.s $f0, $f0, $f1 #divide sum/length 
	j return
	
medianCalc:
	li $t0, 2
	li $t3, 4
	div $a1, $t0 #divide length to check if even
	mflo $t2 #this contains the quotient
	mfhi $t1 #this contains the remainder
	beq $t1, 0, even
	subi $t2 $t2, 1 #add 1 to the quotient 
	mul $t2, $t2, $t3 #multiply quotient by 4 to get address from base
	add $a0, $a0, $t2 #add result to base address
	lw $v0, ($a0) #load int from address to reg
	li $v1, 0 #if $v1 is 0 it's an int
	j return
even: 
	mul $t2, $t2, $t3 #get the offset from base
	add $a0, $a0, $t2 #add offset to base to get address
	subi $a1, $a0, 4 #subtract by 4 to get previous word
	lw $t4 ($a0) #load int
	lw $t5 ($a1) #load int
	add $t4, $t4, $t5 #sum the two int
	mtc1 $t4, $f0 #move sum to fp reg
	mtc1 $t0, $f1 #move 2 to fp reg
	cvt.s.w $f0, $f0 #convert sum to fp
	cvt.s.w $f1, $f1 #convert 2 to fp
	div.s $f0, $f0, $f1 #divide sum by 2
	li $v1, 1 #set flag v1 to 1 if float
	j return

stdevCalc:
	li $t1, 0 #counter for array
	lwc1 $f1, mean
	subi $a1, $a1, 1 #length of array - 1
	mtc1 $a1, $f3
	cvt.s.w $f3, $f3 #convert length to fp
	mtc1 $zero, $f2 #sum for the array
	
stdevloop:	
	beq $t1, 20, sqrt
	lwc1  $f0, ($a0) #load int from array
	cvt.s.w $f0, $f0#convert the int to fp
	sub.s $f0, $f0, $f1 #subtract int from mean
	mul.s $f0, $f0, $f0 #square
	add.s  $f2, $f2, $f0 #sum the results
	addi $a0, $a0, 4 #move to next int
	addi $t1, $t1, 1
	j stdevloop
	
sqrt:
	div.s $f2, $f2, $f3
	sqrt.s $f2, $f2	
	j return

return:
	jr $ra
exit:
	li $v0, 10
	syscall
