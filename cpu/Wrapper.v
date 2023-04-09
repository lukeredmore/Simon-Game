`timescale 1ns / 1ps

// Top level module for Simon, used as the interface between FPGA and CPU
module Wrapper (clock, reset, LED, BTN);
	input clock, reset;
	input [3:0] BTN;
	output [15:0] LED;

    reg clk50MHz = 1'b0;
    reg clockCount = 0;
    always @(posedge clock) begin      
        clockCount <= clockCount + 1;
        if (clockCount == 0)
            clk50MHz <= ~clk50MHz;
     end

    assign LED[15] = clk50MHz;
	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;
	
	wire [3:0] rand_encoding;
	lfsr RandomNumberGenerator(
	.clk(clk50MHz),
	.rand_4_bit_encoding(rand_encoding));
	
	wire [31:0] cpuMemDataIn;
	assign cpuMemDataIn = memAddr == 1000 ? BTN : memAddr == 2000 ? rand_encoding : memDataOut;
    
    wire [31:0] PC;

	localparam INSTR_FILE = "simon-builtin";
	
	// Main Processing Unit
	processor CPU(.clock(clk50MHz), 
	    .reset(~reset), 
		.PC_out(PC),						
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(cpuMemDataIn)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clk50MHz), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clk50MHz), 
		.ctrl_writeEnable(rwe), .ctrl_reset(~reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clk50MHz), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));
	
	reg [14:0] r14 = 14'd0;
	always @(posedge clk50MHz) begin
       if (rwe & rd == 14) r14 <= rData[14:0];
    end
    assign LED[14:0] = r14;

endmodule
