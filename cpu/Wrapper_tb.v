`timescale 1ns / 100ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper_tb();
	reg clock = 0; 
	reg reset = 0;
	reg [3:0] BTN = 0;
	wire [15:0] LED;

     reg clk50MHz = 1'b0;
     reg clockCount = 0;
     always @(posedge clock) begin      
        clockCount <= clockCount + 1;
        if (clockCount == 0)
            clk50MHz <= ~clk50MHz;
     end

	 always
	 	#10 clock <= ~clock;

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

	initial begin
		#100 reset = 1;
		#100 reset = 0;
		#100 reset = 1;
	end
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
	reg [31:0] clockCycleCount = 0;
	always @(posedge clk50MHz) begin
		if (rwe & rd != 0) $display("Wrote %d to r%d", $signed(rData), rd);
    	if (rwe & rd == 14) r14 <= rData[14:0];
		if (clockCycleCount > 1000) $finish;
		else clockCycleCount = clockCycleCount + 1;
    end
    assign LED[14:0] = r14;

endmodule
