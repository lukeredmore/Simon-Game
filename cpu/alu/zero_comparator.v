module zero_comparator(out, in);
    input [7:0] in;
    output out;

    nor op(out, in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]);
endmodule