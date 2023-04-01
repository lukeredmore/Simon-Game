// Just a regular 32 bit register with built in sl1 and invert options
module m_register_32(
    // out
    data_out, 
    is_zero,
    // in
    data_in, 
    clk, 
    in_enable, 
    sl1_enable, 
    invert, 
    clr);

    output [31:0] data_out;
    output is_zero;
    input [31:0] data_in;
    input clk, in_enable, sl1_enable, invert, clr;

    wire [31:0] original_out, shifted_out;

    register_32 Register(original_out, data_in, clk, in_enable, clr);
    assign shifted_out = sl1_enable ? original_out << 1 : original_out;
    assign data_out = invert ? ~shifted_out : shifted_out;
    assign is_zero = ~|original_out;
endmodule