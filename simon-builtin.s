# The simon game running fully on FPGA, using the built in buttons as input  and leds to show pattern
nop
nop
nop
# aside: lw $r1, 2000($0)  
# nop
# nop
# addi $r14, $r1, 0
# nop
# nop
# jal delay
# nop
# nop
# addi $r14, $r0, 7
# nop
# nop
# jal delay
# nop
# nop
# j aside
# nop
# nop
# start:
# real game start
addi $one, $one, 1
add $patternlength, $zero, $zero
gameLoop:                                  
    lw $random 2000($0)                                     # get random value for pattern
    sw $random 0($patternlength)                            # store it in mem array
    addi $patternlength, $patternlength, 1                  # increase the length
    addi $patternindex, $0, 0                               # set display index = 0
    displayLoop:
        # jal delay
        # nop
        # nop
        jal delay
        bne $patternlength, $patternindex, continueDisplay  # display only iff index in range
        # nop
        # nop
        j startButtonListener                               # else start listening for button press
        continueDisplay: 
        lw $currentdisplay, 0($patternindex)                # load pattern val from mem
        addi $r14, $currentdisplay, 0                       # write to led output (for now)
        jal delay
        addi $r14, $r0, 0
        addi $patternindex, $patternindex, 1                # increment index
    j displayLoop                                           
    startButtonListener:
        addi $count, $zero, 0                               # start with zero correct values in count
        #sw $0, 1001($0) (legacy from 
    waitForButtonLoop:
        bne $patternlength, $count, continueButtonLoop      # once we have as many correct values in button,
        j gameLoop                                          # jump to add a new value and extend pattern
        continueButtonLoop: lw $button 1000($0)             # read value at button address
        blt $button, $one, waitForButtonLoop                # if no value of button, try loading again
        lw $expected 0($count)                              # load expected value of pattern
        bne $button, $expected, gameOver                    # if they don't match, game over
        jal waitForButtonRelease                            # don't go on until button is released
        addi $count, $count, 1                              # increment counter
    j waitForButtonLoop
waitForButtonRelease: lw $button 1000($0)
    # nop
    # nop
    bne $button, $r0, waitForButtonRelease
    # nop
    # nop
    jr $r31

delay:
    addi $delayval, $zero, 1
    sll $delayval, $delayval, 22
    addi $delaycounter, $delayval, 0
    delayLoop:
        blt $delaycounter, $zero enddelay
        addi $delaycounter, $delaycounter, -1
    j delayLoop
enddelay: jr $r31

gameOver:
    jal delay
    addi $r15, $r0, 1
    sll $r15, $r15, 15
    addi $r14, $r15, -1
    jal delay
    addi $r14, $r0, 0
j gameOver

# assemble: ./assembler/asm -r ./assembler/custom-regs.csv simon-builtin.s && mv simon-builtin.mem ./assembler-out/simon-builtin.mem
