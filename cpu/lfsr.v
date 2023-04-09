module lfsr(
  input clk,
  output [6:0] rand_out,
  output [3:0] rand_4_bit_encoding
);

  reg [6:0] lfsr_reg = 7'b1011010;

  always @(posedge clk) begin
      lfsr_reg <= {lfsr_reg[5:0], lfsr_reg[6] ^ lfsr_reg[4] ^ lfsr_reg[3] ^ lfsr_reg[1]};
      // Feedback polynomial: x^6 + x^4 + x^3 + x + 1
    //   $display("%d, %b", rand_out[1:0], rand_4_bit_encoding);
  end

  assign rand_out = lfsr_reg;
  assign rand_4_bit_encoding = 4'b0001 << rand_out[1:0];



endmodule