# N = 31
.data
 emptyInput: .asciiz "Input is empty."
 longInput: .asciiz "Input is too long."
  userInput: .space 500
  invalidInput: .asciiz "Invalid base-N number." # change n
  
  .text

err_empty_input:
 la $a0, emptyInput
 li $v0, 4
 syscall
  j exit

err_invalid_input:
 la $a0, invalidInput
 li $v0, 4
 syscall
  j exit

err_long_input:
 la $a0, longInput
 li $v0, 4
 syscall
  j exit

main:
 jal get_userInput
 jal strlen 
 li $v1,5  
 slt $t1,$v1,$v0
 
 beq $t1,1,TooLong
get_userInput: 
 addi $sp, $sp, 4
 sw $ra, 0($sp)
 sw $a0, ($sp)
 la $a0, userInput  
 li $v0, 4
 syscall
 
 la $a0, input 
 li $a1, 80
 li $v0, 8
 syscall
 la $a0, input
 
delete_left_pad:
	li $t8, 32 # this line will end up making a space
	lb $t9, 0($a0)
	beq $t8, $t9, delete_first_char
	move $t9, $a0
	j input_len

delete_first_char:
	addi $a0, $a0, 1
	j delete_left_pad #jump back to dele left pad function
	
input_len:
	addi $t0, $t0, 0
	addi $t1, $t1, 10
	add $t4, $t4, $a0 #adds the value of $t4 into $a0
	
len_iteration:
	lb $t2, 0($a0)#takes the memeory $t2 and puts it $a0
	beqz $t2, after_len_found
	beq $t2, $t1, after_len_found
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	j len_iteration

after_len_found:
	beqz $t0, err_empty_input
	slti $t3, $t0, 5
	beqz $t3, err_long_input
	move $a0, $t4
	j check_str
	
check_str:
	lb $t5, 0($a0)
	beqz $t5, prepare_for_conversion
	beq $t5, $t1, prepare_for_conversion
	slti $t6, $t5, 48
	bne $t6, $zero, err_invalid_input
	slti $t6, $t5, 58
	bne $t6, $zero, step_char_forward
	slti $t6, $t5, 65
	bne $t6, $zero, err_invalid_input
	slti $t6, $t5, 86 
	bne $t6, $zero, step_char_forward
	slti $t6, $t5, 97
	bne $t6, $zero, err_invalid_input
	slti $t6, $t5, 118 
	bne $t6, $zero, step_char_forward
	bgt $t5, 119, err_invalid_input 

step_char_forward:
	addi $a0, $a0, 1
	j check_str
	
prepare_for_conversion:
	move $a0, $t4
	addi $t7, $t7, 0
	add $s0, $s0, $t0
	addi $s0, $s0, -1
	li $s3, 3
	li $s2, 2
	li $s1, 1
	li $s5, 0

base_convert_input:
	lb $s4, 0($a0)
	beqz $s4, print_result
	beq $s4, $t1, print_result
	slti $t6, $s4, 58
	bne $t6, $zero, base_ten_conv
	slti $t6, $s4, 88
	bne $t6, $zero, base_33_upper_conv
	slti $t6, $s4, 120
	bne $t6, $zero, base_33_lower_conv
	
base_ten_conv:
	addi $s4, $s4, -48
	j accumulated_result
	
base_33_upper_conv:
	addi $s4, $s4, -55
	j accumulated_result
	
base_33_lower_conv:
	addi $s4, $s4, -87

accumulated_result:
	beq $s0, $s3, first_integer
	beq $s0, $s2, second_integer
	beq $s0, $s1, third_integer
	beq $s0, $s5, fourth_integer
first_integer:
	li $s6, 29791 # (base N)^3
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input

second_integer:
	li $s6, 961 # (base N)^2
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input
	
third_integer:
	li $s6, 31 # (base N)^1
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input
	
fourth_integer:
	li $s6, 1
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j base_convert_input
	
print_result:
	li $v0, 1
	move $a0, $t7
	syscall

exit:
   li $v0, 10
   syscall
j exit