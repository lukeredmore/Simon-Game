module register_32(data_out, data_in, clk, in_enable, clr);
    input [31:0] data_in;
    input clk, in_enable, clr;
    output [31:0] data_out;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: loop1
            dffe_ref DFF(
                .clk(clk),
                .clr(clr),
                .d(data_in[i]), 
                .q(data_out[i]),
                .en(in_enable));
        end
    endgenerate
endmodule