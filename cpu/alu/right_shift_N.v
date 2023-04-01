module right_shift_N(out, in, enable);
    parameter N = 5;
    input [31:0] in;
    input enable;
    output [31:0] out;

    genvar k;
    generate
      for (k = 31; k > 31-N; k = k - 1) begin
        assign out[k] = enable ? in[31] : in[k];
      end
      for (k = 31-N; k >= 0; k = k - 1) begin
        assign out[k] = enable ? in[k+N] : in[k];
		  end
	endgenerate
endmodule