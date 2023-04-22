`timescale 1ns / 1ps

// Top level module for Simon, used as the interface between FPGA and CPU
module Wrapper (
	input clock, 
	input reset,
	input [3:0] BTN,
	input [15:0] SW,
	input [3:0] JD,
	output [15:0] LED,
	output rs,
	output e,
    output [7:4] d,
	output audioOut,
	output reg audioEn = 0,
	output reg [7:4] JC = 0);

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
	assign cpuMemDataIn = memAddr == 1000 ? (SW[15] ? BTN : JD) : memAddr == 2000 ? rand_encoding : memDataOut; // or JD
    
    wire [31:0] PC;

	localparam INSTR_FILE = "simon-builtin-sound";
	
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
		.lcdOutAddr(lcdOutAddr + 4000),
		.lcdDataOut(lcdDataOut),
		.dataOut(memDataOut));

	// Audio Controller
	reg [3:0] tone = 0;
	AudioController sound(
    	.clk(clk50MHz),
    	.tone(tone),
    	.audioOut(audioOut));

	// reg [3:0] LED_PIN = 0;
	// assign JC[7:4] = LED_PIN[3:0];
	reg [14:0] r14 = 14'd0;
	always @(posedge clk50MHz) begin
        if (rwe & rd == 14) begin 
			r14 <= rData[14:0];
			JC[7:4] <= rData[3:0];
		end
	    if (mwe & memAddr == 3000) begin
			tone <= rData[3:0];
			audioEn <= rData > 0 ? 1 : 0;
	    end
    end
    assign LED[14:0] = r14[14:0];

	// LCD (gross)
	wire [31:0] lcdOutAddr, lcdDataOut;
	mylcdcontroller lcd(
		.clock(clock),
     	.reset(reset),
    	.SW(SW),
		.rom_data(lcdDataOut[8:0]),
		.rom_addr(lcdOutAddr),
		.start(),
    	.rs(rs),
    	.e(e),
    	.d(d)//,
    	// .LED(LED)
	);

	ila_0 debugger(clock, lcdDataOut, lcdOutAddr, memAddr, rData, {31'd0, mwe});

endmodule
