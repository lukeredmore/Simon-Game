# The simon game running fully on FPGA, using the built in buttons as input  and leds to show pattern
nop
nop
nop
nop
addi $patternlength, $patternlength, 1 
nop
nop
jal displayScore
nop
nop
# addi $one, $one, 1
# nop
# nop
# sw $one, 3000($r0)                       # start playing test sound
# jal delay
# sw $r0, 3000($r0)   

start:
# real game starts
addi $one, $one, 1
add $patternlength, $zero, $zero
addi $displaydelaylength, $zero, 440
gameLoop:
    lw $random 2000($0)                                     # get random value for pattern
    sw $random 0($patternlength)                            # store it in mem array
    addi $patternlength, $patternlength, 1                  # increase the length
    addi $patternindex, $0, 0                               # set display index = 0

    addi $displaydelaylength, $displaydelaylength, -20
    # Display current score on LCD
    nop
    addi $lcdcommand, $patternlength, -1 #score to display = 1 less than pattern length
    addi $lcdcommand, $lcdcommand, 48 #
    addi $lcdcommand, $lcdcommand, 256
    sw $lcdcommand, 4000($lcdaddr)
    nop
    jal delay
    nop
    displayLoop:
        # jal delay
        # nop
        addi $delay_mslength, $r0, 50
        nop
        nop
        jal delay_ms
        nop
        nop
        bne $patternlength, $patternindex, continueDisplay  # display only iff index in range
        # nop
        # nop
        j startButtonListener                               # else start listening for button press
        continueDisplay: 
        lw $currentdisplay, 0($patternindex)                # load pattern val from mem
        addi $r14, $currentdisplay, 0                       # write to led output (for now)
        sw $currentdisplay, 3000($r0)                       # start playing sound
        add $delay_mslength, $r0, displaydelaylength                      # could change this based on level?
        nop
        nop
        jal delay_ms
        nop
        nop
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
        blt $button, $one, waitForButtonLoop                # if no value of button, try loading again (should add max wait = 3000 ms?)
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
        blt $delaycounter, $zero enddelay_short
        addi $delaycounter, $delaycounter, -1
    j short_delayLoop
enddelay_short: jr $r31

gameOverStart:
    addi $r14, $expected, 0
    addi $r15, $r0, 15
    sw $r15, 3000($r0)
    jal delay
    nop
    nop
    jal displayGameOver
    nop
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

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    addi $lcdcommand, $r0, 288 #b1_0010_0000
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

displayGameOver:
    # Clear display
    addi $lcdaddr, $r0, 2
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

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1 

    addi $lcdcommand, $r0, 327 # 256 + 71 = G
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 321 # 256 + 65 = A
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 333 # 256 + 77 = M
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 325 # 256 + 69 = E
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 288 #b1_0010_0000
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 335 # 256 + 79 = O
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 342 # 256 + 86 = V
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 325 # 256 + 69 = E
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 338 # 256 + 82 = R
    sw $lcdcommand, 4000($lcdaddr)
    addi $lcdaddr, $lcdaddr, 1

    addi $lcdcommand, $r0, 289 #b1_0010_0001 = !
    sw $lcdcommand, 4000($lcdaddr)
jr $r31

delay_ms:
    addi $delay_mscounter, $delay_mslength, -1 # minus one because doesn't end until less than 1
    delay_msLoop:
        blt $delay_mscounter, $zero enddelay_ms
        delay_1ms:
            addi $delay_1counter, $r0, 4998
            delay_1msLoop: 
                blt $delay_1counter, $zero decrement_mili
                nop
                nop
                addi $delay_1counter, $delay_1counter, -1
            j delay_1msLoop
        decrement_mili:
            addi $delay_mscounter, $delay_mscounter, -1
    j delay_msLoop
enddelay_ms: jr $r31

# assemble: ./assembler/asm -r ./assembler/custom-regs.csv simon-builtin-sound.s && mv simon-builtin-sound.mem ./assembler-out/simon-builtin-sound.mem
