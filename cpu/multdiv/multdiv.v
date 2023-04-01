module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // overflow handling
    wire unexpected_sign_mult, unexpected_sign_div, significant_upper;
    wire [31:0] upper_result;
    assign upper_result = expect_negative_result ? ~AQ[64:33] : AQ[64:33];
    assign significant_upper = |upper_result;
    assign unexpected_sign_mult = expect_negative_result ^ sign_corrected_result[31];
    assign unexpected_sign_div = unexpected_sign_mult & |sign_corrected_result;
    assign data_exception = ~ctrl_MULT & ~ctrl_DIV ? (should_div ?
        unexpected_sign_div | M_is_zero : 
        unexpected_sign_mult | significant_upper) : 1'b0;

    // latch mult or div
    wire should_div_prelim, should_div;
    assign should_div = ~ctrl_MULT & (should_div_prelim | ctrl_DIV);
    dffe_ref ShouldDiv(
        .q(should_div_prelim),
        .d(ctrl_DIV),
        .clk(clock),
        // .clr(ctrl_MULT | ctrl_DIV),
        .en(ctrl_MULT | ctrl_DIV));

    // expect a negative result?
    wire expect_negative_result;
    dffe_ref ExpectNegative(
        .q(expect_negative_result),
        .d(
            (data_operandA[31] ^ data_operandB[31]) & // 1 if the MSB of operands differ (negative */ pos) AND
            |data_operandA &  // both operands non-zero (bc -1 */ 0 = 0, doesn't follow sign rule)
            |data_operandB  // note this doesn't account for 2 / -5 = 0, where neither operand is zero but the sign is unexpected
        ),
        .clk(clock),
        .en(ctrl_MULT | ctrl_DIV));

    // correct signs for div
    wire [31:0] data_operandA_positive;
    make_positive APos(
        .out(data_operandA_positive),
        .in(data_operandA),
        .enable(1'b1));
    wire [31:0] data_operandB_positive;
    make_positive BPos(
        .out(data_operandB_positive),
        .in(data_operandB),
        .enable(1'b1));
    wire [31:0] sign_corrected_result;
    make_negative CorrectResultSign(
        .out(sign_corrected_result),
        .in(AQ[32:1]),
        .enable(should_div & expect_negative_result));

    // controller
    wire A_add_zero, M_negate, M_sl1, AQ_we, AQ_sra2, count_is_zero, ready;
    assign data_resultRDY = ready | (should_div & M_is_zero);
    control Controller(
        //out
        .A_add_zero(A_add_zero), 
        .M_negate(M_negate), 
        .M_sl1(M_sl1), 
        .AQ_we(AQ_we), 
        .AQ_sra2(AQ_sra2),
        .count_is_zero(count_is_zero),
        .ready(ready),
        //in
        .start(ctrl_MULT | ctrl_DIV),
        .should_div(should_div),
        .llsb_Q(AQ[2:0]),
        .mmsb_A(AQ[65]),
        .clock(clock));

    // M register holds the constant multiplicand in mult and the constant divisor in div
    // Note that for mult, M will be inverted/sl1 to implement modified Booth's logic,
    // since M is passed directly to the adder
    wire [31:0] M;
    wire M_is_zero;
    m_register_32 M_Register(
        // out
        .data_out(M), 
        .is_zero(M_is_zero),
        // in
        .data_in(should_div ? data_operandB_positive : data_operandA), 
        .clk(clock), 
        .in_enable(ctrl_DIV | ctrl_MULT), 
        .sl1_enable(M_sl1), 
        .invert(M_negate),
        .clr(1'b0));

    // adder
    wire [31:0] adder_out;
    wire AQ_sl1_in0, AQ_sl1_in1;
    assign AQ_sl1_in0 = should_div & (ctrl_DIV | adder_out[31]);
    assign AQ_sl1_in1 = should_div & ~ctrl_DIV & ~adder_out[31];
    cla_32 Adder(
        // out
        .S(adder_out), 
        // in
        .A(AQ[64:33]), 
        .B(A_add_zero ? {32{1'b0}} : M), 
        .Cin(M_negate & ~A_add_zero));

    wire [65:0] AQ, AQ_in, AQ_init;
    assign AQ_in = {adder_out[31], adder_out, AQ[32:0]};
    assign AQ_init = should_div ? {{33{1'b0}}, data_operandA_positive, 1'b0} : {{33{1'b0}}, data_operandB, 1'b0};
    assign data_result = data_exception ? {32{1'b0}} : sign_corrected_result;
    shift_register_66 AQ_Register(
        // out
        .q(AQ), 
        // in
        .d(ctrl_DIV | ctrl_MULT ? AQ_init : AQ_in), 
        .clk(clock), 
        .in_enable(ctrl_DIV | ctrl_MULT | AQ_we), 
        .sra2_enable(AQ_sra2),
        .sl1_in0(AQ_sl1_in0), 
        .sl1_in1(AQ_sl1_in1), 
        .clr(1'b0));

    // Test wires for gtkwave
    wire [31:0] A, Q;
    wire Q_prev_lsb, A_prev_msb;
    wire [2:0] AQ_lsb; 
    assign Q_prev_lsb = AQ[0];
    assign A_prev_msb = AQ[65];
    assign AQ_lsb = AQ[2:0];
    assign Q = AQ[32:1];
    assign A = AQ[64:33]; 
endmodule