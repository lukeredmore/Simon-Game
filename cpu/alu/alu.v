module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
    input [31:0] data_operandA, data_operandB; 
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] B, adder_out, notB, and_out, or_out, sll_out, sra_out;

    // Flip B and carry-in if subtraction enabled
    wire isSubtraction, isZero;
    decoder_3 dec(.d1(isSubtraction), .in(ctrl_ALUopcode[2:0]));
    not not_B [31:0] (notB, data_operandB);
    assign B = isSubtraction ? notB : data_operandB;

    // Ops (adder takes care of everything but shifts)
    cla_32 adder(adder_out, and_out, or_out, isZero, overflow, data_operandA, B, isSubtraction);
    left_shift ls(sll_out, data_operandA, ctrl_shiftamt);
    right_shift rs(sra_out, data_operandA, ctrl_shiftamt);

    // Resolve A != B and A < B. The latter takes slightly more work, so I put it in a separate module
    not zero(isNotEqual, isZero);
    resolveLT lt(isLessThan, data_operandA, data_operandB, adder_out, isZero);

    // And mux the result based on opcode
    mux_8 mux(data_result, ctrl_ALUopcode[2:0], adder_out, adder_out, and_out, or_out, sll_out, sra_out, 0, 0);
endmodule