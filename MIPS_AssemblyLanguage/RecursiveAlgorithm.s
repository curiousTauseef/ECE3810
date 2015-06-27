# Jordan Wu UID: u0900517
# Author: Jordan Wu
# Date: 2-8-2015
# Homework Assignment #4, PartB
###############################

	.data

Program:
	.asciiz "This program will run a recursive algorithm.\n"
	
Prompt:
	.asciiz "Enter a number N that is between zero and ten: **** user input : " 
	
ErrorOutput:
	.asciiz "Please make sure N is greater than 0 and less than 10, please rerun the program."
	
EndRecursionOutput:
	.asciiz "End recursion\n"
	
RecursionIn:
	.asciiz "Recursion in "
	
Colon:
	.asciiz ":"
	
PrintX:
	.asciiz "x"
	
NewLine:
	.asciiz "\n"
	
RecursionOut:
	.asciiz "Recursion out "
	
	.text

#####################################################################################################
# First, would be to create a main block that will be the first code to be executed
# This should do the following...
# 1. Prompt the user and then accept a number N as input
# 2. Confirm that N is greater than 0 and less than 10 (if not, print an error message and quit)
# 3. Call a function named 'recursion' with the number N as the argument
# 4. quit using syscall for exit
Main:
# First, it will tell the user what this program does
	la $a0, Program			# Display what this program does
	li $v0, 4
	syscall

# Next, tell user to input a integer
	la $a0, Prompt			# Tell user to enter a number 			
	syscall
	
# Next, wait for the user to input a integer (N)	
	li $v0, 5			# Code for input integer
	syscall

# Check if N is greater than 0 and less than 10, if not print error message and exit program	
	beqz $v0, Error			# Go to error if N = 0
	addi $t1, $zero, 10		# create a temp reg that stores the value 10 $t1 = 10
	sltu $t1, $v0, $t1 		# See if 0 < N < 10
	beqz $t1, Error			# go to Error if this number is less than 0 or greater than 10 

# Next, save N into argument register	
	move $a0, $v0			# N is saved in register $a0

# Call the function called 'recursion' with N as the argument
	jal recursion			# Create a recursion procedure
	j Exit				# Jump to Exit
#####################################################################################################	
		
# Recursion function that takes N as a argument in $a0
recursion:
	move $s1, $a0			# argument N is kept in $s1 for convenience
	slti $t1, $s1, 10 		# See if N > 9
	beq $t1, $zero, EndRecursion	# Go to EndRecursion if N > 9
	addi $sp, $sp, -20		# Adjust stack for five items
	sw $fp, 16($sp)			# Save the frame pointer
	sw $ra, 12($sp)			# Save return address
	addi $fp, $fp, 16		# Move frame pointer to the top of frame	
	la $a0, RecursionIn		# Print RecursionIn string
	li $v0, 4
	syscall	
	move $a0, $s1			# Print N		
	li $v0, 1			
	syscall
	la $a0, Colon			# Print ":"
	li $v0, 4
	syscall
	move $t0, $zero			# Set k = 0
	jal Loop			# Jump and link Loop function
	la $a0, NewLine			# New Line
	li $v0, 4
	syscall	
	addi $s0, $s1, 7		# i = N + 7
	addi $t3, $s1, 1		# j = N + 1
	nor $t1, $s0, $zero		# ~($s0) = ~(i) = not(i)
	addi $t1, $t1, 1		# add 1 to get -i
	addi $t0, $t1, 13		# k = -i + 13 same as k = 13 - i
	sw $s1, 8($sp)			# Save N
	sw $s0, 4($sp)			# Save i 
	sw $t0, 0($sp)			# Save k
	move $a0, $t3			# set j as argument
	jal recursion			# Jump and Link to recursion
	move $s2, $v0			# j = return value
	lw $t0, 0($sp)			# Restore k
	lw $s0, 4($sp)			# Restore i
	lw $s1, 8($sp)			# Restore N
	nor $t1, $t0, $zero		# ~($t0) = ~(k) = not(k)
	addi $t1, $t1, 1		# add 1 to get -k
	add $s2, $s2, $t1		# j = j + (-k)
	add $s2, $s2, $s0		# j = j + i
	la $a0, RecursionOut		# Print RecursionOut
	li $v0, 4
	syscall
	move $a0, $s1			# Print N
	li $v0, 1
	syscall
	la $a0, Colon			# Print ":"
	li $v0, 4
	syscall
	move $t0, $zero			# k = 0
	jal Loop			# Jump and link Loop function
	la $a0, Colon			# Print ":"
	li $v0, 4
	syscall
	move $a0, $s2			# Print j
	li $v0, 1
	syscall
	la $a0, NewLine			# Print new line
	li $v0, 4
	syscall
	move $v0, $s2			# Return j
	lw $ra, 12($sp)			# Restore return address
	lw $fp, 16($sp)			# Restore frame pointer
	addi $sp, $sp, 20		# Collapse stack
	jr $ra				# Return address

# Print EndRecusion message when N > 9 and return N
EndRecursion:
	la $a0, EndRecursionOutput	# Display the end recursion string
	li $v0, 4
	syscall
	move $v0, $s1			# Return N
	jr $ra				# Return Address
	
# for( k = 0; k < N; k = k + 1) used to print x
Loop:
	addi $t0, $t0, 1		# Increment k by 1 (k = k + 1)
	la $a0, PrintX			# Print out "x"
	li $v0, 4
	syscall
	slt $t1, $t0, $s1		# If k < N
	bne $t1, $zero, Loop		# Loop if k < N
	jr $ra				# Return using return address	

# Print Error message when when N is not greater than 0 and less than 10
Error:
	la $a0, ErrorOutput		# Prints error message
	li $v0, 4
	syscall
	j Exit				# Jump to Exit

# Exit this program	
Exit:
	li $v0, 10			# Terminate the program gracefully
	syscall