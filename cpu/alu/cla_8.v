module cla_8(S, P, G, bw_and, bw_or, isZero, A, B, Cin);
    input [7:0] A, B;
    input Cin;
    output [7:0] S, bw_and, bw_or;
    output P, G, isZero;

    wire c1_prop0; 
    wire c2_prop0, c2_prop1, c3_prop0, c3_prop1, c3_prop2;
    wire c4_prop0, c4_prop1, c4_prop2, c4_prop3;
    wire c5_prop0, c5_prop1, c5_prop2, c5_prop3, c5_prop4;
    wire c6_prop0, c6_prop1, c6_prop2, c6_prop3, c6_prop4, c6_prop5;
    wire c7_prop0, c7_prop1, c7_prop2, c7_prop3, c7_prop4, c7_prop5, c7_prop6;
    wire c8_prop0, c8_prop1, c8_prop2, c8_prop3, c8_prop4, c8_prop5, c8_prop6, c8_prop7;

    // Calculate g's and p's
    wire [7:0] g, p, c;
    assign c[0] = Cin;
    and gen [7:0] (g, A, B);
    or prop [7:0] (p, A, B);

    // Output these verbatim to g and p for AND and OR funcs of ALU
    assign bw_and = g;
    assign bw_or = p;

    // Generate carries and store in c
    and prop0_1(c1_prop0, p[0], Cin);
    or c1carry(c[1], g[0], c1_prop0);

    and prop0_2(c2_prop0, p[1], p[0], Cin);
    and prop1_2(c2_prop1, p[1], g[0]);
    or c2carry(c[2], g[1], c2_prop0, c2_prop1);

    and prop0_3(c3_prop0, p[2], p[1], p[0], Cin);
    and prop1_3(c3_prop1, p[2], p[1], g[0]);
    and prop2_3(c3_prop2, p[2], g[1]);
    or c3carry(c[3], g[2], c3_prop0, c3_prop1, c3_prop2);

    and prop0_4(c4_prop0, p[3], p[2], p[1], p[0], Cin);
    and prop1_4(c4_prop1, p[3], p[2], p[1], g[0]);
    and prop2_4(c4_prop2, p[3], p[2], g[1]);
    and prop3_4(c4_prop3, p[3], g[2]);
    or c4carry(c[4], g[3], c4_prop0, c4_prop1, c4_prop2, c4_prop3);

    and prop0_5(c5_prop0, p[4], p[3], p[2], p[1], p[0], Cin);
    and prop1_5(c5_prop1, p[4], p[3], p[2], p[1], g[0]);
    and prop2_5(c5_prop2, p[4], p[3], p[2], g[1]);
    and prop3_5(c5_prop3, p[4], p[3], g[2]);
    and prop4_5(c5_prop4, p[4], g[3]);
    or c5carry(c[5], g[4], c5_prop0, c5_prop1, c5_prop2, c5_prop3, c5_prop4);

    and prop0_6(c6_prop0, p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    and prop1_6(c6_prop1, p[5], p[4], p[3], p[2], p[1], g[0]);
    and prop2_6(c6_prop2, p[5], p[4], p[3], p[2], g[1]);
    and prop3_6(c6_prop3, p[5], p[4], p[3], g[2]);
    and prop4_6(c6_prop4, p[5], p[4], g[3]);
    and prop5_6(c6_prop5, p[5], g[4]);
    or c6carry(c[6], g[5], c6_prop0, c6_prop1, c6_prop2, c6_prop3, c6_prop4, c6_prop5);

    and prop0_7(c7_prop0, p[6], p[5], p[4], p[3], p[2], p[1], p[0], Cin);
    and prop1_7(c7_prop1, p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and prop2_7(c7_prop2, p[6], p[5], p[4], p[3], p[2], g[1]);
    and prop3_7(c7_prop3, p[6], p[5], p[4], p[3], g[2]);
    and prop4_7(c7_prop4, p[6], p[5], p[4], g[3]);
    and prop5_7(c7_prop5, p[6], p[5], g[4]);
    and prop6_7(c7_prop6, p[6], g[5]);
    or c7carry(c[7], g[6], c7_prop0, c7_prop1, c7_prop2, c7_prop3, c7_prop4, c7_prop5, c7_prop6);

    // This was used to find the carry-out, but not needed for 2 level, mostly still needed for G
    and prop1_8(c8_prop1, p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and prop2_8(c8_prop2, p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
    and prop3_8(c8_prop3, p[7], p[6], p[5], p[4], p[3], g[2]);
    and prop4_8(c8_prop4, p[7], p[6], p[5], p[4], g[3]);
    and prop5_8(c8_prop5, p[7], p[6], p[5], g[4]);
    and prop6_8(c8_prop6, p[7], p[6], g[5]);
    and prop7_8(c8_prop7, p[7], g[6]);
    
    // S for each bit i is the xor of Ai, Bi and Ci. Compare to zero as well
    xor Sresult [7:0] (S, c, A, B);
    zero_comparator zero(isZero, S);

    // Calculate P and G for level 2
    and Pout(P, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    or Gout(G, g[7], c8_prop1, c8_prop2, c8_prop3, c8_prop4, c8_prop5, c8_prop6, c8_prop7);
endmodule