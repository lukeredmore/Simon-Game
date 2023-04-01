module left_shift_N(out, in, enable);
    parameter N = 2;
    input [31:0] in;
    input enable;
    output [31:0] out;

    genvar k;
    generate
      for (k = 0; k < N; k = k + 1) begin
        assign out[k] = enable ? 0 : in[k];
      end
      for (k = N; k < 32; k = k + 1) begin
        assign out[k] = enable ? in[k-N] : in[k];
		  end
	endgenerate
endmodule