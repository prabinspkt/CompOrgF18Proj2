.data

    input_too_long:
    .asciiz "Input is too long."
    input_is_empty:
    .asciiz "Input is empty."
    invalid_number:
    .asciiz "Invalid base-36 number."
    input_storage:
    .space 2000                                 # reserves space memory for user input string
    filtered_input:                             # allocate 4 bytes for filtered out string that doesn't have white spaces
    .space 4

.text
main:

    la $a0, input_storage                       # $a0 points to the starting address of user input
    li $v0, 8                                   # load code into $v0, $v0 is for user string input
    syscall

    # Use a loop to extract string and exclude white spaces

    li $s2, 0 # s2 is updated to 1 if a non-NUL, non-space or non-new-line-char if found once
    # the idea is that if these types of characters are found again after loading 4 bytes, the user input is more than four chars
    li $t1, 10 # new line char
    li $t2, 32 # space char

    filter_loop:
    lb $t0, 0($a0) # load byte from $a0, $a0 is updated in the loop
    beq $t0, $t1, exit_filter_loop # exit when new line char found
    beq $t0, $t2, skip # if space is found, skip to check another byte
    beqz $t0, exit_filter_loop # exit loop when NUL is found
    # if program reaches this point, it has skipped spaces and found a non-space, non-NUL or non-new-line-char
    # If non-space, non-new-line-char or non-NUL char found, put this and next three bytes in filtered_input
    bne $s2, $zero, print_more_than_four
    li $s2, 1 # once program reaches this point, 1 is loaded into $s2
    la $a1, filtered_input # load address of filtered_input
    sb $t0, 0($a1)
    lb $t0, 1($a0)
    sb $t0, 1($a1)
    lb $t0, 2($a0)
    sb $t0, 2($a1)
    lb $t0, 3($a0)
    sb $t0, 3($a1)
    addi $a0, $a0, 3

    skip:
    addi $a0, $a0, 1
    jal filter_loop

    exit_filter_loop:
    # if $s2 is still 0, it means that either the user input is empty or the has only spaces
    beqz $s2, print_empty






    li $s0, 1                                   # number to multiply 36 with after each iteration of valid char
    li $s1, 0                                   # sum number based on calculation in each iteration
    li $s4, 0                                   # loop counter
    addi $a0, $a0, 4                            # $a0 points to the 5th byte now. It will point to 4th byte after it is decremented by 1 in the loop before loading byte (see below)

    loop:
    # HOW DOES THIS LOOP WORK?
    # Loop starts loading bytes from the 4th position i.e. 3rd offset
    # Exits the loop if invalid value found
    # Ignores NUL as user string can be less than 4 char long

    # Maintain a count of numer of characters read using $s4
    # If count is 4, branch to exit_loop (count starts from 0)
    li $t5, 4
    beq $t5, $s4, loop_exit
    addi $s4, $s4, 1                            # update the value of counter by 1 irrespective of valid/invalid char
    addi $a0, $a0, -1                           # update the value of $a0 so that it points to an address before the previous byte

    lb $t2, 0($a0)                              # get ASCII value of current character
    beqz $t2, loop                              # if the value is NUL, branch to loop start

    li $a1, 10                                  # load new line char in $a1
    beq $a1, $t2, loop                          # go to loop start if it is new line char. this is useful when user input is less than 4 char. if input 3 char, 4th byte will be new line char

    # Now that $t2 does not have NUL or new line char, check if the char is valid in 36-base system
    addi $t0, $zero, 47
    slt $t1, $t0, $t2
    slti $t4, $t2, 58
    and $s5, $t1, $t4                           # if $t2 has value within range 48 and 57, $s5 will have 1, else 0
    addi $s3, $t2, -48                          # $s3 has required value used for calulation later
    li $t7, 1
    beq $t7, $s5, calculation                   # if $s5 already has 1, calculate the char's value from ASCII and skip other checks and branch to calculation

    addi $t0, $zero, 64
    slt $t1, $t0, $t2
    slti $t4, $t2, 91
    and $s5, $t1, $t4                           #if $t2 has value within range 65 and 90, $s5 will have 1, else 0
    addi $s3, $t2, -55                          # $s3 has required value used for calulation later
    li $t7, 1
    beq $t7, $s5, calculation                   # if $s5 already has 1, calculate the char's value from ASCII and skip other checks and branch to calculation

    addi $t0, $zero, 96
    slt $t1, $t0, $t2
    slti $t4, $t2, 123
    and $s5, $t1, $t4                           #if $t2 has value within range 97 and 122, $s5 will have 1, else 0
    addi $s3, $t2, -87
    li $t7, 1
    beq $t7, $s5, calculation                   # if $s5 already has 1, calculate the char's value from ASCII and skip other checks and branch to calculation

    # If $s5 is still 0, it means that $t2 has an invalid char in base-36 system
    beq $s5, $zero, print_invalid_value         # if $t2 has invalid value, jump to print_invalid_value

    calculation:
    mult $s0, $s3                               # $s0 is the required power of 36 and $s3 is the value of valid char in 36-base number system
    mflo $t3
    add $s1, $s1, $t3                           # add the above multiplication to the value resulting from calculation of previous chars

    # Calculate the value of $s0 for next round of multiplication. Current value should be multiplied by 36, if the previous char was valid and used in calculation
    li $t6, 36
    mult $s0, $t6
    mflo $s0

    # Start the loop again
    jal loop

    # Program reaches this point after successful reading of user string and successful calculation of it's unsigned decimal value
    loop_exit:
    li $v0, 1                                   # load code to print integer
    add $a0, $zero, $s1                         # load value calculated in the loop
    syscall
    jal exit

    print_empty:
    la $a0, input_is_empty                      # load address of the string to print
    li $v0, 4                                   # load code to print string
    syscall
    jal exit

    print_invalid_value:
    la $a0, invalid_number                      # load address of the string to print
    li $v0, 4                                   # load code to print string
    syscall
    jal exit

    print_more_than_four:
    la $a0, input_too_long                      # load address of the string to print
    li $v0, 4                                   # load code to print string
    syscall

    exit:
    li $v0, 10                                  # load code to exit the program
    syscall
