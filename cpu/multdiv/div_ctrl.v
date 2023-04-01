// Set control bits for NRDI
module div_ctrl(
    // out
    sub_M,
    load_AQ,
    ready,
    // in
    mmsb_A,
    clk,
    count
);
    output sub_M, load_AQ, ready;
    input mmsb_A, clk;
    input [5:0] count;

    assign load_AQ = 1'b1;
    assign sub_M = ~mmsb_A;
    assign ready = count[5] & ~count[4] & ~count[3] & ~count[2] & ~count[1] & ~count[0];
endmodule