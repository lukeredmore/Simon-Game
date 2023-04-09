nop
nop
nop
lw $r14, 2000($r0)
add $r14, $r0, $r0
loop: bne $r14, $r0, continue
lw $r14, 1000($r0)
j loop
continue:
lw $r14, 2000($r0)
jal delay
add $r14, $r0, $r0
jal delay
nop
nop
j continue

delay:
    addi $r1, $r0, 4
    sll $r1, $r1, 20
    addi $r2, $r1, 0
    delayLoop:
        blt $r2, $r0, enddelay
        addi $r2, $r2, -1
    j delayLoop
enddelay:
jr $r31