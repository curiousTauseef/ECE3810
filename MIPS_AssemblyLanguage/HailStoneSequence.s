# Jordan Wu UID: u0900517
# Author: Jordan Wu
# Date: 2-7-2015
#
# A MIPS program that will run a hail stone sequence.
# --------------------------------------------------
# If the current integer N is even, the next number is computed as N/2
# If the current integer N is odd, the next number is computed as N*3+1
# Note:
# This series of sequence will converge to 'one' no matter what starting 
# positive integer is chosen


	.data
	
Program:
	.asciiz "This program computes the length of the hailstone series for some starting number N.\n"

Prompt:
	.asciiz "Enter a positive integer N: **** user input : "
	
Result1:
	.asciiz "\nThe hailstone series starting from "
	
Result2:
	.asciiz " converges in "

Result3:
	.asciiz " iterations(s)."
	
ErrorOutput:
	.asciiz "The program has been terminated, the inputted number is NOT positive!!"
	
OverflowOutput:
	.asciiz "\nOverflow during iteration #"
	
Space:
	.asciiz " "
	
	.text
	
# First, it will tell the user what this program does.
	la $a0, Program		# Prints out what the program does
	li $v0, 4
	syscall
	
# Next, tell user to input a positive integer.
	la $a0, Prompt		# Tells user to input a positive integer
	li $v0, 4
	syscall
	
# Next, wait for the user to input an positive integer.	
	li $v0, 5		# Code for input integer
	syscall		
	
# Next, save the inpputted integer in a saved register
	move $s0, $v0		# Save content of $v0 into $s0
	
# Next, check if the inputted number is positive number (look at the sign bit which is the MSB).
	rol $t0, $s0, 1		# Roll the bits left by one bits - wraps highest bits to lowest bits
	andi $t0, $t0, 1	# Mask off low lits (logical AND with 0000...0001)
	bne $t0, $zero, Error	# If the sign bit (MSB) is a 1 then go to Error
	
# Next, check if the inputted number is zero, end program if it is zero.
	beq $s0, $zero, Error	# If the inputted number is zero go to Error

# Next, compute the hailstone sequence for the initail number N and count iterations
	move $t0, $s0		# copy inputted integer into $t0
	li $s1, 0		# Set iterations to 0
Loop:	
	move $t0, $v0		# Save return value back into $t0
	beq $t0, -1, PrintOverflow# If number is -1 go to OverflowOutput
	jal DigitOut		# Prints number and a space
	beq $t0, 1, Output	# If number equal 1 go to Output
	addu $s2, $s2, 1	# Increment iteration
	move $a0, $t0		# Put in argument to be used for function 
	jal Function		# Create function
	j Loop			# Jump back to Loop

# Function that will compute N*3+1	
Function:
	andi $t1, $a0, 1	# Mask off LSB to see if it is even or odd
	beqz $t1, Even		# If even number then go to Even 
	addi $t3, $zero, 715827883# $t3 = 715827883
	slt $t2, $a0, $t3	# See if N < 715827883
	bne $t2, 1, Overflow	# If N > 715827883 than overflow has occur
	addu $t1, $a0, $a0	# This is like multiplying by 2
	addu $t1, $t1, $a0	# Then add again this will give us (N*3)
	addi $v0, $t1, 1	# Add 1 (N*3+1) and save as return value
	jr $ra			# Return to address
	
# This will compute N/2
Even:
	srl $v0, $t0, 1		# Shift the bits left by 1 (N/2) and return value
	j Loop			# Jump to Loop
	
# Prints the number and a space
DigitOut:
	move $a0, $t0		# Print integer
	li $v0, 1		
	syscall
	la $a0, Space		# Print space
	li $v0, 4	
	syscall
	jr $ra			# Return back using return address

# Print this when it overflows
PrintOverflow:
	la $a0, OverflowOutput	# Prints out Overflow output
	li $v0, 4
	syscall	
	move $a0, $s2		# Print int (iterations)
	li $v0, 1
	syscall	
	j Exit			# jump to Exit
# Overflow has occurred
Overflow:
	addi $v0, $zero, -1	# $v0 = -1 for overflow
	j Loop			# Jump to Loop
		
# When there is a negative number run this
Error:
	la $a0, ErrorOutput	# Prints out Error output
	li $v0, 4
	syscall
	j Exit			# jump to Exit	
	
# Output results if nothing went wrong	
Output:
# Output Result1	
	la $a0, Result1 	# Prints out Result1 string
	li $v0, 4
	syscall
	
# Output the inputted integer
	move $a0, $s0		# Print int (inputted number)
	li $v0, 1
	syscall
	
# Output Result1	
	la $a0, Result2 	# Prints out Result2 string
	li $v0, 4
	syscall
	
# Output the iterations
	move $a0, $s2		# Print int (iterations)
	li $v0, 1
	syscall
	
# Output Result1	
	la $a0, Result3 	# Prints out Result3 string
	li $v0, 4
	syscall
	j Exit

# Done, exit the program.
Exit:
        li $v0, 10  		# This system call will terminate the program gracefully.
        syscall