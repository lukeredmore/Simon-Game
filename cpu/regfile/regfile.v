module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// Use shifter as decoder
	wire [31:0] input_enable, A_output_enable, B_output_enable;
	left_shift in_dec(input_enable, {{31{1'b0}}, 1'b1}, ctrl_writeReg);
	left_shift A_out_dec(A_output_enable, {{31{1'b0}}, 1'b1}, ctrl_readRegA);
	left_shift B_out_dec(B_output_enable, {{31{1'b0}}, 1'b1}, ctrl_readRegB);

	// Register 0 isn't even a register, just assign 0s if decoder selects it for output
	assign data_readRegA = A_output_enable[0] ? {32{1'b0}} : {32{1'bz}};
	assign data_readRegB = B_output_enable[0] ? {32{1'b0}} : {32{1'bz}};

	genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin: loop1
			wire [31:0] out_temp;
			wire can_write;
			and canWrite(can_write, input_enable[i], ctrl_writeEnable);
            register_32 register(out_temp, data_writeReg, clock, can_write, ctrl_reset);
			assign data_readRegA = A_output_enable[i] ? out_temp : {32{1'bz}};
			assign data_readRegB = B_output_enable[i] ? out_temp : {32{1'bz}};
        end
    endgenerate

endmodule
