module loadOutputToALUInputDetector(
    input [31:0] IR_X,
    input [31:0] IR_D,
    output loadOutputToALUInput
);

    wire [4:0] D_dep1, D_dep2;
    wire D_sw;
    instruction_decoder DDecoder(
        .instruction(IR_D),
        .sw(D_sw),
        .dependency_reg_A(D_dep1), 
        .dependency_reg_B(D_dep2)
    );

    wire [4:0] X_mod;
    wire X_lw;
    instruction_decoder XDecoder(
        .instruction(IR_X),
        .lw(X_lw),
        .modifying_reg(X_mod)
    );

    assign loadOutputToALUInput = X_lw 
        && (D_dep1 == X_mod //D has a dependency a in x
            || (D_dep2 == X_mod && ~D_sw) //D has a dependency b in x and D isn't a sw
    );
endmodule