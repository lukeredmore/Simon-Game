// Main multdiv control module that is responsible for the counter and 
// coordinating the individual mult and div control modules. Depending
// on what op is selected, it will assign all the relevant wires to the
// appropriate control, and set the irrelevant wires to constants (i.e
// disabling AQ_sra2 for divison)
module control(
    //out
    A_add_zero, 
    M_negate, 
    M_sl1, 
    AQ_we, 
    AQ_sra2,
    count_is_zero,
    ready,
    //in
    start,
    should_div,
    llsb_Q,
    mmsb_A,
    clock);

    input [2:0] llsb_Q;
    input clock, start, should_div, mmsb_A;

    output A_add_zero, M_negate, M_sl1, AQ_we, AQ_sra2, count_is_zero, ready;

    assign {
        A_add_zero, 
        M_negate, 
        M_sl1, 
        AQ_we, 
        AQ_sra2, 
        ready} = 
        should_div ? {
            1'b0, 
            div_sub_M, 
            1'b0, 
            div_load_AQ, 
            1'b0,
            div_ready} 
        : {
            mult_do_nothing, 
            mult_sub_M, 
            mult_M_sl1, 
            mult_load_prod, 
            ~start,
            mult_ready
        };

    // counter
    wire [5:0] count;
    assign count_is_zero = &{~count};
    counter_6 Counter(
        .count(count), 
        .clr(start), 
        .clk(clock));

    // mult ctrl
    wire mult_do_nothing, mult_sub_M, mult_M_sl1, mult_load_prod, mult_shift_prod, mult_ready;
    mult_ctrl MultCtrl(
        // out
        .do_nothing(mult_do_nothing), 
        .sub(mult_sub_M), 
        .sl(mult_M_sl1), 
        .load_product(mult_load_prod),
        .shift_product(mult_shift_prod),
        .ready(mult_ready),
        // in
        .lsb(llsb_Q),
        .clk(clock),
        .count(count));

    // div ctrl
    wire div_sub_M, div_load_AQ, div_ready;
    div_ctrl DivCtrl(
        // out
        .sub_M(div_sub_M),
        .load_AQ(div_load_AQ),
        .ready(div_ready),
        // in
        .mmsb_A(mmsb_A),
        .clk(clock),
        .count(count)
    );

endmodule