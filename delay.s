addi $delay_mslength, $r0, 1000
start: jal delay_ms
addi $r14, $r14, 1
j start

delay_ms:
    addi $delay_mscounter, $delay_mslength, -1 # minus one because doesn't end until less than 1
    delay_msLoop:
        blt $t1, $zero enddelay
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
enddelay: jr $r31

# assemble: ./assembler/asm -r ./assembler/custom-regs.csv delay.s && mv delay.mem ./assembler-out/delay.mem
