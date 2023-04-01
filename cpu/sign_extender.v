module sign_extender_17(
    output [31:0] extended,
    input [16:0] in_17);

    assign extended = in_17[16] ? {{15{1'b1}}, in_17} : {{15{1'b0}}, in_17};
endmodule