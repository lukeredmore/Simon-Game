const readline = require('readline');

function wait(msec) { 
    return new Promise((resolve, _) => {
        setTimeout(resolve, msec);
    });
}

button = 0

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});
rl.input.on('keypress', async (key) => {
  if (key === '1' || key === '2' || key === '3' || key === '4') {
    button = Number.parseInt(key)
  }
});


const game = async () => {
    let pattern = []                                                    //addi $one, $zero, 1
    let patternLength = 0                                               //addi $patternlength, $zero, 0
    gameLoop:                                                           //gameLoop:
    while (true) {                                                      //nop                                  
        const randomInt =  Math.floor(Math.random() * 4) + 1            //lw $random <MEM[random_addr]>
        pattern.push(randomInt)                                         //sw $random 0($patternlength)
        patternLength = patternLength + 1                               //addi $patternlength, $patternlength, 1
                                                                        //addi $patternindex, $0, 0
                                                                        //displayLoop: bne $patternlength, $patternindex, continueDisplayLoop
                                                                        //j startButtonLoop
                                                                        //continueDisplayLoop: lw $currentdisplay, 0($patternindex)
                                                                        //sw $currentdisplay, <MEM[display_addr]>
                                                                        //addi $patternindex, $patternindex, 1
                                                                        //j displayLoop
        await displayPattern()                                          //startButtonLoop:
        let count = 0                                                   //addi $count, $zero, 0
        waitForButtonLoop:                                              //waitForButtonLoop:
        while (patternLength > count) {                                 //  bne $patternlength, $count, continueButtonLoop
                                                                        //  j gameLoop
                                                                        //  continueButtonLoop: lw $button <MEM[button_addr]>
            if (button != 0) {                                          //  blt $button, $one, waitForButtonLoop
                const expected = pattern[count]                         //  lw $expected 0($count)
                if (button !== expected) { break gameLoop }             //  bne $button, $expected, gameOver
                button = 0                                              //  sw $0 <MEM[button_addr]>
                count = count + 1                                       //  addi $count, $count, 1
            }                                                           // nop                         
            await wait(10)                                              // nop
        }                                                               //  j waitForButtonLoop
    }                                                                   //j gameLoop (probably unnecessary)
                                                                        //gameOver:
    console.log("Game over!")                                           //nop
    rl.close()                                                          //nop
}                                                                       //nop
const displayPattern = async () => {                                    //displayPattern:
    process.stdout.write("\nNew pattern: ");                            //addi <i> $0, 0
    for (i = 0; i < patternLength; i++) {                               //displayLoop:
        process.stdout.write(pattern[i] + " ");                         //<console out MEM[i]>
        await wait(500)                                                 //nop                 
    }                                                                   //addi <i> <i>, 1
    console.log("\nYour turn")
}


game()