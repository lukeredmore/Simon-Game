module bypass(
    input [31:0] IR_X,
    input [31:0] IR_M,
    input [31:0] IR_W,

    input [31:0] Regfile_in,
    input [31:0] M_O,
    input [31:0] M_B,
    input [31:0] X_A,
    input [31:0] X_B,

    output [31:0] DX_out_A,
    output [31:0] DX_out_B,
    output [31:0] XM_out_B
);

    wire [4:0] X_dep_1, X_dep_2;
    wire X_needsAluOpA, X_needsAluOpB;
    instruction_decoder XDecoder(
        .instruction(IR_X),
        .needsAluOpA(X_needsAluOpA),
        .needsAluOpB(X_needsAluOpB),
        .dependency_reg_A(X_dep_1), // Rs
        .dependency_reg_B(X_dep_2) // Rt or Rd, depending on what is dependent
    );

    wire [4:0] M_mod, M_dep_2;
    wire M_modifies, M_setx;
    wire [26:0] M_T;
    instruction_decoder MDecoder(
        .instruction(IR_M),
        .modifying_reg(M_mod),
        .modifies_reg(M_modifies),
        .setx(M_setx),
        .dependency_reg_B(M_dep_2),
        .T(M_T)
    );

    wire [4:0] W_mod;
    wire W_modifies;
    instruction_decoder WDecoder(
        .instruction(IR_W),
        .modifying_reg(W_mod),
        .modifies_reg(W_modifies)
    );

    assign DX_out_A = X_needsAluOpA 
        ? (X_dep_1 == M_mod & M_modifies // input to alu is currently in M stage, intercept it
            ? (M_setx ? {5'b0, M_T} : M_O)
            : X_dep_1 == W_mod & W_modifies // input to alu is currently being written to regfile, intercept it
                ? Regfile_in
                : X_A)
        : X_A;
    
    assign DX_out_B = X_needsAluOpB
        ? (X_dep_2 == M_mod & M_modifies // input to alu is currently in M stage, intercept it
            ? (M_setx ? {5'b0, M_T} : M_O)
            : X_dep_2 == W_mod & W_modifies // input to alu is currently being written to regfile, intercept it
                ? Regfile_in
                : X_B)
        : X_B;

    //only matters for sw instruction
    assign XM_out_B = W_modifies && W_mod == M_dep_2 ? Regfile_in : M_B;
endmodule