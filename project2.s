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
