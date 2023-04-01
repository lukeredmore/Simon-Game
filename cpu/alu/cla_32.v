module cla_32(S, bw_and, bw_or, isZero, overflow, A, B, Cin);
    input[31:0] A, B;
    input Cin;
    output [31:0] S, bw_and, bw_or;
    output isZero, overflow;
    
    wire c8, c16, c24;
    wire zero1, zero2, zero3, zero4;
    wire [3:0] P, G;

    // Split up into 8-bit chunks and call 8-bit cla for each (hence, two-level) 
    cla_8 add_0(S[7:0], P[0], G[0], bw_and[7:0], bw_or[7:0], zero1, A[7:0], B[7:0], Cin);
    cla_8 add_8(S[15:8], P[1], G[1], bw_and[15:8], bw_or[15:8], zero2, A[15:8], B[15:8], c8);
    cla_8 add_16(S[23:16], P[2], G[2], bw_and[23:16], bw_or[23:16], zero3, A[23:16], B[23:16], c16);
    cla_8 add_24(S[31:24], P[3], G[3], bw_and[31:24], bw_or[31:24], zero4, A[31:24], B[31:24], c24);

    // Calculate carries
    wire c8_prop0;
    wire c16_prop0, c16_prop1;
    wire c24_prop0, c24_prop1, c24_prop2;

    and prop0_1(c8_prop0, P[0], Cin);
    or c8carry(c8, G[0], c8_prop0);

    and prop0_2(c16_prop0, P[1], P[0], Cin);
    and prop1_2(c16_prop1, P[1], G[0]);
    or c16carry(c16, G[1], c16_prop0, c16_prop1);

    and prop0_3(c24_prop0, P[2], P[1], P[0], Cin);
    and prop1_3(c24_prop1, P[2], P[1], G[0]);
    and prop2_3(c24_prop2, P[2], G[1]);
    or c24carry(c24, G[2], c24_prop0, c24_prop1, c24_prop2);

    // Determine if overflow occured by checking if two positives add to a negative or v.v.
    wire added_pos_to_neg, added_negs_to_pos, isPositive;
    not isPos(isPositive, S[31]);
    nor two_positives_add_to_negative(added_pos_to_neg, isPositive, A[31], B[31]);
    and two_negatives_add_to_positive(added_negs_to_pos, isPositive, A[31], B[31]);
    or oflow(overflow, added_negs_to_pos, added_pos_to_neg);

    // Compare indv zeros for total zero
    and zero(isZero, zero1, zero2, zero3, zero4);
endmodule