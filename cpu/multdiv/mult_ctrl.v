// Set control bits for modified booth multiplication based on Q lsbs
module mult_ctrl(
    // out
    do_nothing, 
    sub, 
    sl, 
    load_product,
    shift_product,
    ready,
    // in
    lsb,
    clk,
    count);

    input [2:0] lsb;
    input [5:0] count;
    input clk;
    output do_nothing, sub, sl, load_product, shift_product, ready;
    
    wire count_is_not_zero, count_is_17, count_is_16;
    assign count_is_not_zero = |count;
    assign count_is_17 = ~count[5] & count[4] & ~count[3] & ~count[2] & ~count[1] & count[0];
    assign count_is_16 = ~count[5] & count[4] & ~count[3] & ~count[2] & ~count[1] & ~count[0];


    assign sub = lsb[2];
    assign do_nothing = lsb[2] & lsb[1] & lsb[0] | ~lsb[2] & ~lsb[1] & ~lsb[0];
    assign sl = ~lsb[2] & lsb[1] & lsb[0] | lsb[2] & ~lsb[1] & ~lsb[0];
    assign load_product = 1'b1;
    assign shift_product = 1'b1; //count_is_not_zero;
    assign ready = count_is_16 ? 1'b1 : 1'b0;
endmodule