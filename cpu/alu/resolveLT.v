// Calculates A < B given A, B, and A - B. A < B is inherently true if A is negative and B is positive, and inherently false if A
// is positive and B is negative. This module tries to resolve LT using that simpler case first, if it can't (because they share a 
// sign), we know that A < B is true if A - B < 0
module resolveLT(isLT, A, B, subtraction_result, isZero);
    input [31:0] A, B, subtraction_result; 
    input isZero;
    output isLT;

    wire isPositive, aPositive, bPositive;
    not pos(isPositive, subtraction_result[31]);
    not aPos(aPositive, A[31]);
    not bPos(bPositive, B[31]);

    wire aPos_bNeg, aNeg_bPos, not_aPos_bNeg;
    and aPosbNeg(aPos_bNeg, aPositive, B[31]);
    and aNegbPos(aNeg_bPos, bPositive, A[31]);
    not notaPosbNeg(not_aPos_bNeg, aPos_bNeg);

    wire lt_by_sub, inh_LT;
    and inhLT(inh_LT, not_aPos_bNeg, aNeg_bPos);
    nor ltbsub(lt_by_sub, aPos_bNeg, aNeg_bPos, isPositive, isZero);
    or lt(isLT, lt_by_sub, inh_LT);
endmodule