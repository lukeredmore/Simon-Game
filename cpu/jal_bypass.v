module jal_bypass(
    input [31:0] PC_X,
    input [31:0] IR_D,
    input [31:0] IR_X,
    input [31:0] PC_in_default,

    output [31:0] PC_in_bp
);

    wire D_jr;
    instruction_decoder DDecoder(
        .instruction(IR_D),
        .jr(D_jr)
    );

    wire X_jal;
    instruction_decoder XDecoder(
        .instruction(IR_X),
        .jal(X_jal)
    );

    assign PC_in_bp = X_jal & D_jr ? PC_X : PC_in_default;

endmodule