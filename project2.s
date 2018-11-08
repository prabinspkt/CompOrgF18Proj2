.data

    input_too_long:
    .asciiz "Input is too long."
    input_is_empty:
    .asciiz "Input is empty."
    invalid_number:
    .asciiz "Invalid base-36 number."
    input_storage:
    .space 8                                    # reserves space for 8 bytes in memory for user_string

.text
main:

    la $a0, input_storage                       # $a0 points to the starting address of user input
    li $v0, 8                                   # load code into $v0, $v0 is for user string input
    syscall

    #Check if input is more than 4 characters long
    lb $t0, 5($a0)                              # load the 6th byte into register $t0 , 5th byte is new line char when we use qtSpim to enter string
    bne $zero, $t0, print_more_than_four        # if 6th byte is not NUL, user input has more than 4 char

    #Check if the first character is new line char as well to see if string is empty
    lb $t0, 0($a0)                              # load first byte in $t0
    li $a2, 10                                  # load new line char in $a2
    beq $t0, $a2, print_empty                   # if 1st byte is new line char, user input is empty

    li $s0, 1                                   # number to multiply 36 with after each iteration of valid char
    li $s1, 0                                   # sum number based on calculation in each iteration
    li $s4, 0                                   # loop counter
