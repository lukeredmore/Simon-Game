module right_shift(out, in, amt);
    input [31:0] in;
    input [4:0] amt;
    output [31:0] out;
    wire [31:0] shift16, shift8, shift4, shift2;

    right_shift_N #(.N(16)) shift_16(shift16, in, amt[4]);
    right_shift_N #(.N(8)) shift_8(shift8, shift16, amt[3]);
    right_shift_N #(.N(4)) shift_4(shift4, shift8, amt[2]);
    right_shift_N #(.N(2)) shift_2(shift2, shift4, amt[1]);
    right_shift_N #(.N(1)) shift_1(out, shift2, amt[0]);
endmodule