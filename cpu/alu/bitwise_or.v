module bitwise_or(out, in0, in1);
    input [31:0] in0, in1;
    output [31:0] out;

    or single_or [31:0] (out, in0, in1);
endmodule