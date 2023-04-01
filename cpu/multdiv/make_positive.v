// Module where out = |in| if enabled, else out = in
module make_positive(out, in, enable);
    input enable;
    input [31:0] in;
    output [31:0] out;

    wire [31:0] negative_input;
    cla_32 negater(
        // out
        .S(negative_input), 
        // in
        .A({32{1'b0}}), 
        .B(~in), 
        .Cin(1'b1)
    );

    assign out = (enable & in[31]) ? negative_input : in;
endmodule