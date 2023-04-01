// 66 bit shift register that can sra2 or sl1 on latch. sl1 can shift
// in either a 1 or a zero
module shift_register_66(q, d, clk, in_enable, sra2_enable, sl1_in0, sl1_in1, clr);
    input [65:0] d;
    input clk, in_enable, sra2_enable, sl1_in0, sl1_in1, clr;
    output [65:0] q;

    wire [65:0] d_sra2, d_sl1_in0, d_sl1_in1;
    assign d_sra2 = $signed(d) >>> 2;
    assign d_sl1_in0 = d << 1;
    assign d_sl1_in1 = {d_sl1_in0[65:2], 1'b1, d_sl1_in0[0]};


    genvar i;
    generate
        for (i = 0; i < 66; i = i + 1) begin: loop1
            dffe_ref DFF(
                .clk(clk),
                .clr(clr),
                .d(sra2_enable ? d_sra2[i] : sl1_in0 ? d_sl1_in0[i] : sl1_in1 ? d_sl1_in1[i] : d[i]), 
                .q(q[i]),
                .en(in_enable));
        end
    endgenerate
endmodule