module decoder_3(d0, d1, d2, d3, d4, d5, d6, d7, in);
    input [2:0] in;
    output d0, d1, d2, d3, d4, d5, d6, d7;
    wire nin0, nin1, nin2;

    not (nin0, in[0]);
    not (nin1, in[1]);
    not (nin2, in[2]);
    
    and out_0(d0, nin0, nin1, nin2);
    and out_1(d1, in[0], nin1, nin2);
    and out_2(d2, nin0, in[1], nin2);
    and out_3(d3, in[0], in[1], nin2);
    and out_4(d4, nin0, nin1, in[2]);
    and out_5(d5, in[0], nin1, in[2]);
    and out_6(d6, nin0, in[1], in[2]);
    and out_7(d7, in[0], in[1], in[2]);
endmodule