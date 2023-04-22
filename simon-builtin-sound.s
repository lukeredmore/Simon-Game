# The simon game running fully on FPGA, using the built in buttons as input  and leds to show pattern
nop
nop
nop
# aside:
# addi $r14, $r0, 1
# jal delay
# sll $r14, $r14, 16
# jal delay
# addi $r14, $r14, -1
# jal delay

# addi $r1, $r0, 32 #b0_0010_0000 #h0020
# addi $r2, $r0, 2
# sw $r1, 4000($r2)

# addi $r1, $r0, 1 #b0_0000_0001 #h0001
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 2 #b0_0000_0010 #h0002
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 12 #b0_0000_1100 #h000c
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 333 #77 + 256 #h014d #b1_0100_1101
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 335 #79 + 256 #h014f #b1_0100_1111
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 334 #78 + 256 #h014e #b1_0100_1110
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 325 #69 + 256 #h0145 #b1_0100_0101
# addi $r2, $r2, 1
# sw $r1, 4000($r2)

# addi $r1, $r0, 345 #89 + 256 #h0159 #b1_0101_1001
# addi $r2, $r2, 1
# sw $r1, 4000($r2)
# nop
# nop
# # try lw from 4000 and see whats there
# nop
# jal delay
# jal delay

# addi $r2, $r0, 2
# nop
# nop
# lw $r14, 4000($r2)
# jal delay
# jal delay

# addi $r2, $r2, 1
# nop
# nop
# lw $r14, 4000($r2)
# jal delay
# jal delay

# addi $r2, $r2, 1
# nop
# nop
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# nop
# nop
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# nop
# nop
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# nop
# nop
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# lw $r14, 4000($r2)
# jal delay
# jal delay
# addi $r2, $r2, 1
# lw $r14, 4000($r2)
# jal delay
# jal delay
nop
nop
# j aside
nop
nop
addi $patternlength, $patternlength, 1 
nop
nop
jal displayScore
nop
nop

start:
# real game start
addi $one, $one, 1
add $patternlength, $zero, $zero
gameLoop:
    lw $random 2000($0)                                     # get random value for pattern
    sw $random 0($patternlength)                            # store it in mem array
    addi $patternlength, $patternlength, 1                  # increase the length
    addi $patternindex, $0, 0                               # set display index = 0

    nop
        nop
        addi $lcdcommand, $patternlength, -1 #score to display = 1 less than pattern length
        addi $lcdcommand, $lcdcommand, 48 #
        addi $lcdcommand, $lcdcommand, 256
        sw $lcdcommand, 4000($lcdaddr)
        nop
        nop
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
        sw $currentdisplay, 3000($r0)                       # start playing sound
        jal delay
        addi $r14, $r0, 0
        sw $r0, 3000($r0)                                   # stop playing sound
        addi $patternindex, $patternindex, 1                # increment index
    j displayLoop                                           
    startButtonListener:
        addi $count, $zero, 0                               # start with zero correct values in count
        #sw $0, 1001($0) (legacy from 
    waitForButtonLoop:
        bne $patternlength, $count, continueButtonLoop      # once we have as many correct values in button,
        j gameLoop                                          # jump to add a new value and extend pattern
        continueButtonLoop: lw $button 1000($0)             # read value at button address
        jal short_delay
        nop
        blt $button, $one, waitForButtonLoop                # if no value of button, try loading again
        nop
        nop
        lw $expected, 0($count)                              # load expected value of pattern
        bne $button, $expected, gameOverStart                    # if they don't match, game over
        addi $r14, $button, 0
        jal waitForButtonRelease                            # don't go on until button is released
        addi $count, $count, 1                              # increment counter
    j waitForButtonLoop
waitForButtonRelease: lw $button 1000($0)
    sw $button, 3000($r0)          
    addi $r14, $button, 0
    bne $button, $r0, waitForButtonRelease
    nop
    nop
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

short_delay:
    addi $delayval, $zero, 1
    sll $delayval, $delayval, 19
    addi $delaycounter, $delayval, 0
    short_delayLoop:
        blt $delaycounter, $zero enddelay
        addi $delaycounter, $delaycounter, -1
    j short_delayLoop
enddelay: jr $r31

gameOverStart:
    addi $r14, $expected, 0
    addi $r15, $r0, 15
    sw $r15, 3000($r0)
    jal delay
    nop
gameOver:
    jal delay
    sw $r0, 3000($r0)
    addi $r15, $r0, 1
    sll $r15, $r15, 15
    addi $r14, $r15, -1
    jal delay
    addi $r14, $r0, 0
j gameOver

displayScore:
    # 4-bit mode
    addi $lcdcommand, $r0, 32 #b0_0010_0000 #h0020
    addi $lcdaddr, $r0, 2
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    # Clear display
    addi $lcdcommand, $r0, 1 #b0_0000_0001 #h0001
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    # Return home
    addi $lcdcommand, $r0, 2 #b0_0000_0010 #h0002
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    # Display on, no cursor
    addi $lcdcommand, $r0, 12 #b0_0000_1100 #h000c
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1    

    # S
    addi $lcdcommand, $r0, 339 #b1_0010_10011
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1    

    # C
    addi $lcdcommand, $r0, 323
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    # O
    addi $lcdcommand, $r0, 335 #b1_0100_1111
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    # R
    addi $lcdcommand, $r0, 338 #b1_0101_0010
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    # E
    addi $lcdcommand, $r0, 325 #b1_0100_0101
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    # :
    addi $lcdcommand, $r0, 314 #b1_0011_1010
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    # SP
    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    # score
    addi $lcdcommand, $patternlength, -1 #score to display = 1 less than pattern length
    addi $lcdcommand, $lcdcommand, 48 #
    addi $lcdcommand, $lcdcommand, 256
    sw $lcdcommand, 4000($lcdaddr)
jr $r31

# assemble: ./assembler/asm -r ./assembler/custom-regs.csv simon-builtin-sound.s && mv simon-builtin-sound.mem ./assembler-out/simon-builtin-sound.mem
