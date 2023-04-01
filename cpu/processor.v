/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB,                   // I: Data from port B of RegFile
	 
	// Mine
	PC_out
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;
	
	//Mine
	output [31:0] PC_out;

    // Program Counter
	wire [31:0] PC, PC_inc, PC_in, PC_in_bp, PC_branched;
    assign address_imem = PC;
    assign PC_out = PC;
    wire stall, ctrlD_PCinToRegFileOut, shouldBranch;
    assign PC_in = shouldBEX 
        ? IR_D[26:0] 
        : ctrlD_PCinToRegFileOut
            ? PC_in_bp
            : q_imem[31:27] == 1 || q_imem[31:27] == 3 //j or jal
                ? q_imem[26:0] 
                : PC_inc;
	register_32 ProgramCounter(
        // out
       .data_out(PC), 
       // in
       .data_in(shouldBranch ? PC_branched : PC_in), 
       .clk(~clock), // falling edge
       .in_enable(~stall), 
       .clr(reset)
    );
    cla_32 PCIncrementer(
        // out
        .S(PC_inc), 
        // in
        .A(PC),
        .B(32'b1),
        .Cin(1'b0)
    );

    // FD Latch
    wire [31:0] IR_D, PC_D;
    wire ctrlD_FetchRdInsteadOfRt, ctrlD_insertNopInF, ctrlD_readR30, shouldBEX;
    FD FDLatch(
        // Out
        .IR(IR_D),
        .PC(PC_D),
        .ctrlD_FetchRdInsteadOfRt(ctrlD_FetchRdInsteadOfRt),
        .ctrlD_PCinToRegFileOut(ctrlD_PCinToRegFileOut),
        .ctrlD_insertNopInF(ctrlD_insertNopInF),
        .ctrlD_readR30(ctrlD_readR30),
        // In
        .write_enable(~stall),
        .IR_in(ctrlD_insertNopInF || shouldBEX || shouldBranch ? {32'b0} : q_imem),
        .PC_in(PC_inc),
        .clock(clock),
        .reset(reset)
    );
    assign ctrl_readRegA = ctrlD_readR30 ? {5'b11110} : IR_D[21:17]; // $rs
    assign ctrl_readRegB = ctrlD_FetchRdInsteadOfRt ? IR_D[26:22] : IR_D[16:12]; // $rd || $rt
    assign shouldBEX = ctrlD_readR30 && data_readRegA != 0;

    wire RdBeingWrittenToAhead, loadOutputToALUInput;
    assign RdBeingWrittenToAhead = (IR_X > 0 && IR_D[26:22] == IR_X[26:22]) || (IR_M != 0 && IR_D[26:22] == IR_M[26:22]);

    // DX Latch
    wire [31:0] A_X, B_X, IR_X, PC_X, ALU_out, A_X_Bp, B_X_Bp;
    wire ctrlX_ALUsImm, ctrlX_startMult,ctrlX_startDiv, ctrlX_setPCtoOin, ctrlX_isBNE, ctrlX_isBLT;
    DX DXLatch(
        // Out
        .IR(IR_X),
        .PC(PC_X),
        .A(A_X),
        .B(B_X),
        .ctrlX_ALUsImm(ctrlX_ALUsImm),
        .ctrlX_startMult(ctrlX_startMult),
        .ctrlX_startDiv(ctrlX_startDiv),
        .ctrlX_setPCtoOin(ctrlX_setPCtoOin),
        .ctrlX_isBNE(ctrlX_isBNE),
        .ctrlX_isBLT(ctrlX_isBLT),
        // In
        .IR_in(stall || shouldBranch ? {32'b0} : IR_D),
        .PC_in(PC_D),
        .A_in(data_readRegA),
        .B_in(data_readRegB),
        .clock(clock),
        .reset(reset)
    );
    wire [31:0] Imm_SE_X;
    sign_extender_17 SE_X(.extended(Imm_SE_X), .in_17(IR_X[16:0]));
    cla_32 PCBranchDest(
        // out
        .S(PC_branched), 
        // in
        .A(PC_X),
        .B(Imm_SE_X),
        .Cin(1'b0)
    );
    assign shouldBranch = alu_is_not_equal && ctrlX_isBNE || alu_is_less_than && ctrlX_isBLT;
    wire alu_is_not_equal, alu_is_less_than, alu_overflow;
    alu ALU(
        .data_operandA(ctrlX_isBLT ? B_X_Bp : A_X_Bp), 
        .data_operandB(ctrlX_isBLT ? A_X_Bp : ctrlX_ALUsImm ? Imm_SE_X : B_X_Bp), 
        .ctrl_ALUopcode(ctrlX_ALUsImm ? 5'b0 : ctrlX_isBLT | ctrlX_isBNE ? 5'b1 : IR_X[6:2]), 
        .ctrl_shiftamt(IR_X[11:7]),
        .data_result(ALU_out),
        .overflow(alu_overflow),
        .isNotEqual(alu_is_not_equal),
        .isLessThan(alu_is_less_than)
    );
    wire muldiv_ready, muldiv_exception;
    wire [31:0] muldiv_result;
    multdiv Multiplier(
        // In
        .data_operandA(A_X_Bp), 
        .data_operandB(B_X_Bp),
        .ctrl_MULT(ctrlX_startMult), 
        .ctrl_DIV(ctrlX_startDiv), 
	    .clock(clock),
        // Out
        .data_resultRDY(muldiv_ready),
        .data_exception(muldiv_exception),
        .data_result(muldiv_result)
    );
    wire [31:0] P_PW, IR_PW, muldiv_exception_value;
    wire ctrlPW_RegInToPOut, ctrlPW_RegfileWe, multdiv_operating;
    assign muldiv_exception_value = IR_PW[6:2] == 6 & IR_PW[31:27] == 0 //mult
        ? 4
        : IR_PW[6:2] == 7 & IR_PW[31:27] == 0 //div
            ? 5
            : 32'bX;
    PW PWLatch(
        // Out
        .IR(IR_PW),
        .P(P_PW),
        .ctrlPW_RegInToPOut(ctrlPW_RegInToPOut),
        .ctrlPW_RegfileWe(ctrlPW_RegfileWe),
        .isOperating(multdiv_operating),
        // In
        .IR_in(IR_X),
        .P_in(muldiv_result),
        .dataReady(muldiv_ready),
        .clock(clock),
        .reset(reset)
    );
    jal_bypass JalBypasser(
        .PC_X(PC_X),
        .IR_D(IR_D),
        .IR_X(IR_X),
        .PC_in_default(data_readRegB),
        .PC_in_bp(PC_in_bp)
    );

    loadOutputToALUInputDetector BypassStallDetector(
        .IR_X(IR_X),
        .IR_D(IR_D),
        .loadOutputToALUInput(loadOutputToALUInput)
    );

    assign stall = ctrlX_startMult | ctrlX_startDiv | multdiv_operating | loadOutputToALUInput | (ctrlD_PCinToRegFileOut && RdBeingWrittenToAhead);

    // XM Latch
    wire [31:0] O_M, B_M, IR_M, exception_value;
    assign exception_value = IR_X[31:27] == 5 ? 2 : IR_X[6:2] == 0 & IR_X[31:27] == 0 ? 1 : IR_X[6:2] == 1 & IR_X[31:27] == 0 ? 3 : 32'bX;
    XM XMLatch(
        // Out
        .IR(IR_M),
        .O(O_M),
        .B(B_M),
        .ctrlM_DmemWe(wren),
        // In
        .IR_in(IR_X),
        .O_in(ctrlX_setPCtoOin ? PC_X : ALU_out),
        .B_in(B_X),
        .exception_value(alu_overflow ? exception_value : 32'b0),
        .clock(clock),
        .reset(reset)
    );
    assign address_dmem = O_M;
    assign data = B_M_Bp;

    // MW Latch
    wire [31:0] O_W, D_W, IR_W;
    wire ctrlW_RegInToMemOut, ctrlW_RegfileWe, ctrlW_WriteToR31, ctrlW_WriteToR30;
    MW MWLatch(
        // Out
        .IR(IR_W),
        .O(O_W),
        .D(D_W),
        .ctrlW_RegInToMemOut(ctrlW_RegInToMemOut),
        .ctrlW_RegfileWe(ctrlW_RegfileWe),
        .ctrlW_WriteToR31(ctrlW_WriteToR31),
        .ctrlW_WriteToR30(ctrlW_WriteToR30),
        // In
        .IR_in(IR_M),
        .O_in(O_M),
        .D_in(q_dmem),
        .clock(clock),
        .reset(reset)
    );
    assign ctrl_writeReg = ctrlW_WriteToR30 
        ? {5'b11110} 
        : ctrlW_WriteToR31 
            ? {5'b11111} 
            : (ctrlPW_RegInToPOut && muldiv_ready 
                ? muldiv_exception 
                    ? {5'b11110} 
                    : IR_PW[26:22] 
                : IR_W[26:22]);
    assign data_writeReg = ctrlW_WriteToR30 
        ? IR_W[26:0] 
        : ctrlPW_RegInToPOut && muldiv_ready 
            ? muldiv_exception 
                ? muldiv_exception_value 
                : P_PW 
            : (ctrlW_RegInToMemOut ? D_W : O_W);
    assign ctrl_writeEnable = ctrlW_RegfileWe | ctrlPW_RegfileWe;

    wire [31:0] B_M_Bp;
    bypass Bypasser(
        // In
        .IR_X(IR_X),
        .IR_M(IR_M),
        .IR_W(IR_W),
        .Regfile_in(data_writeReg),
        .M_O(O_M),
        .M_B(B_M),
        .X_A(A_X),
        .X_B(B_X),
        // Out
        .DX_out_A(A_X_Bp),
        .DX_out_B(B_X_Bp),
        .XM_out_B(B_M_Bp)
    );

endmodule
