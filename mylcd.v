module mylcd(
    input clock,
    input reset,
    output rs,
    output e,
    output [7:4] d,
    output [15:0] LED
);

    reg clk50MHz = 1'b0;
    reg [19:0] clockCount = 0;
    always @(posedge clock) begin      
        clockCount <= clockCount + 1;
        if (clockCount == 0)
            clk50MHz <= ~clk50MHz;
    end
    assign e = clk50MHz & enabled;
    reg enabled = 1;
    reg [3:0] counter = 0;
    
    assign LED[15] = clk50MHz;
    assign LED[3:0] = counter;
    
    wire [4:0] rom_out;
    mylcd_rom rom(
        .rom_in(counter),
        .rom_out(rom_out)
    );

    assign rs = rom_out[4];
    assign d[7:4] = rom_out[3:0];
    assign LED[10:6] = rom_out[4:0];

    always @(posedge clk50MHz) begin // enable bit goes hi
        counter = reset ? counter + 1 : 0;
        if (counter == 15) enabled = 0;
    end

endmodule

module mylcd_rom (
rom_in   , // Address input
rom_out    // Data output
);
input [3:0] rom_in;
output [4:0] rom_out;

reg [4:0] rom_out;
     
always @*
begin
  case (rom_in)
   4'h0: rom_out = 5'd0;
   4'h1: rom_out = 5'd0;
   4'h2: rom_out = 5'd0;
   4'h3: rom_out = 5'd0;
   4'h4: rom_out = 5'b00010;
   4'h5: rom_out = 5'b00000;
   4'h6: rom_out = 5'b00001;
   4'h7: rom_out = 5'b00000;
   4'h8: rom_out = 5'b00010;
   4'h9: rom_out = 5'b00000;
   4'ha: rom_out = 5'b01100;
   4'hb: rom_out = 5'b10100;
   4'hc: rom_out = 5'b11000;
   4'hd: rom_out = 5'b10100;
   4'he: rom_out = 5'b11001;
   default: rom_out = 5'bXXXXX;
  endcase
end



endmodule